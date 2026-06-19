#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="${RUNTIME_DIR:-$ROOT_DIR/infra/runtime-aks}"
SQL_FILE="${SQL_FILE:-$RUNTIME_DIR/bootstrap-postgres-entra-principal.sql}"

POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_HOST="${POSTGRES_HOST:-}"
POSTGRES_DATABASE="${POSTGRES_DATABASE:-}"
POSTGRES_ENTRA_ADMIN_USER="${POSTGRES_ENTRA_ADMIN_USER:-}"
POSTGRES_APP_PRINCIPAL_NAME="${POSTGRES_APP_PRINCIPAL_NAME:-}"

AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-}"
DRY_RUN="${DRY_RUN:-false}"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

info() {
  printf 'INFO: %s\n' "$*"
}

require_command() {
  local command_name="$1"
  local install_hint="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "$command_name is not installed or is not on PATH. $install_hint"
  fi
}

terraform_output() {
  local output_name="$1"
  local value
  local error_file

  error_file="$(mktemp)"

  if ! value="$(terraform -chdir="$RUNTIME_DIR" output -raw "$output_name" 2>"$error_file")"; then
    cat "$error_file" >&2 || true
    rm -f "$error_file"
    fail "Terraform output '$output_name' is missing or unreadable. Apply infra/runtime-aks first and run this from a host with access to the Terraform backend."
  fi

  rm -f "$error_file"

  if [[ -z "$value" ]]; then
    fail "Terraform output '$output_name' is empty. Apply infra/runtime-aks first and verify the output exists."
  fi

  printf '%s' "$value"
}

check_dns_resolution() {
  local host="$1"
  local result

  if command -v getent >/dev/null 2>&1; then
    getent hosts "$host" >/dev/null 2>&1 && return 0
  fi

  if command -v dig >/dev/null 2>&1; then
    result="$(dig +short "$host" 2>/dev/null || true)"
    [[ -n "$result" ]] && return 0
  fi

  if command -v nslookup >/dev/null 2>&1; then
    nslookup "$host" >/dev/null 2>&1 && return 0
  fi

  if ! command -v getent >/dev/null 2>&1 \
    && ! command -v dig >/dev/null 2>&1 \
    && ! command -v nslookup >/dev/null 2>&1; then
    printf 'WARN: getent, dig, and nslookup are unavailable; skipping DNS preflight.\n' >&2
    return 0
  fi

  fail "Could not resolve PostgreSQL host '$host'. Run this from a network path with private DNS access to privatelink.postgres.database.azure.com."
}

ensure_azure_login() {
  if az account show -o none >/dev/null 2>&1; then
    return 0
  fi

  if [[ -n "${AZURE_CLIENT_ID:-}" && -n "${AZURE_TENANT_ID:-}" && -n "${AZURE_FEDERATED_TOKEN_FILE:-}" ]]; then
    [[ -r "$AZURE_FEDERATED_TOKEN_FILE" ]] || fail "AZURE_FEDERATED_TOKEN_FILE is set but is not readable."

    if az login \
      --service-principal \
      --tenant "$AZURE_TENANT_ID" \
      --username "$AZURE_CLIENT_ID" \
      --federated-token "$(cat "$AZURE_FEDERATED_TOKEN_FILE")" \
      --allow-no-subscriptions \
      -o none >/dev/null; then
      return 0
    fi
  fi

  fail "Azure CLI is not logged in. Run 'az login' on a VM/runner, or configure AKS Workload Identity with AZURE_CLIENT_ID, AZURE_TENANT_ID, and AZURE_FEDERATED_TOKEN_FILE."
}

check_subscription() {
  local current_subscription_id

  current_subscription_id="$(az account show --query id -o tsv)"

  if [[ -z "$current_subscription_id" ]]; then
    fail "Could not determine current Azure subscription."
  fi

  if [[ -z "$AZURE_SUBSCRIPTION_ID" ]]; then
    info "Using Azure subscription: $current_subscription_id"
    return 0
  fi

  if [[ "$current_subscription_id" != "$AZURE_SUBSCRIPTION_ID" ]]; then
    fail "Wrong Azure subscription. Current: $current_subscription_id. Expected: $AZURE_SUBSCRIPTION_ID."
  fi

  info "Azure subscription verified: $current_subscription_id"
}

validate_principal_name() {
  local principal_name="$1"

  [[ -n "$principal_name" ]] || fail "POSTGRES_APP_PRINCIPAL_NAME is empty."

  if [[ "$principal_name" =~ [[:cntrl:]] ]]; then
    fail "POSTGRES_APP_PRINCIPAL_NAME contains control characters."
  fi

  if [[ ${#principal_name} -gt 128 ]]; then
    fail "POSTGRES_APP_PRINCIPAL_NAME is unexpectedly long."
  fi
}

check_private_network_access() {
  local host="$1"
  local database="$2"
  local user="$3"
  local token="$4"
  local output

  if output="$(
    PGPASSWORD="$token" psql \
      "host=$host port=$POSTGRES_PORT dbname=$database user=$user sslmode=require connect_timeout=10" \
      --set=ON_ERROR_STOP=1 \
      --no-psqlrc \
      --tuples-only \
      --command="SELECT 1;" 2>&1
  )"; then
    return 0
  fi

  if grep -Eqi 'could not translate host name|Name or service not known|nodename nor servname|timeout|timed out|No route to host|Connection refused|Network is unreachable|could not connect to server' <<<"$output"; then
    printf '%s\n' "$output" >&2
    fail "Could not reach private PostgreSQL endpoint '$host:$POSTGRES_PORT'. Check VPN, VNet placement, NSG/routing, and private DNS."
  fi

  printf '%s\n' "$output" >&2
  fail "PostgreSQL preflight connection failed. Confirm POSTGRES_ENTRA_ADMIN_USER is the configured PostgreSQL Entra administrator."
}

need_terraform=false
[[ -z "$POSTGRES_HOST" ]] && need_terraform=true
[[ -z "$POSTGRES_DATABASE" ]] && need_terraform=true
[[ -z "$POSTGRES_APP_PRINCIPAL_NAME" ]] && need_terraform=true

require_command az "Install Azure CLI and authenticate with 'az login' or Workload Identity."
require_command psql "Install the PostgreSQL client tools."

if [[ "$need_terraform" == "true" ]]; then
  require_command terraform "Install Terraform in this execution environment or provide POSTGRES_HOST, POSTGRES_DATABASE, and POSTGRES_APP_PRINCIPAL_NAME explicitly."
fi

psql --version

[[ -f "$SQL_FILE" ]] || fail "SQL file not found at '$SQL_FILE'. Run this script from the repository checkout or set SQL_FILE."

if [[ -z "$POSTGRES_HOST" ]]; then
  POSTGRES_HOST="$(terraform_output postgres_server_fqdn)"
fi

if [[ -z "$POSTGRES_DATABASE" ]]; then
  POSTGRES_DATABASE="$(terraform_output postgres_database_name)"
fi

if [[ -z "$POSTGRES_APP_PRINCIPAL_NAME" ]]; then
  POSTGRES_APP_PRINCIPAL_NAME="$(terraform_output postgres_app_entra_principal_name)"
fi

if [[ -z "$POSTGRES_ENTRA_ADMIN_USER" ]]; then
  fail "POSTGRES_ENTRA_ADMIN_USER is required. Set it to the PostgreSQL Microsoft Entra administrator login name."
fi

validate_principal_name "$POSTGRES_APP_PRINCIPAL_NAME"

ensure_azure_login
check_subscription
check_dns_resolution "$POSTGRES_HOST"

if ! ACCESS_TOKEN="$(
  az account get-access-token \
    --resource https://ossrdbms-aad.database.windows.net \
    --query accessToken \
    -o tsv
)"; then
  fail "Could not obtain an Entra access token for Azure Database for PostgreSQL. Check Azure CLI authentication."
fi

if [[ -z "$ACCESS_TOKEN" ]]; then
  fail "Azure CLI returned an empty PostgreSQL access token."
fi

check_private_network_access "$POSTGRES_HOST" "$POSTGRES_DATABASE" "$POSTGRES_ENTRA_ADMIN_USER" "$ACCESS_TOKEN"

if [[ "$DRY_RUN" == "true" ]]; then
  info "DRY_RUN=true. Preflight checks succeeded. SQL bootstrap was not executed."
  exit 0
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