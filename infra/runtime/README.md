# Runtime layer

Destroyable, cost-bearing application infrastructure.

This layer owns ACR, PostgreSQL Flexible Server, PostgreSQL database, App Service
Plan, Linux Web App, staging slot, runtime Key Vault settings, Container Apps
migration job, monitoring, alerts, Web App private endpoint, VNet integration,
and runtime RBAC assignments.

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

Deployment flow depends on resources from this layer:

- application images are pushed to ACR;
- Flyway migration images are pushed to ACR;
- the Container Apps migration job runs before the Web App slot swap;
- the staging slot is verified before it is swapped into production;
- Application Insights and diagnostic settings send telemetry to Log Analytics.
