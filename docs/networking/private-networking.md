# Private networking

The PostgreSQL deployment is intentionally private-only. The goal is to make database access depend on Azure network placement and identity rather than public firewall exceptions.

## VNet purpose

The VNet is the private network boundary for application egress and database access. It contains separate subnets for different Azure service integrations:

- `snet-web-egress`: delegated for App Service regional VNet integration.
- `snet-postgres`: delegated for Azure Database for PostgreSQL Flexible Server.
- `snet-admin`: reserved for private operational access patterns such as temporary jump hosts.
- `snet-container-apps`: delegated to the Container Apps Environment that runs the migration job.
- `snet-private-endpoints`: reserved for private endpoints such as the Web App private endpoint.

This separation keeps App Service egress integration and PostgreSQL placement independent. It also mirrors production network design, where subnet delegation, routing, and policy are managed per service role.

## PostgreSQL delegated subnet

PostgreSQL Flexible Server uses VNet injection when deployed with private access. The delegated subnet gives the PostgreSQL service permission to attach into the VNet and allocate private addresses.

The PostgreSQL server is configured with:

- public network access disabled;
- a private DNS zone;
- a private delegated subnet;
- secure transport required.

No public PostgreSQL endpoint is expected to be reachable from a laptop or arbitrary internet client.

## App Service VNet integration

App Service is not deployed directly into the VNet. Regional VNet integration attaches App Service outbound traffic to a delegated subnet. This is sufficient for the app to call private resources such as PostgreSQL, provided DNS and routing are correct.

The Web App also enables route-all behavior so outbound traffic follows the integrated network path. This is important when private resources depend on VNet-local DNS and private routing.

## Container Apps migration networking

The migration job runs in an Azure Container Apps Environment attached to `snet-container-apps`. This gives the Flyway container private network reachability to PostgreSQL while keeping migrations separate from the Web App startup path.

The job image is pulled from ACR with a migration-job managed identity. The job currently connects with the PostgreSQL administrator credential for bootstrap and migration execution. That credential remains sensitive and should be treated as transitional operational access.

## Web App private endpoint

The runtime layer creates a private endpoint for the Web App in `snet-private-endpoints` and links it with the `privatelink.azurewebsites.net` private DNS zone. This provides a private inbound path for clients located inside the VNet or connected private networks.

The public App Service hostname can still be useful for deployment slot verification unless public inbound restrictions are tightened later. If the project moves to private-only inbound access, GitHub-hosted runners will need a private verification path or the workflow health checks will need to run from inside the network.

## Private DNS

Private DNS is required because private resource hostnames must resolve to private addresses inside the VNet.

The PostgreSQL hostname resolves to a private IP only inside the linked VNet. The Web App private endpoint also depends on the linked `privatelink.azurewebsites.net` zone. External clients cannot resolve or route to those private addresses unless they are connected to the private network.

This has several consequences:

- The Web App can resolve the database hostname after VNet integration and private DNS linking.
- The migration job can resolve the database hostname from the Container Apps Environment.
- Private Web App clients can resolve the Web App private endpoint hostname through the Web App private DNS zone.
- A local laptop typically cannot resolve the hostname to the private address.
- Even if a laptop learns the private IP, it cannot route to it without network connectivity into the VNet.
- Operational database administration must happen from inside the network boundary or through an approved private access path.

## Why a jump host may be needed

Private networking complicates ad hoc administration. Tasks such as creating PostgreSQL principals, checking extensions, or running `psql` commands may require a host with network reachability to the database.

Common patterns:

- temporary Azure VM in the VNet;
- Azure Bastion plus a VM;
- VPN or ExpressRoute into the VNet;
- self-hosted CI runner inside the VNet;
- controlled admin container/job running inside the network.

A temporary VM or jump host is often the simplest early-project option because it proves DNS and route behavior without opening PostgreSQL publicly.

## Security benefits

Private PostgreSQL access reduces exposure:

- no public database endpoint;
- no IP allowlist drift from developer laptops;
- fewer emergency firewall exceptions;
- database access requires both network position and valid authentication;
- credential leaks are less useful without private network reachability.

This does not remove the need for strong authentication, least privilege roles, auditing, backup strategy, and secure Terraform state.

## Operational tradeoffs

Private networking is safer but less convenient:

- local debugging cannot connect directly to cloud PostgreSQL;
- DNS failures look like application connectivity failures;
- database administration requires a private access path;
- CI/CD systems need either Azure API access or network placement depending on the task;
- incident response runbooks need explicit commands for checking DNS, routes, and identity.

This tradeoff is acceptable for production-style systems because routine access should be mediated by deployment pipelines, controlled admin paths, and observability rather than direct public database access.
