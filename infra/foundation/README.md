# Foundation layer

Persistent shared platform infrastructure for the `devops-tracker` Azure student environment.

This layer should stay cheap and stable. It contains the platform resource group, VNet, shared subnets, shared Azure Container Registry, shared managed identities, and Key Vault. Add private DNS and minimal monitoring later as separate modules and applies.

See `DEFERRED.md` for the full inventory of previously removed resources, including the module-ready pieces and the items that should stay in runtime or labs.

## Current resources

- Resource group: `rg-devops-tracker-dev-platform`.
- VNet: `vnet-devops-tracker-dev`.
- Subnets for private endpoints, PostgreSQL, admin access, labs, GitHub runner, and future AKS nodes.
- Azure Container Registry using the Basic SKU, public network access enabled, and admin user disabled.
- Managed identities for GitHub Actions deploy, AKS workload identity, migration jobs, and optional GitHub private runner reuse.
- Key Vault with RBAC authorization enabled, public network access enabled, soft delete enabled, and purge protection disabled for dev cleanup.

## Not in foundation yet

Do not deploy cost-bearing or runtime resources from this root:

- AKS
- PostgreSQL
- Front Door
- Bastion
- VPN Gateway or API Management
- NAT Gateway
- App Service
- self-hosted runner VM
- Container Apps jobs

## Operational notes

Apply foundation before runtime. For the student subscription, add modules in small checkpoints and inspect every plan before applying.

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

If Terraform wants to destroy or replace anything unexpected, stop and investigate before applying.
