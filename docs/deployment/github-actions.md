# GitHub Actions deployment

GitHub Actions deploys without Azure client secrets, ACR admin credentials, or Web App publish profiles. Azure authentication uses GitHub OIDC federation with Microsoft Entra ID, and runner registration is GitHub App based.

- Environment: `dev`
- Deployment strategy: staging slot swap

The staging slot is not a separate environment. It is a deployment slot used to validate a release candidate before swapping it into production.

## Identity model

The platform layer creates the Entra applications, service principals, and federated credentials used by GitHub Actions. Repository secrets hold identifiers, not Azure passwords:

```text
AZURE_DEV_GITHUB_ACTIONS_DEPLOY_CLIENT_ID
AZURE_DEV_OPERATOR_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
FRONT_DOOR_URL
```

GitHub-hosted runners use OIDC for Azure API operations. The self-hosted runner uses GitHub App based registration and is used for private validation, not as the main deployment identity.

## Workflow stages

The main deployment workflow is intentionally split by responsibility:

- Build/push: build the application image and push immutable/latest tags to ACR.
- Migrations: build the Flyway image, update the Container Apps Job, and run migrations before app promotion.
- Staging deployment: update and restart the staging slot with the new image.
- Private validation: run health/version checks from the VNet runner against the staging private endpoint.
- Slot swap: swap staging into production from a GitHub-hosted runner through Azure APIs.
- Production validation: run health/version checks from the VNet runner against the production private endpoint and validate Front Door.

The private validation stages target runners with self-hosted VNet labels. The runner exists so validation can exercise private DNS and private endpoint routing instead of relying on public App Service access.

## Runner architecture

The runtime layer creates a persistent Ubuntu VM runner:

- no public IP;
- dedicated `snet-github-runner` subnet;
- user-assigned managed identity;
- Key Vault access for GitHub App registration material;
- persistent GitHub Actions runner service;
- labels for private/VNet workload targeting.

Runner outbound traffic uses the NAT Gateway associated with its subnet. NAT provides a centralized outbound IP, but it is not a firewall or inbound access mechanism.

## Private endpoint validation

Runtime creates private endpoints for:

- production App Service, subresource `sites`;
- staging slot, subresource `sites-staging`.

Both use the shared App Service private DNS zone `privatelink.azurewebsites.net`. Validation checks should run from inside the VNet or another connected private network.

## Rollback

Rollback is modeled as a slot swap through `.github/workflows/rollback-production.yml`. It uses OIDC to perform the Azure operation and then validates production. Because rollback is slot based, staging must still hold the previously known-good production version for rollback to be meaningful.

## PostgreSQL Entra bootstrap workflow

The bootstrap Job is not part of normal deploys. Run it manually when bootstrapping
or repairing PostgreSQL Entra principals. Populate workflow or repository variables
from `infra/runtime-aks` Terraform outputs:

| Variable | Terraform output |
|---|---|
| `AZURE_TENANT_ID` | `azure_tenant_id` |
| `POSTGRES_BOOTSTRAP_IDENTITY_CLIENT_ID` | `postgres_bootstrap_identity_client_id` |
| `POSTGRES_HOST` | `postgres_server_fqdn` |
| `POSTGRES_DATABASE` | `postgres_database_name` |
| `POSTGRES_ENTRA_ADMIN_USER` | `postgres_bootstrap_identity_name` |
| `POSTGRES_APP_PRINCIPAL_NAME` | `postgres_app_entra_principal_name` |

Helm equivalents in `helm/jobs/devops-tracker-jobs/values-dev.yaml`:

- `global.tenantId` ← `azure_tenant_id`
- `postgres.host`, `postgres.port`, `postgres.database` ← shared by bootstrap and migration Jobs
- `postgres.appUser` ← bootstrap PostgreSQL role
- `postgres.migrationUser` ← migration PostgreSQL role
- `bootstrap.managedIdentityClientId` ← `postgres_bootstrap_identity_client_id`
- `bootstrap.entraAdminUser` ← `postgres_bootstrap_identity_name`

Enable the Job only for the bootstrap run:

```bash
helm upgrade devops-tracker-jobs helm/jobs/devops-tracker-jobs \
  --install \
  --namespace devops-tracker \
  --values helm/jobs/devops-tracker-jobs/values-dev.yaml \
  --set migrations.enabled=false \
  --set bootstrap.enabled=true \
  --set bootstrap.managedIdentityClientId="$(terraform -chdir=infra/runtime-aks output -raw postgres_bootstrap_identity_client_id)" \
  --set global.tenantId="${AZURE_TENANT_ID}"
```

## AKS application PostgreSQL authentication

The API Helm chart wires PostgreSQL connection settings through `postgres.*` values.
Production auth mode is `entra`. The deploy workflow sets the Workload Identity
client ID and tenant ID from repository variables:

```bash
helm upgrade devops-tracker-api helm/applications/devops-tracker-api \
  --install \
  --namespace devops-tracker \
  --values helm/applications/devops-tracker-api/values-dev.yaml \
  --set azure.tenantId="${AZURE_TENANT_ID}" \
  --set azure.clientId="${AZURE_DEV_AKS_WORKLOAD_CLIENT_ID}"
```

Use the AKS workload identity client ID from platform Terraform outputs
(`aks_workload_identity_client_id`) or the `AZURE_DEV_AKS_WORKLOAD_CLIENT_ID`
repository variable in GitHub Actions deploys.

See [PostgreSQL Entra authentication on AKS](../security/postgresql-entra-aks.md) for
the full flow, token refresh behaviour, and operational guidance.

## AKS database migrations (Flyway Job)

Schema migrations run through the separate `devops-tracker-jobs` Helm release
before each application deploy.

| Variable | Purpose |
|---|---|
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID |
| `AZURE_DEV_MIGRATION_JOB_CLIENT_ID` | Migration Job workload identity client ID |
| `AZURE_DEV_AKS_WORKLOAD_CLIENT_ID` | Application workload identity client ID |

Helm equivalents in `helm/jobs/devops-tracker-jobs/values-dev.yaml`:

- `postgres.host`, `postgres.port`, `postgres.database` ← shared connection settings
- `postgres.migrationUser` ← migration PostgreSQL role (`migration_job_identity_name`)
- `migrations.managedIdentityClientId` ← `AZURE_DEV_MIGRATION_JOB_CLIENT_ID`
- `global.tenantId` ← `AZURE_TENANT_ID`

Deploy workflow order (`.github/workflows/build-and-deploy-aks.yml`):

1. Build and push application and migration images.
2. Delete any previous `devops-tracker-db-migrate` Job.
3. `helm upgrade devops-tracker-jobs` with `migrations.enabled=true` and the migration image tag.
4. Wait for Job completion and print logs.
5. Deploy `devops-tracker-api` with the new application image tag.

If the migration Job fails, the deploy job does not run. The application chart does
not manage migration Jobs.
