# Private networking

The current architecture uses private networking for database access, App Service validation, and Front Door origin access. Public user traffic enters through Front Door; direct public access to App Service production and staging is disabled.

## VNet purpose

The VNet is the private network boundary for workload egress, private endpoints, migration execution, and CI validation.

Current subnet layout:

- `snet-web-egress`: delegated for App Service regional VNet integration.
- `snet-postgres`: delegated for PostgreSQL Flexible Server.
- `snet-admin`: reserved for private administration patterns.
- `snet-container-apps`: delegated to the Container Apps Environment.
- `snet-private-endpoints`: production and staging App Service private endpoints.
- `snet-github-runner`: self-hosted GitHub runner VM.

## App Service paths

App Service VNet integration is outbound. It lets the production app and staging slot reach private VNet resources such as PostgreSQL.

Private endpoints are inbound. They let VNet resources reach App Service privately. The runtime layer creates:

- production App Service private endpoint;
- staging slot private endpoint;
- private DNS zone group using `privatelink.azurewebsites.net`.

Front Door is the public entry point. It reaches the production App Service through Private Link, so public clients do not need direct access to the App Service hostname.

## Traffic flows

User traffic:

```text
User
  -> Front Door
  -> Private Link
  -> App Service
```

CI validation traffic:

```text
GitHub Actions
  -> self-hosted runner inside VNet
  -> private endpoint
  -> App Service
```

Runner outbound traffic:

```text
runner subnet
  -> NAT Gateway
  -> internet services
```

NAT Gateway gives the runner subnet a stable outbound path and public IP. It is not an inbound path and does not enforce security policy.

## PostgreSQL

PostgreSQL Flexible Server is deployed with private access and public network access disabled. Clients need both private network reachability and valid database authentication.

Private DNS is required for the database hostname to resolve correctly inside the VNet:

- PostgreSQL: `private.postgres.database.azure.com`.
- App Service private endpoints: `privatelink.azurewebsites.net`.

## Self-hosted runner

The runner is an Ubuntu VM with no public IP in `snet-github-runner`. It uses a managed identity to read GitHub App registration material from Key Vault and registers as a persistent GitHub Actions runner.

The runner exists primarily to validate private connectivity:

- production App Service private endpoint;
- staging slot private endpoint;
- Front Door endpoint from inside the VNet;
- NAT outbound IP.

Deployment operations still use GitHub-hosted runners and OIDC authentication where private network placement is not required.

## Operational tradeoffs

Private networking improves exposure control, but it changes operations:

- local machines usually cannot reach private PostgreSQL or App Service private endpoints;
- DNS checks should run from inside the VNet or a connected private network;
- database administration needs a private path such as the runner, an admin VM, VPN, or an approved job;
- failed health checks may be DNS, route, private endpoint, identity, or application failures.
