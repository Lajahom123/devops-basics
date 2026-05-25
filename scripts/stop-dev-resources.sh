#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-devops-tracker-dev"

POSTGRES_SERVER_NAME="psql-devops-tracker-29193-swn"
VM_NAME="vm-devops-db-admin"

FRONT_DOOR_PROFILE_NAME="fd-devops-tracker-29193"
FRONT_DOOR_ENDPOINT_NAME="fde-devops-tracker-29193"

APP_SERVICE_PLAN_NAME="plan-devops-tracker"

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

echo "Stopping PostgreSQL Flexible Server if possible..."
run_step "Stop PostgreSQL Flexible Server" \
  az postgres flexible-server stop \
    --resource-group "$RESOURCE_GROUP" \
    --name "$POSTGRES_SERVER_NAME"

echo ""
echo "Finding admin VM related resources..."

VM_IDS=$(az resource list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?contains(name, '$VM_NAME')].id" \
  --output tsv)

if [[ -n "$VM_IDS" ]]; then
  echo "Deleting admin VM related resources..."
  echo "$VM_IDS"

  run_step "Delete admin VM related resources" \
    az resource delete --ids $VM_IDS
else
  echo "No admin VM related resources found."
fi

run_step "Disable Front Door endpoint" \
  az afd endpoint update \
    --resource-group "$RESOURCE_GROUP" \
    --profile-name "$FRONT_DOOR_PROFILE_NAME" \
    --endpoint-name "$FRONT_DOOR_ENDPOINT_NAME" \
    --enabled-state Disabled

run_step "Scale App Service Plan down to B1" \
  az appservice plan update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_SERVICE_PLAN_NAME" \
    --sku B1

if [[ "$FAILED" -ne 0 ]]; then
  echo ""
  echo "One or more stop dev resource operations failed."
  exit 1
fi

echo ""
echo "Done. All stop dev resource operations completed successfully."