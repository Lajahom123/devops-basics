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
inside PostgreSQL from a host that can reach the private endpoint.

```bash
POSTGRES_ENTRA_ADMIN_USER="<postgres-entra-admin-login>" \
  ../../scripts/bootstrap-postgres-entra-principal.sh
```

The script is idempotent. It creates the `pgaadauth` extension if needed and
only calls `pgaadauth_create_principal` when the target PostgreSQL role does not
already exist.

The script uses Terraform outputs for:

- PostgreSQL host: `postgres_server_fqdn`
- database name: `postgres_database_name`
- target Entra principal name: `postgres_app_entra_principal_name`

By default the application principal is the platform AKS workload identity
name. Override with `POSTGRES_APP_PRINCIPAL_NAME` if a different application
identity should be mapped.

The script uses Entra token authentication through Azure CLI and does not need
or accept a PostgreSQL password. It checks for missing Terraform outputs,
missing `psql`, Azure CLI login problems, DNS failures, and private network
connectivity failures before running the SQL.

Supported execution paths:

1. Local machine connected through VPN

   Connect the local machine to a VPN or another approved private network path
   that can resolve and reach the PostgreSQL private endpoint. Install
   Terraform, Azure CLI, and `psql`; authenticate with `az login`; then run the
   script from this repository.

2. Temporary VM inside the VNet

   Create a short-lived admin VM in an approved subnet such as `snet-admin`.
   Install Terraform, Azure CLI, and `psql`; authenticate with Azure CLI; clone
   the repository; run the script; then stop or delete the VM when finished.

3. Future Kubernetes Job inside AKS

   A future-use manifest skeleton lives at
   `k8s/jobs/postgres-entra-bootstrap-job.yaml`. It assumes an operations image
   containing Terraform, Azure CLI, `psql`, and this repository's bootstrap
   script. It also assumes AKS Workload Identity will provide Azure
   authentication. The manifest contains placeholders only, has no secrets, is
   not referenced by Terraform, and should not be applied until AKS and Workload
   Identity are ready.
