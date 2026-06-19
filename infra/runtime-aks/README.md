# Runtime AKS layer

This Terraform root will own the runtime infrastructure for PostgreSQL, AKS,
and Kubernetes-related resources in `swedencentral`.

The root is intentionally empty for the first checkpoint. It configures backend
state, providers, and foundation remote state only, so `terraform plan` should
show no resources to create.

## State

Runtime AKS uses a separate state file from foundation:

```text
runtime-aks.tfstate
```

The state is stored in the same Terraform state storage account and container as
the foundation state, but with its own key.

## Foundation dependency

This root depends on the foundation remote state:

```text
foundation.tfstate
```

Foundation must be applied before this root. Shared platform values such as the
VNet, AKS and PostgreSQL subnet IDs, ACR, Key Vault, Log Analytics workspace, and
managed identities are consumed through `data.terraform_remote_state.foundation`.
Do not duplicate those values as runtime variables or recreate foundation-owned
resources here.

## Verification

Run from this directory:

```bash
terraform init
terraform validate
terraform plan
```

Expected result: initialization and validation succeed, and the plan reports no
resources to add, change, or destroy.
