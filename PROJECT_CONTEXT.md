# DevOps tracker

## Goal

Build one evolving Azure DevOps learning project that keeps the application small and makes production-inspired infrastructure, delivery, networking, identity, migration, and monitoring patterns visible.

## Current stack

- Node.js and Express
- Docker and Docker Compose for local development
- Azure App Service for the API container
- Azure App Service deployment slots for staging to production promotion
- Azure Front Door Premium as the public entry point
- Azure Container Registry with admin credentials disabled
- Azure Database for PostgreSQL Flexible Server with private networking
- Azure Container Apps Job for Flyway migrations
- Azure Key Vault for secret storage and access control
- Azure Monitor, Log Analytics, Application Insights, diagnostics, and alerts
- GitHub Actions with Azure OIDC
- GitHub self-hosted runner VM for private network validation
- Terraform split into platform and runtime roots

## Current architecture

- Region: `swedencentral`
- Environment: `dev`
- Deployment strategy: staging slot swap

`infra/platform` is persistent and should survive normal cleanup. It owns shared infrastructure: resource group lookup, VNet, subnets, ACR, Key Vault, private DNS, Log Analytics, Application Insights, managed identities, GitHub OIDC identities, role assignments, and NAT Gateway.

`infra/runtime` is destroyable and cost-bearing. It owns workload resources: App Service, staging slot, PostgreSQL Flexible Server, Container Apps migration job, Front Door, production and staging private endpoints, GitHub runner VM, workload diagnostics, alerts, and workload RBAC.

Runtime consumes platform outputs through `terraform_remote_state`.

## Deployment flow

1. GitHub Actions authenticates to Azure with OIDC.
2. The workflow builds and pushes the application image.
3. The workflow builds and pushes the Flyway migration image.
4. The Container Apps migration job image is updated and executed.
5. The Web App staging slot image is updated.
6. Staging `/health` and `/version` are verified privately from the VNet runner.
7. Staging is swapped into production.
8. Production `/health` and `/version` are verified privately from the VNet runner.
9. Front Door is validated as the public entry point.

## Important operating model

- The staging slot is not a separate environment.
- Do not use publish profiles, ACR admin credentials, or Azure client secrets.
- Runner registration is GitHub App based.
- Keep `infra/platform` deployed during ordinary cost-control cycles.
- Destroy `infra/runtime` when removing active cost for a longer idle period.
- Keep migrations outside Web App startup.
- Keep GitHub deployment identity, Web App runtime identity, migration job identity, and runner identity separate.
- Treat PostgreSQL private DNS and VNet placement as part of the database access boundary.
- Treat PostgreSQL administrator password usage in the migration job as privileged bootstrap access to harden later.
- NAT Gateway centralizes runner outbound internet access but does not enforce security policy.

## Future hardening ideas

- Move migrations to narrower database privileges.
- Improve token refresh behavior for PostgreSQL managed identity connections.
- Add deeper runbooks for alerts, rollback, and private database administration.
- Revisit the App Service baseline during the planned AKS phase.
