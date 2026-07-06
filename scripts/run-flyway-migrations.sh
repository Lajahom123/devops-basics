#!/usr/bin/env bash
set -euo pipefail

: "${POSTGRES_HOST:?POSTGRES_HOST is required}"
: "${POSTGRES_DATABASE:?POSTGRES_DATABASE is required}"
: "${POSTGRES_USER:?POSTGRES_USER is required}"

POSTGRES_PORT="${POSTGRES_PORT:-5432}"
FLYWAY_LOCATIONS="${FLYWAY_LOCATIONS:-filesystem:/flyway/sql}"
TOKEN_RESOURCE="${TOKEN_RESOURCE:-https://ossrdbms-aad.database.windows.net}"

ensure_azure_auth() {
  if [[ -n "${AZURE_FEDERATED_TOKEN_FILE:-}" && -n "${AZURE_CLIENT_ID:-}" ]]; then
    : "${AZURE_TENANT_ID:?AZURE_TENANT_ID is required for Workload Identity}"

    az login --service-principal \
      -u "$AZURE_CLIENT_ID" \
      --tenant "$AZURE_TENANT_ID" \
      --federated-token "$(tr -d '\n' < "$AZURE_FEDERATED_TOKEN_FILE")" \
      --allow-no-subscriptions \
      --output none

    return
  fi

  if ! az account show --output none 2>/dev/null; then
    echo "ERROR: Azure CLI is not authenticated. Run under AKS Workload Identity or log in with az login." >&2
    exit 1
  fi
}

ensure_azure_auth

ACCESS_TOKEN="$(
  az account get-access-token \
    --resource "$TOKEN_RESOURCE" \
    --query accessToken \
    --output tsv
)"

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "ERROR: Azure CLI returned an empty PostgreSQL access token." >&2
  exit 1
fi

JDBC_URL="jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}?sslmode=require"

echo "Running Flyway migrations against ${POSTGRES_HOST}/${POSTGRES_DATABASE} as ${POSTGRES_USER}."

exec flyway migrate \
  -url="$JDBC_URL" \
  -user="$POSTGRES_USER" \
  -password="$ACCESS_TOKEN" \
  -locations="$FLYWAY_LOCATIONS"