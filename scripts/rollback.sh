#!/usr/bin/env bash

set -e

RESOURCE_GROUP="rg-devops-tracker-dev"
WEBAPP_NAME="devops-tracker-29193"
SLOT_NAME="staging"

az webapp deployment slot swap \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --slot "$SLOT_NAME" \
  --target-slot production

curl --fail https://$WEBAPP_NAME.azurewebsites.net/health