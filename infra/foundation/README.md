# Foundation layer

Persistent, low/no cost infrastructure that should survive normal runtime cleanup.

This layer reads the persistent resource group as data and owns the VNet, subnets, private DNS, user-assigned
managed identities, GitHub Actions OIDC identity, and foundational RBAC.

Current subnet layout:

- `snet-web-egress` for App Service VNet integration.
- `snet-postgres` for PostgreSQL Flexible Server private access.
- `snet-admin` for private operational access patterns.
- `snet-container-apps` for the Container Apps Environment.
- `snet-private-endpoints` for private endpoints.

Current private DNS zones:

- `private.postgres.database.azure.com`
- `privatelink.azurewebsites.net`

Current managed identities:

- Web App runtime identity.
- Migration job identity.

Do not run `terraform destroy` here during routine cost-management cycles.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

If resources already exist in Azure or in a previous monolithic state, import or
move state before applying to avoid duplicate creation.
