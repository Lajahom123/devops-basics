# DevOps tracker

DevOps tracker is a small Express API used as a working system for practicing production-style Azure and DevOps patterns. The application records deployment events and exposes simple read endpoints, but the main engineering value of the repository is the surrounding platform: Terraform-managed Azure infrastructure, container delivery, private database networking, GitHub Actions OIDC, and managed identities.

The project is intentionally small at the application layer so infrastructure and operational decisions remain visible. It is not a product template; it is a focused environment for learning how production Azure systems are usually assembled and reasoned about.

## Architecture overview

The cloud architecture centers on an Azure Linux Web App running a container image from Azure Container Registry. The Web App is integrated with a VNet for outbound private access to Azure Database for PostgreSQL Flexible Server. PostgreSQL is deployed without public network access and is reachable through a delegated subnet plus a private DNS zone.

Identity is split by responsibility:

- GitHub Actions authenticates to Azure with OIDC through a long-lived bootstrap identity.
- GitHub Actions receives Azure RBAC for image push and deployment operations.
- The Web App uses a user-assigned managed identity to pull images from ACR.
- The PostgreSQL production authentication target is managed identity to Entra token to PostgreSQL role, avoiding application-owned database passwords.

Terraform is split into separate lifecycle roots:

- `infra/foundation`: persistent resource group, networking, private DNS, managed identities, and GitHub Actions OIDC identity.
- `infra/runtime`: cost-bearing application resources such as ACR, App Service, PostgreSQL, Key Vault runtime settings, and runtime RBAC.

## High-level deployment flow

```text
Developer push
  -> GitHub Actions
  -> Azure OIDC authentication
  -> Terraform infrastructure changes
  -> Docker image build
  -> Image push to ACR
  -> Web App container image update
  -> Web App pulls image using managed identity
  -> Web App connects privately to PostgreSQL
  -> Production target: Web App authenticates to PostgreSQL using an Entra token
```

The current workflow uses `azure/login` with OIDC and `az acr login`; it does not use ACR admin credentials or Web App publish profiles.

## Security overview

The repository is structured around removing long-lived credentials from deployment and runtime paths.

- GitHub does not store Azure client secrets, ACR passwords, or publish profiles.
- ACR admin credentials are disabled.
- PostgreSQL is private-only and is not routable from the public internet.
- App Service reaches PostgreSQL through VNet integration and private DNS.
- The current transitional database connection string is stored in Key Vault, not directly in App Service settings.
- The production authentication direction is managed identity based database access, where the app obtains an Entra token and PostgreSQL maps that identity to a database role.

Terraform state can still contain sensitive generated values. Local state files are ignored, and a remote state backend is the expected next hardening step before shared operation.

## Local application development

The API can run without PostgreSQL and falls back to in-memory storage. For container-based local testing, Docker Compose starts both the app and PostgreSQL:

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

## Documentation

- [Architecture overview](docs/architecture/overview.md)
- [Infrastructure lifecycle](docs/architecture/infrastructure-lifecycle.md)
- [Private networking](docs/networking/private-networking.md)
- [PostgreSQL managed identity authentication](docs/security/postgresql-managed-identity.md)
- [GitHub Actions deployment](docs/deployment/github-actions.md)
- [Operations and lessons learned](docs/operations/lessons-learned.md)
- [Cost management](docs/operations/cost-management.md)

Architecture decisions:

- [ADR 0001: Use Terraform](docs/decisions/0001-use-terraform.md)
- [ADR 0002: Use GitHub OIDC](docs/decisions/0002-use-github-oidc.md)
- [ADR 0003: Use private PostgreSQL networking](docs/decisions/0003-private-postgresql.md)
- [ADR 0004: Use managed identity for database authentication](docs/decisions/0004-managed-identity-db-auth.md)
