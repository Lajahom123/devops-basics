# DevOps tracker

## Goal
Build one evolving Azure DevOps learning project.

---

## Stack
- Node.js + Express
- Docker + docker compose
- Azure App Service
- Azure Container Registry
- GitHub Actions
- Terraform  
- Later: AKS, monitoring, database

---

## Phase 1: Local API
Create repo `devops-tracker`.

### Endpoints
- `GET /health` → `{status, timestamp}`
- `GET /version` → `{version, environment}`
- `POST /deployments` → accepts `service`, `version`, `environment`
- `GET /deployments` → returns stored deployments

### Setup
- Start with in-memory array
- Use env vars: `PORT`, `APP_VERSION`, `NODE_ENV`
- Add npm scripts: `start`, `dev`

### Verify
- Test endpoints with `curl`

---

## Phase 2: Docker
- Add `Dockerfile` (base: `node:lts-alpine`)
- Add `.dockerignore`
- Build image locally
- Run container with mapped port
- Add `docker-compose.yml`

### Verify
- All endpoints work inside container

---

## Phase 3: Git
- Create GitHub repo
- Add `README.md`:
  - local run
  - Docker run
  - API examples

### Structure
src/server.js
package.json
Dockerfile
docker-compose.yml
.github/workflows/
infra/


---

## Phase 4: First Azure deployment
- Create resource group
- Create Linux App Service plan
- Create Web App
- Deploy from zip or GitHub

### Verify
- Public URL works
- Check logs via Azure CLI

### Output
- Document deployment steps

---

## Phase 5: CI/CD
- Create GitHub Actions workflow

### On push to main
- install dependencies
- run tests (if present)
- deploy to Azure App Service

### Setup
- Use GitHub secrets for Azure credentials

### Verify
- Automatic deployment works

---

## Phase 6: Container registry
- Create Azure Container Registry

### Update pipeline
- build Docker image
- tag with commit SHA
- push to ACR
- deploy container to App Service

### Verify
- `/version` reflects deployed version

---

## Phase 7: Terraform
- Create `infra/terraform`

### Provision
- resource group
- App Service plan
- Web App
- ACR
- basic storage/logging if needed

### Practices
- use variables (env, region)
- add remote state later (Azure Storage)

### Goal
- full infra reproducible from code

---

## Phase 8: Database
- Replace in-memory storage

### Steps
- start with SQLite locally
- move to Azure PostgreSQL or Azure SQL

### Setup
- use env vars for DB config
- keep secrets outside code

### Update
- health endpoint includes DB check

---

## Phase 9: Monitoring
- Enable Azure Monitor / Application Insights

### Add
- request logging
- error logging
- basic alerts (downtime, errors)

### Output
- document how to inspect logs and metrics

---

## Phase 10: AKS
- Create AKS cluster
- Push image to ACR

### Kubernetes manifests
- Deployment
- Service
- Ingress
- ConfigMap
- Secret
- Health probes

### Verify
- deployment works
- scaling works
- rollout works

### Later
- move AKS infra to Terraform

---

## Learning rule
Do not copy blindly.

For every phase:
- implement it
- change one thing
- break one thing
- fix it
- document what failed and how it was fixed

---

## Success criteria
- Public app is running
- App is containerized
- Automatic deployment from GitHub
- Infrastructure reproducible with Terraform
- Logs and health checks work
- README explains:
  - architecture
  - setup
  - deployment
  - troubleshooting