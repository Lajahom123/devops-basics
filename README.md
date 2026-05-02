# DevOps tracker

Small Express API used to learn Azure DevOps, containers, CI/CD, and Terraform. Deployments are stored in memory for now.

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

Example:

```bash
PORT=8080 APP_VERSION=1.2.3 NODE_ENV=development npm run dev
```

The API listens on `http://localhost:<PORT>` (default `http://localhost:3000`).

## Docker run

Build and start with Compose (maps host port 3000 to the app):

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

Or build and run the image directly:

```bash
docker build -t devops-tracker .
docker run --rm -p 3000:3000 \
  -e APP_VERSION=1.0.0 \
  -e NODE_ENV=production \
  devops-tracker
```

Compose already sets `PORT`, `APP_VERSION`, and `NODE_ENV` in `docker-compose.yml`; adjust there or override with `-e` when using `docker run`.

## API examples

Replace the base URL if you use a different host or port.

**Health**

```bash
curl -s http://localhost:3000/health
```

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

Invalid `POST /deployments` bodies (missing or empty `service`, `version`, or `environment`) receive `400` with a JSON error message.

## Repository layout

```
src/server.js          # Express app
package.json           # Dependencies and npm scripts
Dockerfile             # Production-oriented Node image
docker-compose.yml     # Local container stack
.github/workflows/     # GitHub Actions (CI/CD added in a later phase)
infra/                 # Terraform and related infra (later phase)
```

## Architecture (high level)

- **Runtime:** Node.js with Express; JSON request bodies for `POST /deployments`.
- **State:** In-memory array (resets when the process restarts).
- **Config:** `PORT`, `APP_VERSION`, and `NODE_ENV` only; no secrets in the repo.

## Troubleshooting

- **Port already in use:** Set `PORT` to a free port, or stop the other process using 3000.
- **Docker: cannot connect to daemon:** Start Docker Desktop (or your container engine) and retry `docker compose up --build`.
- **Empty deployment list after restart:** Expected; storage is in-memory until a database phase is added.
