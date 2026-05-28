#!/usr/bin/env bash
set -euo pipefail

KEY_VAULT_NAME="${key_vault_name}"

RUNNER_VERSION="2.324.0"
RUNNER_USER="runner"
RUNNER_DIR="/home/$${RUNNER_USER}/actions-runner"
RUNNER_LABELS="dev,private,azure,vnet"
RUNNER_NAME="$(hostname)"

log() {
  echo "[$(date --iso-8601=seconds)] $*"
}

base64url() {
  openssl base64 -A | tr '+/' '-_' | tr -d '='
}

log "Installing dependencies"
apt-get update
apt-get install -y curl jq tar openssl ca-certificates lsb-release gnupg

if ! command -v az >/dev/null 2>&1; then
  log "Installing Azure CLI"
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash
fi

log "Logging in with managed identity"
az login --identity >/dev/null

log "Reading GitHub App configuration from Key Vault"
GITHUB_CLIENT_ID="$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name github-runner-client-id --query value -o tsv)"
GITHUB_INSTALLATION_ID="$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name github-runner-installation-id --query value -o tsv)"
GITHUB_REPO_OWNER="$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name github-runner-repo-owner --query value -o tsv)"
GITHUB_REPO_NAME="$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name github-runner-repo-name --query value -o tsv)"

az keyvault secret show \
  --vault-name "$KEY_VAULT_NAME" \
  --name github-runner-app-private-key \
  --query value \
  -o tsv > /tmp/github-app-private-key.pem

chmod 600 /tmp/github-app-private-key.pem

log "Generating GitHub App JWT"
NOW="$(date +%s)"
IAT="$((NOW - 60))"
EXP="$((NOW + 540))"

HEADER="$(printf '{"alg":"RS256","typ":"JWT"}' | base64url)"
PAYLOAD="$(printf '{"iat":%s,"exp":%s,"iss":"%s"}' "$IAT" "$EXP" "$GITHUB_CLIENT_ID" | base64url)"
SIGNATURE="$(printf '%s.%s' "$HEADER" "$PAYLOAD" | openssl dgst -sha256 -sign /tmp/github-app-private-key.pem | base64url)"
JWT="$${HEADER}.$${PAYLOAD}.$${SIGNATURE}"

log "Requesting GitHub App installation token"
INSTALLATION_TOKEN="$(
  curl -fsSL \
    -X POST \
    -H "Authorization: Bearer $${JWT}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/app/installations/$${GITHUB_INSTALLATION_ID}/access_tokens" \
  | jq -r '.token'
)"

if [[ -z "$INSTALLATION_TOKEN" || "$INSTALLATION_TOKEN" == "null" ]]; then
  echo "Failed to get GitHub installation token"
  exit 1
fi

log "Requesting runner registration token"
RUNNER_TOKEN="$(
  curl -fsSL \
    -X POST \
    -H "Authorization: Bearer $${INSTALLATION_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$${GITHUB_REPO_OWNER}/$${GITHUB_REPO_NAME}/actions/runners/registration-token" \
  | jq -r '.token'
)"

if [[ -z "$RUNNER_TOKEN" || "$RUNNER_TOKEN" == "null" ]]; then
  echo "Failed to get runner registration token"
  exit 1
fi

log "Creating runner user if needed"
if ! id "$RUNNER_USER" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "$RUNNER_USER"
fi

log "Downloading GitHub Actions runner"
mkdir -p "$RUNNER_DIR"
chown -R "$RUNNER_USER:$RUNNER_USER" "$RUNNER_DIR"

cd "$RUNNER_DIR"

if [[ ! -f ./config.sh ]]; then
  curl -fsSL \
    -o actions-runner-linux-x64.tar.gz \
    "https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz"

  tar xzf actions-runner-linux-x64.tar.gz
  rm actions-runner-linux-x64.tar.gz
  chown -R "$RUNNER_USER:$RUNNER_USER" "$RUNNER_DIR"
fi

if [[ ! -f ".runner" ]]; then
  log "Configuring runner"
  sudo -u "$RUNNER_USER" ./config.sh \
    --url "https://github.com/$${GITHUB_REPO_OWNER}/$${GITHUB_REPO_NAME}" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --unattended \
    --replace
else
  log "Runner already configured"
fi

log "Installing and starting runner service"
./svc.sh install "$RUNNER_USER" || true
./svc.sh start

rm -f /tmp/github-app-private-key.pem

log "GitHub runner installation complete"