#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-devops-tracker-dev"

POSTGRES_SERVER_NAME="psql-devops-tracker-29193-swn"
VM_NAME="vm-devops-db-admin"

FRONT_DOOR_PROFILE_NAME="fd-devops-tracker-29193"
FRONT_DOOR_ENDPOINT_NAME="fde-devops-tracker-29193"

FAILED=0

run_step() {
  local description="$1"
  shift

  echo ""
  echo "Running: $description"

  if ! "$@"; then
    echo "FAILED: $description"
    FAILED=1
  else
    echo "OK: $description"
  fi
}

echo ""
echo "Checking PostgreSQL Flexible Server state..."

POSTGRES_STATE=$(az postgres flexible-server show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$POSTGRES_SERVER_NAME" \
  --query "state" \
  --output tsv)

echo "PostgreSQL state: $POSTGRES_STATE"

if [[ "$POSTGRES_STATE" == "Ready" ]]; then
  run_step "Stop PostgreSQL Flexible Server" \
    az postgres flexible-server stop \
      --resource-group "$RESOURCE_GROUP" \
      --name "$POSTGRES_SERVER_NAME" \
      --output none
elif [[ "$POSTGRES_STATE" == "Stopped" ]]; then
  echo "OK: PostgreSQL Flexible Server is already stopped."
else
  echo "FAILED: PostgreSQL Flexible Server is in unsupported state: $POSTGRES_STATE"
  FAILED=1
fi

echo ""
echo "Deleting admin VM resources in dependency order..."

VM_ID=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --query "id" \
  --output tsv 2>/dev/null || true)

if [[ -z "$VM_ID" ]]; then
  echo "OK: Admin VM does not exist."
else
  OS_DISK_ID=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --query "storageProfile.osDisk.managedDisk.id" \
    --output tsv)

  NIC_IDS=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --query "networkProfile.networkInterfaces[].id" \
    --output tsv)

  run_step "Delete admin VM" \
    az vm delete \
      --resource-group "$RESOURCE_GROUP" \
      --name "$VM_NAME" \
      --yes \
      --output none

  for NIC_ID in $NIC_IDS; do
    PUBLIC_IP_IDS=$(az network nic show \
      --ids "$NIC_ID" \
      --query "ipConfigurations[].publicIPAddress.id" \
      --output tsv 2>/dev/null || true)

    run_step "Delete admin VM NIC" \
      az network nic delete \
        --ids "$NIC_ID" \
        --output none

    for PUBLIC_IP_ID in $PUBLIC_IP_IDS; do
      run_step "Delete admin VM Public IP" \
        az network public-ip delete \
          --ids "$PUBLIC_IP_ID" \
          --output none
    done
  done

  if [[ -n "$OS_DISK_ID" ]]; then
    run_step "Delete admin VM OS disk" \
      az disk delete \
        --ids "$OS_DISK_ID" \
        --yes \
        --output none
  fi
fi

run_step "Disable Front Door endpoint" \
  az afd endpoint update \
    --resource-group "$RESOURCE_GROUP" \
    --profile-name "$FRONT_DOOR_PROFILE_NAME" \
    --endpoint-name "$FRONT_DOOR_ENDPOINT_NAME" \
    --enabled-state Disabled \
    --output none

if [[ "$FAILED" -ne 0 ]]; then
  echo ""
  echo "One or more stop dev resource operations failed."
  exit 1
fi

echo ""
echo "Done. All stop dev resource operations completed successfully."