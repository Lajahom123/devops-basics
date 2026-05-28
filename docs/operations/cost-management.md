# Cost management

The project is structured so foundational infrastructure can remain deployed while runtime compute can be stopped or destroyed.

## Low or minimal cost resources

Foundation resources are intended to stay deployed:

- resource group;
- VNet;
- subnets;
- private DNS zones and VNet links;
- Azure Container Registry;
- Key Vault;
- Log Analytics Workspace and Application Insights;
- user-assigned managed identities;
- GitHub OIDC Entra application and service principal;
- foundational RBAC assignments;
- NAT Gateway and its public IP.

These resources preserve identity and networking continuity. Destroying them to save small amounts of cost creates operational risk and usually increases rebuild effort.

## Cost-bearing resources

Runtime resources should be reviewed when the environment is idle:

- PostgreSQL Flexible Server;
- App Service plan;
- Linux Web App;
- Container Apps Environment and migration job executions;
- Front Door;
- private endpoint;
- workload diagnostics and alerts;
- self-hosted runner VM;
- temporary admin VMs or jump hosts.

The largest recurring costs are normally PostgreSQL compute and the App Service plan. Log ingestion can also become meaningful if diagnostics are noisy.

## PostgreSQL stop and start

PostgreSQL remains in the runtime layer because it is cost-bearing and can be stopped independently.

Stop:

```bash
az postgres flexible-server stop \
  --resource-group rg-devops-tracker-dev \
  --name psql-devops-tracker-29193-swn
```

Start:

```bash
az postgres flexible-server start \
  --resource-group rg-devops-tracker-dev \
  --name psql-devops-tracker-29193-swn
```

Operational notes:

- stopped PostgreSQL still incurs storage and backup cost;
- compute billing stops while the server is stopped;
- Azure automatically starts a stopped Flexible Server after 7 days;
- dependent applications may fail readiness checks while PostgreSQL is stopped;
- start operations are not instant, so allow for warm-up before testing the app.

## App Service cost behavior

Stopping a Web App does not stop App Service plan billing. The App Service plan is the billing component.

Use stop/start for short pauses:

```bash
az webapp stop \
  --resource-group rg-devops-tracker-dev \
  --name devops-tracker-29193

az webapp start \
  --resource-group rg-devops-tracker-dev \
  --name devops-tracker-29193
```

Use runtime destroy for meaningful cost removal:

```bash
cd infra/runtime
terraform destroy
```

Destroying runtime removes the App Service plan, Web App, PostgreSQL server, and other runtime resources while leaving foundation intact.

The staging slot shares the App Service plan. It does not create a separate plan, but it can add operational surface and logging volume.

## Front Door and runner cost behavior

Front Door Premium and the self-hosted runner VM are runtime resources. The runner is intentionally persistent so private validation can run without recreating registration state, but it should still be reviewed during long idle periods.

Runner outbound traffic uses the foundation NAT Gateway. NAT and its public IP remain deployed with foundation to preserve a stable outbound egress point.

## Container Apps migration cost behavior

The migration job runs on the Container Apps consumption workload profile. It should only consume compute while executions are active, but the Container Apps Environment and its diagnostics remain part of runtime.

Operational guidance:

- keep the job manually triggered;
- investigate failed or stuck executions promptly;
- avoid adding always-on Container Apps to this environment without revisiting cost expectations.

## Monitoring cost behavior

Log Analytics and Application Insights costs are driven mostly by ingestion and retention. They are foundation resources, but runtime diagnostics can drive their usage.

Cost controls:

- keep diagnostic categories intentional;
- reduce noisy application logs before raising retention;
- watch ingestion after enabling new Azure resources;
- tune alert queries to avoid unnecessary noise rather than disabling diagnostics entirely.

## Temporary VM cleanup

Private PostgreSQL administration may require a temporary VM or jump host in `snet-admin`. The permanent self-hosted runner is primarily for CI validation, not general administration.

Operational guidance:

- create temporary admin hosts only when needed;
- use small SKUs;
- restrict access with just-in-time or narrow network rules;
- delete the VM, public IP, NIC, and disks after use;
- avoid leaving admin hosts running as an accidental cost source.

## Recommended idle strategies

Short idle period:

- stop PostgreSQL;
- stop Web App if no traffic is needed;
- keep runtime Terraform state.

Long idle period:

- destroy `infra/runtime`;
- keep `infra/foundation`;
- keep GitHub OIDC and managed identities intact.

Full teardown:

- destroy runtime first;
- only destroy foundation when intentionally retiring the project;
- expect identity recreation to require PostgreSQL principal recreation and GitHub secret updates.
