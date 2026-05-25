#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-devops-tracker-dev"

POSTGRES_SERVER_NAME="psql-devops-tracker-29193-swn"
FRONT_DOOR_PROFILE_NAME="fd-devops-tracker-29193"
FRONT_DOOR_ENDPOINT_NAME="fde-devops-tracker-29193"
APP_SERVICE_PLAN_NAME="plan-devops-tracker"

echo "Starting PostgreSQL Flexible Server..."
az postgres flexible-server start \
  --resource-group "$RESOURCE_GROUP" \
  --name "$POSTGRES_SERVER_NAME" || true

echo "Scaling App Service Plan to S1..."
az appservice plan update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE_PLAN_NAME" \
  --sku S1 || true

echo "Enabling Front Door endpoint..."
az afd endpoint update \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_PROFILE_NAME" \
  --endpoint-name "$FRONT_DOOR_ENDPOINT_NAME" \
  --enabled-state Enabled || true

echo "Checking app health..."
curl --retry 10 --retry-delay 10 --fail --silent --show-error \
  https://devops-tracker-29193.azurewebsites.net/health || true

echo "Done."