# Runtime layer

Cost-bearing workload infrastructure for the `devops-tracker` `dev` environment in `switzerlandnorth`.

Runtime consumes shared foundation outputs through `terraform_remote_state`. It should not duplicate foundation naming or hardcode resource IDs.

## Workload resources

- Linux App Service plan and Linux Web App.
- Staging deployment slot.
- PostgreSQL Flexible Server and application database.
- Container Apps Environment and Flyway migration job.
- Front Door Premium, route, WAF policy, and Private Link origin.
- Production App Service private endpoint.
- Staging slot private endpoint.
- GitHub self-hosted runner VM.
- Diagnostic settings, failed-request alert, and workload RBAC.

- Environment: `dev`
- Deployment strategy: staging slot swap

The staging slot is not a separate environment. It is a release candidate surface inside `dev` and is swapped into production after private validation succeeds.

## Traffic and validation

Public user traffic enters through Front Door and reaches App Service over Private Link. Direct public access to the production app and staging slot is disabled.

Private validation runs from the self-hosted runner inside the VNet:

- staging validation: runner to staging private endpoint;
- production validation: runner to production private endpoint;
- public edge validation: runner or workflow checks Front Door.

The runner VM is an Ubuntu VM with no public IP, a dedicated subnet, a managed identity, GitHub App based registration, and a persistent runner service. Runner labels include private/VNet targeting labels used by workflows.

## Operations

Apply runtime after foundation:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Runtime can be destroyed to remove most active cost:

```bash
terraform destroy
```

Keep `infra/foundation` deployed unless the project is being retired.
