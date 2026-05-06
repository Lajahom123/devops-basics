# DevOps tracker

Small Express API used to learn Azure DevOps, containers, CI/CD, Terraform, and database-backed services. Deployments are stored in PostgreSQL when `DATABASE_URL` is configured; otherwise the app falls back to in-memory storage for lightweight local tests.

## Prerequisites

- Node.js 20 or newer (LTS recommended)
- npm
- Docker and Docker Compose (optional, for container run)

## Local run

Clone the repository and install dependencies:

```bash
git clone git@github.com:Lajahom123/devops-basics.git
cd devops-tracker
npm install
```

Start the server:

```bash
npm run dev
```

For a one-shot run without file watching:

```bash
npm start
```

### Environment variables

| Variable       | Default        | Purpose                          |
| -------------- | -------------- | -------------------------------- |
| `PORT`         | `3000`         | HTTP port                        |
| `APP_VERSION`  | `0.0.0`        | Value returned by `GET /version` |
| `NODE_ENV`     | `development`  | Shown as `environment` on `/version` |
| `DATABASE_URL` | unset          | PostgreSQL connection string     |
| `DATABASE_SSL` | `false`        | Set to `true` for SSL DB connections, such as Azure PostgreSQL |
| `DATABASE_SSL_REJECT_UNAUTHORIZED` | `true` | Keep TLS certificate validation enabled |

Example:

```bash
PORT=8080 APP_VERSION=1.2.3 NODE_ENV=development npm run dev
```

The API listens on `http://localhost:<PORT>` (default `http://localhost:3000`).

Without `DATABASE_URL`, the app uses in-memory storage. This keeps `npm test` simple, but container runs should use PostgreSQL.

## Docker Compose with PostgreSQL

Build and start the full local stack:

```bash
docker compose up --build
```

Run in the background:

```bash
docker compose up --build -d
```

Stop:

```bash
docker compose down
```

Stop and remove the local database volume:

```bash
docker compose down -v
```

Compose starts:

- `app`: Express API on `http://localhost:3000`
- `db`: PostgreSQL 16 on `localhost:5432`

The app automatically creates the `deployments` table on startup. Local Compose uses this connection string:

```text
postgres://devops:devops_password@db:5432/devops_tracker
```

Or build and run the image directly:

```bash
docker build -t devops-tracker .
docker run --rm -p 3000:3000 \
  -e APP_VERSION=1.0.0 \
  -e NODE_ENV=production \
  -e DATABASE_URL=postgres://devops:devops_password@host.docker.internal:5432/devops_tracker \
  devops-tracker
```

Compose already sets `PORT`, `APP_VERSION`, `NODE_ENV`, `DATABASE_URL`, and `DATABASE_SSL` in `docker-compose.yml`; adjust there or override with `-e` when using `docker run`.

## API examples

Replace the base URL if you use a different host or port.

**Health**

```bash
curl -s http://localhost:3000/health
```

When PostgreSQL is configured and reachable, `database.status` is `ok`.

**Version**

```bash
curl -s http://localhost:3000/version
```

**Record a deployment**

```bash
curl -s -X POST http://localhost:3000/deployments \
  -H "Content-Type: application/json" \
  -d '{"service":"api","version":"2.1.0","environment":"staging"}'
```

**List deployments**

```bash
curl -s http://localhost:3000/deployments
```

**Get one deployment**

Use an `id` returned by `POST /deployments`.

```bash
curl -s http://localhost:3000/deployments/<deployment-id>
```

**Deployment stats**

```bash
curl -s http://localhost:3000/deployments/stats
```

Invalid `POST /deployments` bodies (missing or empty `service`, `version`, or `environment`) receive `400` with a JSON error message.

## Azure database notes

Terraform configures the cloud path with private database networking:

- Azure App Service uses regional VNet integration.
- Azure PostgreSQL Flexible Server is deployed into a delegated private subnet.
- PostgreSQL public network access is disabled.
- A private DNS zone resolves the PostgreSQL hostname inside the VNet.
- The database requires secure transport.
- `DATABASE_URL` is stored in Azure Key Vault and referenced from App Service.
- `DATABASE_SSL=true` and `DATABASE_SSL_REJECT_UNAUTHORIZED=true` are set on App Service.

Keep the same API container image and swap only the database connection settings when moving from local Compose to Azure. Do not commit real database passwords or connection strings.

The private networking setup requires an App Service plan tier that supports VNet integration, such as `B1` or higher.

## Repository layout

```
src/server.js          # Express app and routes
src/database.js        # PostgreSQL persistence with in-memory fallback
package.json           # Dependencies and npm scripts
Dockerfile             # Production-oriented Node image
docker-compose.yml     # Local app + PostgreSQL container stack
.github/workflows/     # GitHub Actions (CI/CD added in a later phase)
infra/                 # Terraform and related infra (later phase)
```

## Architecture (high level)

- **Runtime:** Node.js with Express; JSON request bodies for `POST /deployments`.
- **State:** PostgreSQL via `pg` when `DATABASE_URL` is set; in-memory fallback otherwise.
- **Config:** `PORT`, `APP_VERSION`, `NODE_ENV`, `DATABASE_URL`, and `DATABASE_SSL`; no secrets in the repo.

## Troubleshooting

- **Port already in use:** Set `PORT` to a free port, or stop the other process using 3000.
- **Docker: cannot connect to daemon:** Start Docker Desktop (or your container engine) and retry `docker compose up --build`.
- **Database health is degraded:** Check `docker compose ps`, confirm the `db` service is healthy, and verify `DATABASE_URL`.
- **Empty deployment list after `docker compose down -v`:** Expected; `-v` deletes the PostgreSQL volume.
