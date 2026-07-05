#!/usr/bin/env bash
set -euo pipefail

: "${POSTGRES_HOST:?POSTGRES_HOST is required}"
: "${POSTGRES_DATABASE:?POSTGRES_DATABASE is required}"
: "${POSTGRES_ENTRA_ADMIN_USER:?POSTGRES_ENTRA_ADMIN_USER is required}"
: "${POSTGRES_APP_PRINCIPAL_NAME:?POSTGRES_APP_PRINCIPAL_NAME is required}"

POSTGRES_PORT="${POSTGRES_PORT:-5432}"
SQL_FILE="${SQL_FILE:-/workspace/devops-tracker/infra/runtime-aks/bootstrap-postgres-entra-principal.sql}"

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

PGPASSWORD="$ACCESS_TOKEN" psql \
  "host=$POSTGRES_HOST port=$POSTGRES_PORT dbname=$POSTGRES_DATABASE user=$POSTGRES_ENTRA_ADMIN_USER sslmode=require connect_timeout=10" \
  --set=ON_ERROR_STOP=1 \
  --no-psqlrc \
  --set=app_principal_name="$POSTGRES_APP_PRINCIPAL_NAME" \
  --file="$SQL_FILE"

printf 'PostgreSQL Entra principal bootstrap completed for %s in database %s on %s.\n' \
  "$POSTGRES_APP_PRINCIPAL_NAME" \
  "$POSTGRES_DATABASE" \
  "$POSTGRES_HOST"