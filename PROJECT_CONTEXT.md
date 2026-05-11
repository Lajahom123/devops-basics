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
  foundation/
  runtime/


---

## Phase 4: First Azure deployment

### Azure App Service deployment via GitHub Actions

#### Output
- Deployment is automated via GitHub Actions on push to `master`
- Azure App Service runs with Linux runtime (Node 20)
- Publish profile is stored as a GitHub secret and used for deployment
- SCM/Kudu publishing credentials must be enabled for publish profile deployments

#### Deployment steps

1. **Create resource group**
   ```bash
   az group create --name <resource-group> --location westeurope
   ```

2. **Create App Service plan**
   ```bash
   az appservice plan create \
     --name <app-service-plan> \
     --resource-group <resource-group> \
     --sku B1 \
     --is-linux
   ```

3. **Create web app**
   ```bash
   az webapp create \
     --resource-group <resource-group> \
     --plan <app-service-plan> \
     --name <app-name> \
     --runtime "NODE|20-lts"
   ```

4. **Enable SCM publishing credentials (if disabled)**
   ```bash
   az resource update \
     --resource-group <resource-group> \
     --name scm \
     --namespace Microsoft.Web \
     --resource-type basicPublishingCredentialsPolicies \
     --parent sites/<app-name> \
     --set properties.allow=true
   ```

5. **Generate publish profile**
   ```bash
   az webapp deployment list-publishing-profiles \
     --resource-group <resource-group> \
     --name <app-name> \
     --xml
   ```
   Copy the full XML output.

6. **Add publish profile to GitHub**  
   Repository → **Settings** → **Secrets and variables** → **Actions**  
   - Secret name: `AZURE_WEBAPP_PUBLISH_PROFILE`  
   - Paste the full XML.

7. **Configure GitHub Actions workflow**  
   `.github/workflows/deploy-app-service.yml` (see YAML in the project).

8. **Push code to GitHub**
   ```bash
   git add .
   git commit -m "Setup Azure deployment"
   git push
   ```

9. **Verify deployment**
   ```bash
   curl https://<app-name>.azurewebsites.net/health
   ```

#### Notes
- Deployment triggers on push to `master`
- Azure runs `npm start` from `package.json`
- Kudu (SCM) handles deployment internally

### Verify
- Public URL works
- Check logs via Azure CLI

### App URL
https://devops-tracker-29193.azurewebsites.net

### Verification
```bash
curl https://devops-tracker-29193.azurewebsites.net/health
```


---

## Phase 5: CI/CD
- Create GitHub Actions workflow

### On push to master
- install dependencies
- run tests (if present)
- deploy to Azure App Service

### Setup
- Use GitHub secrets for Azure credentials

### Verify
- Automatic deployment works

## Notes
- do not zip the file as a deployment step, let Azure do it

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

## Notes
- use managed identity
- make sure to use the right processor architecture linux/amd64

---

## Phase 7: Terraform
- Create `infra/foundation`
- Create `infra/runtime`
- Keep long-lived GitHub Actions OIDC identity, network, and managed identities in `infra/foundation`

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
