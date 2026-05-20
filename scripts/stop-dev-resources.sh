#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-devops-tracker-dev"

POSTGRES_SERVER_NAME="psql-devops-tracker-29193-swn"
VM_NAME="vm-devops-db-admin"

FRONT_DOOR_PROFILE_NAME="fd-devops-tracker-29193"
FRONT_DOOR_ENDPOINT_NAME="fde-devops-tracker-29193"

APP_SERVICE_PLAN_NAME="asp-devops-tracker-29193"

echo "Stopping PostgreSQL Flexible Server if possible..."
az postgres flexible-server stop \
  --resource-group "$RESOURCE_GROUP" \
  --name "$POSTGRES_SERVER_NAME" || true

echo "Finding admin VM related resources..."

VM_IDS=$(az resource list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?contains(name, '$VM_NAME')].id" \
  --output tsv)

if [[ -n "$VM_IDS" ]]; then
  echo "Deleting admin VM related resources..."
  echo "$VM_IDS"

  az resource delete --ids $VM_IDS || true
else
  echo "No admin VM related resources found."
fi

echo "Disabling Front Door endpoint..."
az afd endpoint update \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_PROFILE_NAME" \
  --endpoint-name "$FRONT_DOOR_ENDPOINT_NAME" \
  --enabled-state Disabled || true

echo "Scaling App Service Plan down to B1..."
az appservice plan update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE_PLAN_NAME" \
  --sku B1 || true

echo "Done."