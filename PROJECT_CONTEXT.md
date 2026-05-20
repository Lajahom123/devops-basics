# DevOps tracker

## Goal

Build one evolving Azure DevOps learning project that keeps the application small and makes production-style infrastructure, delivery, networking, identity, migration, and monitoring patterns visible.

## Current stack

- Node.js and Express
- Docker and Docker Compose for local development
- Azure App Service for the API container
- Azure App Service deployment slots for staging to production promotion
- Azure Container Registry with admin credentials disabled
- Azure Database for PostgreSQL Flexible Server with private networking
- Azure Container Apps Job for Flyway migrations
- Azure Key Vault for runtime secret storage and access control
- Azure Monitor, Log Analytics, Application Insights, diagnostics, and alerts
- GitHub Actions with Azure OIDC
- Terraform split into foundation and runtime roots

## Current architecture

`infra/foundation` is persistent and should survive normal cleanup. It owns the resource group lookup, VNet, subnets, PostgreSQL private DNS, Web App private DNS, Web App managed identity, migration job managed identity, GitHub Actions OIDC identity, and foundational RBAC.

`infra/runtime` is destroyable and cost-bearing. It owns ACR, App Service plan, Web App, staging slot, PostgreSQL Flexible Server, PostgreSQL database, Container Apps Environment, Flyway migration job, Key Vault, Log Analytics, Application Insights, diagnostics, alerts, Web App private endpoint, and runtime RBAC.

## Deployment flow

1. GitHub Actions authenticates to Azure with OIDC.
2. The workflow logs in to ACR through Azure CLI.
3. The application image is built and pushed with commit and `latest` tags.
4. The Flyway migration image is built and pushed with a commit tag.
5. The Container Apps migration job image is updated and executed.
6. The Web App staging slot image is updated.
7. Staging `/health` and `/version` are verified.
8. Staging is swapped into production.
9. Production `/health` and `/version` are verified.

## Important operating model

- Do not use publish profiles or ACR admin credentials.
- Keep `infra/foundation` deployed during ordinary cost-control cycles.
- Destroy `infra/runtime` when removing active cost for a longer idle period.
- Keep migrations outside Web App startup.
- Keep GitHub deployment identity, Web App runtime identity, and migration job identity separate.
- Treat PostgreSQL private DNS and VNet placement as part of the database access boundary.
- Treat PostgreSQL administrator password usage in the migration job as a bootstrap state to harden later.

## Future hardening ideas

- Move Terraform state fully to remote state with reviewable plan/apply controls.
- Narrow migration database privileges away from administrator credentials.
- Improve token refresh behavior for PostgreSQL managed identity connections.
- Decide whether Web App public inbound access should remain available or become private-only.
- Add deeper runbooks for alerts, rollback, and private database administration.
