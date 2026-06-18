# DevOps tracker

DevOps tracker is a small Express API used to practice production-inspired Azure and DevOps patterns. The application records deployment events and exposes simple read endpoints, while the main learning surface is the platform around it: Terraform-managed Azure infrastructure, private networking, container delivery, GitHub Actions OIDC, managed identities, and deployment validation.

The target region is `swedencentral`. The current environment is `dev`; the deployment strategy is a staging slot swap. The staging slot is part of the same environment, not a separate environment.

## Architecture overview

The Azure architecture uses Front Door as the public entry point and Azure App Service as the container host. Direct public access to App Service is disabled. Front Door reaches the production App Service through Private Link, while private validation reaches production and staging through App Service private endpoints inside the VNet.

Terraform is split by lifecycle:

- `infra/foundation` owns shared, persistent infrastructure: networking foundations, VNet/subnets, ACR, Key Vault, Log Analytics/Application Insights, private DNS, identities, role assignments, and NAT Gateway.
- `infra/runtime` owns workload resources: App Service, staging slot, PostgreSQL Flexible Server, Front Door, private endpoints, Container Apps migration job, GitHub self-hosted runner VM, diagnostics, alerts, and workload RBAC.

Runtime consumes foundation outputs through `terraform_remote_state`. This keeps low/no cost identity and network resources stable while allowing cost-bearing workload resources to be recreated.

## Current implemented features

- Azure Linux App Service running a container image from ACR.
- Staging slot deployment with production slot swap.
- Front Door Premium with WAF and Private Link origin access.
- App Service public network access disabled for production and staging.
- Production and staging App Service private endpoints.
- Shared App Service private DNS zone: `privatelink.azurewebsites.net`.
- PostgreSQL Flexible Server on private networking with public access disabled.
- Container Apps Job for Flyway migrations before slot swap.
- GitHub OIDC for deployment authentication.
- GitHub self-hosted runner VM inside the VNet for private validation.
- NAT Gateway on the runner subnet for centralized outbound internet access.
- Log Analytics, Application Insights, diagnostics, and failed-request alerting.

## Deployment flow

The application workflow keeps deployment operations on GitHub-hosted runners where Azure API access is enough, then uses the VNet runner only for private endpoint validation.

```text
Build/push
  -> migrations
  -> staging deployment
  -> private staging validation
  -> slot swap
  -> private production validation
```

Deployment authentication uses GitHub OIDC and Azure RBAC. Runner registration is GitHub App based.

## Networking overview

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

App Service VNet integration gives App Service outbound access into the VNet. Private endpoints give VNet resources a private inbound path to App Service. NAT Gateway is outbound only; it centralizes egress IPs but does not enforce security policy.

## Local application development

The API can run without PostgreSQL and falls back to in-memory storage. For local testing:

```bash
npm install
npm test
docker compose up --build
```

Core endpoints:

- `GET /health`
- `GET /version`
- `POST /deployments`
- `GET /deployments`
- `GET /deployments/:id`
- `GET /deployments/stats`

## Next planned phase

The next major infrastructure phase is AKS. The existing App Service architecture remains useful as the production-inspired baseline for identity, networking, private ingress, migrations, and deployment validation.

## Documentation

- [Architecture overview](docs/architecture/overview.md)
- [Infrastructure lifecycle](docs/architecture/infrastructure-lifecycle.md)
- [Private networking](docs/networking/private-networking.md)
- [PostgreSQL managed identity authentication](docs/security/postgresql-managed-identity.md)
- [GitHub Actions deployment](docs/deployment/github-actions.md)
- [Migration job bootstrap](docs/migrations/migration-job-bootstrap.md)
- [Monitoring](docs/monitoring/monitoring.md)
- [Operations and lessons learned](docs/operations/lessons-learned.md)
- [Cost management](docs/operations/cost-management.md)
