# Runtime AKS layer

This Terraform root will own the runtime infrastructure for PostgreSQL, AKS,
and Kubernetes-related resources in `swedencentral`.

The root is intentionally empty for the first checkpoint. It configures backend
state, providers, and platform remote state only, so `terraform plan` should
show no resources to create.

## State

Runtime AKS uses a separate state file from platform:

```text
runtime-aks.tfstate
```

The state is stored in the same Terraform state storage account and container as
the platform state, but with its own key.

## Platform dependency

This root depends on the platform remote state:

```text
platform.tfstate
```

Platform must be applied before this root. Shared platform values such as the
VNet, AKS and PostgreSQL subnet IDs, ACR, Key Vault, Log Analytics workspace, and
managed identities are consumed through `data.terraform_remote_state.platform`.
Do not duplicate those values as runtime variables or recreate platform-owned
resources here.

Runtime AKS creates its own runtime resource group:

```text
rg-devops-tracker-dev-runtime
```

Cost-bearing runtime resources such as PostgreSQL are created there. Platform
continues to own the platform resource group, VNet, delegated subnets, private
DNS zones, shared identities, and monitoring primitives.

## Required PostgreSQL inputs

Before the first apply, copy `terraform.tfvars.example` to `terraform.tfvars`
and set at least:

- `postgres_administrator_password` — bootstrap PostgreSQL login password

PostgreSQL Entra administration is owned by the platform layer:

- Entra group: `devops-tracker-postgres-admins`
- group members: configured general admin and the PostgreSQL bootstrap managed identity
- PostgreSQL Flexible Server Entra admin: the group above

Set `postgres_admin_member_object_id` in `infra/platform/terraform.tfvars` for
the general admin or service principal group member. Do not use a personal email as the
PostgreSQL server administrator principal name.

## Verification

Run from this directory:

```bash
terraform init
terraform validate
terraform plan
```

Expected result: initialization and validation succeed, and the plan reports no
resources to add, change, or destroy.

## PostgreSQL Entra principal bootstrap

After PostgreSQL is applied and verified, create the application Entra principal
inside PostgreSQL using the bootstrap managed identity.

Relevant Terraform outputs from this root:

- `postgres_server_fqdn`
- `postgres_database_name`
- `postgres_app_entra_principal_name`
- `postgres_bootstrap_identity_name`
- `postgres_bootstrap_identity_client_id`
- `postgres_entra_admin_group_name`
- `azure_tenant_id`

For the Kubernetes bootstrap Job, set `postgresBootstrap.managedIdentityClientId` in Helm
to `postgres_bootstrap_identity_client_id` and `postgresBootstrap.entraAdminUser`
to `postgres_bootstrap_identity_name` (or the Entra admin group name).

Connection settings (`postgres.host`, `postgres.database`, `postgres.user`) are shared
between the API deployment and the bootstrap Job.

The bootstrap Job is managed by Helm and disabled by default
(`postgresBootstrap.enabled: false`). Enable it only for one-time bootstrap or
repair.

Supported execution paths:

1. Kubernetes Job inside AKS (preferred)

   Build and push `Dockerfile.postgres-bootstrap`, then enable the Helm bootstrap
   Job with Workload Identity. The Job ServiceAccount uses the bootstrap managed
   identity client ID and federated credential.

2. Local machine connected through VPN

   Connect through a private network path that can reach PostgreSQL. Authenticate
   with `az login` as a member of `devops-tracker-postgres-admins`, then run
   `scripts/bootstrap-postgres-entra-principal.sh` with the Terraform output
   values above.

## Application PostgreSQL authentication

The API connects to PostgreSQL using Helm `postgres.*` values with
`authMode: entra`. See
[PostgreSQL Entra authentication on AKS](../../docs/security/postgresql-entra-aks.md)
for the full authentication flow and operational guidance.
