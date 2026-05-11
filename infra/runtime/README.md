# Runtime layer

Destroyable, cost-bearing application infrastructure.

This layer owns ACR, PostgreSQL Flexible Server, PostgreSQL database, App Service
Plan, Linux Web App, runtime Key Vault settings, VNet integration, and runtime
RBAC assignments.

Runtime discovers foundation resources through Azure data sources by name. It
does not hardcode foundation resource IDs.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Runtime can be destroyed to remove most active cost:

```bash
terraform destroy
```

Keep `infra/foundation` deployed unless the project is being retired.
