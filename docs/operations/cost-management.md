# Cost management

The project is structured so foundational infrastructure can remain deployed while runtime compute can be stopped or destroyed.

## Low or minimal cost resources

Foundation resources are intended to stay deployed:

- resource group;
- VNet;
- subnets;
- private DNS zone and VNet link;
- user-assigned managed identity;
- GitHub OIDC Entra application and service principal;
- foundational RBAC assignments.

These resources preserve identity and networking continuity. Destroying them to save small amounts of cost creates operational risk and usually increases rebuild effort.

## Cost-bearing resources

Runtime resources should be reviewed when the environment is idle:

- PostgreSQL Flexible Server;
- App Service plan;
- Linux Web App;
- Azure Container Registry;
- Key Vault operations and stored secrets;
- temporary admin VMs or jump hosts.

The largest recurring costs are normally PostgreSQL compute and the App Service plan.

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

## Temporary VM cleanup

Private PostgreSQL administration may require a temporary VM or jump host in `snet-admin`. These resources are not part of the permanent foundation unless explicitly added later.

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
