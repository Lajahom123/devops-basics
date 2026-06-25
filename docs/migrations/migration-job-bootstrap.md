# Migration job bootstrap

Database migrations run through an Azure Container Apps Job in the runtime layer. The job uses the Container Apps Environment attached to `snet-container-apps`, pulls a Flyway image from ACR, and connects to PostgreSQL over the private network.

## Why a bootstrap image exists

Container Apps Job resources require a valid container image during infrastructure creation. Terraform creates the job before the normal CI/CD pipeline has produced a migration image for the current commit, so the initial environment needs a bootstrap image.

After bootstrap:

- GitHub Actions builds and pushes migration images from `Dockerfile.flyway`.
- GitHub Actions updates the Container Apps Job image to the current commit tag.
- GitHub Actions starts the job and waits for it to succeed before deploying the Web App slot.
- Manual bootstrap upload is no longer part of normal operations.

## Bootstrap command

Use the actual ACR name from `infra/foundation` outputs or `terraform.tfvars`.

```bash
ACR_NAME="devopstracker29193"
ACR_LOGIN_SERVER="$ACR_NAME.azurecr.io"

az acr login --name "$ACR_NAME"

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -f Dockerfile.flyway \
  -t "$ACR_LOGIN_SERVER/devops-tracker-migrations:bootstrap" \
  --push \
  .
```

## Runtime behavior

The migration job is configured with:

- manual trigger mode;
- one replica and one required completion;
- a 10 minute replica timeout;
- a migration-job user-assigned managed identity for ACR pull;
- a Flyway command that targets the private PostgreSQL FQDN;
- the PostgreSQL administrator password as a Container Apps secret.

The job image is intentionally ignored by Terraform lifecycle rules after creation so GitHub Actions can update it per deployment without Terraform trying to roll it back to the bootstrap tag.

## Security notes

The job currently uses the PostgreSQL administrator password for migrations. That is practical for bootstrap, but it is still privileged database access. A future hardening step should move migrations to a narrower database role and, where practical, an Entra-backed authentication flow.
