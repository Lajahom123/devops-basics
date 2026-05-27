#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-devops-tracker-dev"

POSTGRES_SERVER_NAME="psql-devops-tracker-29193-swn"
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

if [[ "$POSTGRES_STATE" == "Stopped" ]]; then
  run_step "Start PostgreSQL Flexible Server" \
    az postgres flexible-server start \
      --resource-group "$RESOURCE_GROUP" \
      --name "$POSTGRES_SERVER_NAME" \
      --output none
elif [[ "$POSTGRES_STATE" == "Ready" ]]; then
  echo "OK: PostgreSQL Flexible Server is already running."
else
  echo "FAILED: PostgreSQL Flexible Server is in unsupported state: $POSTGRES_STATE"
  FAILED=1
fi

run_step "Enable Front Door endpoint" \
  az afd endpoint update \
    --resource-group "$RESOURCE_GROUP" \
    --profile-name "$FRONT_DOOR_PROFILE_NAME" \
    --endpoint-name "$FRONT_DOOR_ENDPOINT_NAME" \
    --enabled-state Enabled \
    --output none

echo ""
echo "Resolving Front Door hostname..."

FRONT_DOOR_HOSTNAME=$(az afd endpoint show \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_PROFILE_NAME" \
  --endpoint-name "$FRONT_DOOR_ENDPOINT_NAME" \
  --query "hostName" \
  --output tsv)

run_step "Check app health through Front Door" \
  curl --retry 10 \
    --retry-delay 10 \
    --fail \
    --silent \
    --show-error \
    "https://${FRONT_DOOR_HOSTNAME}/health"

if [[ "$FAILED" -ne 0 ]]; then
  echo ""
  echo "One or more start dev resource operations failed."
  exit 1
fi

echo ""
echo "Done. All start dev resource operations completed successfully."