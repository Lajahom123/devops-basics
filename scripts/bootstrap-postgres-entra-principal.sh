#!/usr/bin/env bash
set -euo pipefail

: "${POSTGRES_HOST:?POSTGRES_HOST is required}"
: "${POSTGRES_DATABASE:?POSTGRES_DATABASE is required}"
: "${POSTGRES_ENTRA_ADMIN_USER:?POSTGRES_ENTRA_ADMIN_USER is required}"
: "${POSTGRES_APP_PRINCIPAL_NAME:?POSTGRES_APP_PRINCIPAL_NAME is required}"

POSTGRES_PORT="${POSTGRES_PORT:-5432}"
CREATE_PRINCIPAL_SQL_FILE="${CREATE_PRINCIPAL_SQL_FILE:-/opt/postgres-bootstrap/bootstrap-postgres-entra-principal.sql}"
GRANT_PERMISSIONS_SQL_FILE="${GRANT_PERMISSIONS_SQL_FILE:-/opt/postgres-bootstrap/grant-app-permissions.sql}"

if [[ ! -f "$CREATE_PRINCIPAL_SQL_FILE" ]]; then
  echo "ERROR: SQL file not found at ${CREATE_PRINCIPAL_SQL_FILE}." >&2
  exit 1
fi

if [[ ! -f "$GRANT_PERMISSIONS_SQL_FILE" ]]; then
  echo "ERROR: SQL file not found at ${GRANT_PERMISSIONS_SQL_FILE}." >&2
  exit 1
fi

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
    echo "ERROR: Azure CLI is not authenticated. Log in with 'az login' or run under AKS Workload Identity." >&2
    exit 1
  fi
}

ensure_azure_auth

ACCESS_TOKEN="$(
  az account get-access-token \
    --resource https://ossrdbms-aad.database.windows.net \
    --query accessToken \
    -o tsv
)"

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "ERROR: Azure CLI returned an empty PostgreSQL access token." >&2
  exit 1
fi

echo "Creating PostgreSQL Entra principal '${POSTGRES_APP_PRINCIPAL_NAME}' via database 'postgres'."

PGPASSWORD="$ACCESS_TOKEN" psql \
  "host=$POSTGRES_HOST port=$POSTGRES_PORT dbname=postgres user=$POSTGRES_ENTRA_ADMIN_USER sslmode=require connect_timeout=10" \
  --set=ON_ERROR_STOP=1 \
  --no-psqlrc \
  --set=app_principal_name="$POSTGRES_APP_PRINCIPAL_NAME" \
  --file="$CREATE_PRINCIPAL_SQL_FILE"

echo "Granting application permissions on database '${POSTGRES_DATABASE}'."

PGPASSWORD="$ACCESS_TOKEN" psql \
  "host=$POSTGRES_HOST port=$POSTGRES_PORT dbname=$POSTGRES_DATABASE user=$POSTGRES_ENTRA_ADMIN_USER sslmode=require connect_timeout=10" \
  --set=ON_ERROR_STOP=1 \
  --no-psqlrc \
  --set=app_principal_name="$POSTGRES_APP_PRINCIPAL_NAME" \
  --set=database_name="$POSTGRES_DATABASE" \
  --file="$GRANT_PERMISSIONS_SQL_FILE"

printf 'PostgreSQL Entra principal bootstrap completed for %s in database %s on %s.\n' \
  "$POSTGRES_APP_PRINCIPAL_NAME" \
  "$POSTGRES_DATABASE" \
  "$POSTGRES_HOST"