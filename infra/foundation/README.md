# Foundation layer

Persistent shared infrastructure for the `devops-tracker` Azure environment in `swedencentral`.

This layer should survive normal runtime cleanup. It owns the network, shared platform services, identities, role assignments, and remote-state outputs that runtime consumes through `terraform_remote_state`.

## Shared infrastructure

- Existing resource group lookup.
- VNet and service-specific subnets.
- Azure Container Registry with admin credentials disabled.
- Key Vault with RBAC authorization.
- Log Analytics Workspace and Application Insights.
- PostgreSQL private DNS zone: `private.postgres.database.azure.com`.
- App Service private DNS zone: `privatelink.azurewebsites.net`.
- User-assigned identities for App Service, migration job, and GitHub runner.
- GitHub OIDC deployment and operator identities.
- Foundational RBAC assignments.
- NAT Gateway and static public outbound IP for the runner subnet.

## Networking foundations

Current subnet layout:

- `snet-web-egress`: App Service regional VNet integration.
- `snet-postgres`: PostgreSQL Flexible Server delegated subnet.
- `snet-admin`: reserved private administration subnet.
- `snet-container-apps`: Container Apps Environment delegated subnet.
- `snet-private-endpoints`: private endpoint subnet.
- `snet-github-runner`: self-hosted GitHub runner subnet.

The NAT Gateway is associated with `snet-github-runner`. It provides centralized outbound internet access for the runner VM, but it is outbound only and does not apply security policy.

## Operational notes

Apply foundation before runtime. Do not destroy this layer during routine cost-management cycles; recreating it can change identity principal IDs, private DNS links, and runner networking assumptions.

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

If resources already exist in Azure or in previous state, import or move state before applying.
