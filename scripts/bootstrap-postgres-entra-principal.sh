#!/usr/bin/env bash
set -euo pipefail

: "${POSTGRES_HOST:?POSTGRES_HOST is required}"
: "${POSTGRES_DATABASE:?POSTGRES_DATABASE is required}"
: "${POSTGRES_ENTRA_ADMIN_USER:?POSTGRES_ENTRA_ADMIN_USER is required}"
: "${POSTGRES_BOOTSTRAP_PRINCIPALS:?POSTGRES_BOOTSTRAP_PRINCIPALS is required}"

POSTGRES_PORT="${POSTGRES_PORT:-5432}"
CREATE_PRINCIPAL_SQL_FILE="${CREATE_PRINCIPAL_SQL_FILE:-/opt/postgres-bootstrap/bootstrap-postgres-entra-principal.sql}"
GRANT_APP_PERMISSIONS_SQL_FILE="${GRANT_APP_PERMISSIONS_SQL_FILE:-/opt/postgres-bootstrap/grant-app-permissions.sql}"
GRANT_MIGRATION_PERMISSIONS_SQL_FILE="${GRANT_MIGRATION_PERMISSIONS_SQL_FILE:-/opt/postgres-bootstrap/grant-migration-permissions.sql}"

for sql_file in \
  "$CREATE_PRINCIPAL_SQL_FILE" \
  "$GRANT_APP_PERMISSIONS_SQL_FILE" \
  "$GRANT_MIGRATION_PERMISSIONS_SQL_FILE"; do
  if [[ ! -f "$sql_file" ]]; then
    echo "ERROR: SQL file not found at ${sql_file}." >&2
    exit 1
  fi
done

grant_sql_for_profile() {
  case "$1" in
    app)
      printf '%s' "$GRANT_APP_PERMISSIONS_SQL_FILE"
      ;;
    migration)
      printf '%s' "$GRANT_MIGRATION_PERMISSIONS_SQL_FILE"
      ;;
    *)
      echo "ERROR: Unknown grant profile '${1}'. Expected 'app' or 'migration'." >&2
      exit 1
      ;;
  esac
}

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

while IFS=: read -r role_name grant_profile; do
  role_name="$(printf '%s' "$role_name" | xargs)"
  grant_profile="$(printf '%s' "${grant_profile:-}" | xargs)"

  [[ -z "$role_name" ]] && continue

  if [[ -z "$grant_profile" ]]; then
    echo "ERROR: Missing grant profile for principal '${role_name}'." >&2
    exit 1
  fi

  echo "Creating PostgreSQL Entra principal '${role_name}' via database 'postgres'."

  PGPASSWORD="$ACCESS_TOKEN" psql \
    "host=$POSTGRES_HOST port=$POSTGRES_PORT dbname=postgres user=$POSTGRES_ENTRA_ADMIN_USER sslmode=require connect_timeout=10" \
    --set=ON_ERROR_STOP=1 \
    --no-psqlrc \
    --set=principal_name="$role_name" \
    --file="$CREATE_PRINCIPAL_SQL_FILE"

  grant_sql_file="$(grant_sql_for_profile "$grant_profile")"

  echo "Granting '${grant_profile}' permissions to '${role_name}' on database '${POSTGRES_DATABASE}'."

  PGPASSWORD="$ACCESS_TOKEN" psql \
    "host=$POSTGRES_HOST port=$POSTGRES_PORT dbname=$POSTGRES_DATABASE user=$POSTGRES_ENTRA_ADMIN_USER sslmode=require connect_timeout=10" \
    --set=ON_ERROR_STOP=1 \
    --no-psqlrc \
    --set=principal_name="$role_name" \
    --set=database_name="$POSTGRES_DATABASE" \
    --file="$grant_sql_file"

  printf 'Bootstrapped %s with %s permissions.\n' \
    "$role_name" \
    "$grant_profile"
done <<< "$POSTGRES_BOOTSTRAP_PRINCIPALS"

printf 'PostgreSQL Entra principal bootstrap completed on %s.\n' "$POSTGRES_HOST"