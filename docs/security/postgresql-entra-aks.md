# PostgreSQL Entra authentication on AKS (runtime-aks)

This document describes how the devops-tracker API authenticates to Azure Database for PostgreSQL Flexible Server when deployed on AKS through the `runtime-aks` layer.

## End-to-end authentication flow

```text
AKS Pod (devops-tracker-api)
  ↓
AKS Workload Identity
  (ServiceAccount annotation + pod label)
  ↓
Application Managed Identity (id-devops-tracker-dev-aks-workload)
  ↓
Azure Identity SDK (DefaultAzureCredential)
  ↓
Microsoft Entra access token
  (scope: https://ossrdbms-aad.database.windows.net/.default)
  ↓
Azure Database for PostgreSQL Flexible Server
  (pgaadauth validates token, maps to PostgreSQL role)
```

The PostgreSQL roles for managed identities are created by the one-time bootstrap Job in
`helm/jobs/devops-tracker-jobs` using `pgaadauth_create_principal`. Application grants
come from `grant-app-permissions.sql`; migration grants come from `grant-migration-permissions.sql`.

## Why every Entra managed identity must be bootstrapped

Microsoft Entra authentication to Azure Database for PostgreSQL is a two-step trust chain:

1. **Entra validates the token** — the managed identity proves itself to Microsoft Entra and
   receives an access token for scope `https://ossrdbms-aad.database.windows.net/.default`.
2. **PostgreSQL maps the token to a local role** — the `pgaadauth` extension checks that a
   PostgreSQL role exists whose name matches the managed identity display name.

Creating the managed identity in Azure (and wiring AKS Workload Identity) satisfies step 1
only. Until `pgaadauth_create_principal` creates the matching PostgreSQL role, PostgreSQL
has no local principal to authenticate the token against. The server then rejects the
connection with `password authentication failed for user "<identity-name>"` even though
Workload Identity and token acquisition succeeded.

Each managed identity that connects to PostgreSQL therefore needs a one-time bootstrap
entry in `bootstrap.principals`:

| Identity | PostgreSQL role | Grant profile |
|---|---|---|
| Application workload | `id-devops-tracker-dev-aks-workload` | `app` (DML) |
| Migration job | `id-devops-tracker-dev-migration-job` | `migration` (DDL for Flyway) |

The bootstrap Job itself runs as the **bootstrap** managed identity (PostgreSQL admin
group member). It does not use the target identities' tokens — it creates their PostgreSQL
roles and applies the appropriate grants.

## Why database passwords are no longer required

Production deployments authenticate through Microsoft Entra instead of a static PostgreSQL password:

- **No long-lived application secret** — the app never stores or rotates a PostgreSQL password.
- **Identity-aligned access** — database access is tied to the same managed identity used for Workload Identity and Azure RBAC.
- **Clear revocation path** — disable the identity or remove the PostgreSQL role instead of rotating a shared password.
- **Reduced secret sprawl** — no application database password in Key Vault, Helm values, Kubernetes Secrets, or Terraform state.

The PostgreSQL server administrator password remains in Terraform for bootstrap operations (migrations, principal creation). It is not used by the application runtime.

## Application configuration

| Variable | Purpose |
|---|---|
| `POSTGRES_AUTH_MODE` | `entra` (production default) or `password` (local development only) |
| `POSTGRES_HOST` | PostgreSQL server FQDN |
| `POSTGRES_PORT` | Port (default `5432`) |
| `POSTGRES_DB` | Database name |
| `POSTGRES_USER` | PostgreSQL role name (managed identity name for Entra mode) |
| `APP_CLIENT_ID` | User-assigned managed identity client ID for `DefaultAzureCredential` |
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID (also injected by Workload Identity webhook) |
| `DATABASE_SSL` | `"true"` for Azure PostgreSQL |
| `DATABASE_SSL_REJECT_UNAUTHORIZED` | `"true"` in production |

`POSTGRES_PASSWORD` is not set in production. It is only used when `POSTGRES_AUTH_MODE=password` for local development with a plain PostgreSQL instance.

### Helm values (production)

```yaml
postgres:
  enabled: true
  authMode: entra
  user: "id-devops-tracker-dev-aks-workload"

azure:
  tenantId: "<tenant-id>"
  clientId: "<aks-workload-identity-client-id>"
```

The GitHub Actions deploy workflow sets `azure.tenantId` and `azure.clientId` from repository variables at deploy time.

## How token acquisition works

1. The pod runs with the application ServiceAccount annotated with `azure.workload.identity/client-id` and the pod label `azure.workload.identity/use: "true"`.
2. AKS Workload Identity exchanges the federated token for Azure credentials.
3. `DefaultAzureCredential` (configured with `managedIdentityClientId` from `APP_CLIENT_ID`) requests a token for scope `https://ossrdbms-aad.database.windows.net/.default`.
4. The token is passed to `node-postgres` as the connection password. PostgreSQL validates it through the `pgaadauth` extension and maps it to the role named in `POSTGRES_USER`.

## Connection pooling and token refresh

Azure Entra access tokens for PostgreSQL are valid for approximately one hour. The `pg` Pool stores the token as the connection password at pool creation time; it does not refresh credentials automatically.

The application handles this by:

1. **Proactive refresh** — before the token expires (5-minute buffer), the pool is recreated with a fresh token. Existing connections on the old pool are drained asynchronously.
2. **Single-flight refresh** — concurrent requests share one refresh operation to avoid stampeding the identity endpoint.

This is production-safe because:

- new connections always receive a valid token;
- in-flight queries on the old pool complete before it is closed;
- the refresh cycle repeats for the lifetime of the pod without manual intervention.

## Why this approach is preferable for production

| Aspect | Password auth | Entra auth |
|---|---|---|
| Credential lifetime | Long-lived, manual rotation | Short-lived token (~1 hour), automatic refresh |
| Secret storage | Key Vault / K8s Secret / env var | None for the application |
| Revocation | Rotate password, update all consumers | Disable identity or remove PostgreSQL role |
| Audit alignment | Database login only | Entra sign-in logs + PostgreSQL auth |
| Least privilege | Shared password risk | Identity-scoped, role-granted permissions |

## Workload Identity configuration

The API pod uses AKS Workload Identity exclusively:

- ServiceAccount annotation `azure.workload.identity/client-id` → application managed identity client ID
- Pod label `azure.workload.identity/use: "true"`
- Federated credential: `system:serviceaccount:devops-tracker:devops-tracker-api`
- No pod-managed identity, no legacy aad-pod-identity

Key Vault CSI uses the same application identity client ID for secret mounts (Application Insights connection string only — no database credentials).

## Database schema migrations

Flyway migrations run as a one-shot Kubernetes Job (`devops-tracker-db-migrate`)
managed by the `devops-tracker-jobs` Helm release before each application deploy.
The Job uses Workload Identity to acquire a Microsoft Entra access token and passes
it to Flyway as the PostgreSQL password.

| Component | Value |
|---|---|
| Job name | `devops-tracker-db-migrate` |
| ServiceAccount | `devops-tracker-db-migrate` |
| Token scope | `https://ossrdbms-aad.database.windows.net/.default` |
| Migration image | `Dockerfile.migrations` (Flyway + Azure CLI) |
| SQL files | `migrations/V*.sql` |

### Identity model

| Workload | Managed identity | PostgreSQL role | Federated credential subject |
|---|---|---|---|
| Application | `id-devops-tracker-dev-aks-workload` | Same name as identity | `system:serviceaccount:devops-tracker:devops-tracker-api` |
| Flyway migrations | `id-devops-tracker-dev-migration-job` | Same name as identity | `system:serviceaccount:devops-tracker:devops-tracker-db-migrate` |

Each workload has its own managed identity and federated credential. The
identities are not shared.

- Migration identity: DDL via `grant-migration-permissions.sql`
- Application identity: DML only via `grant-app-permissions.sql`

Do not use the bootstrap identity or Entra admin group for routine migrations.

## Operational considerations

### Access token lifetime

Tokens typically expire after ~60 minutes. The application refreshes 5 minutes early. Monitor for authentication errors if the identity endpoint is unavailable near refresh time.

### Failure modes

| Symptom | Likely cause |
|---|---|
| `Failed to obtain PostgreSQL Entra access token` | Workload Identity not configured, wrong `APP_CLIENT_ID`, or federated credential mismatch |
| `password authentication failed` with valid token | PostgreSQL role not created or grants missing — re-run bootstrap |
| Intermittent auth errors after ~1 hour | Token refresh failure — check identity endpoint connectivity and logs |
| Connection timeout | NetworkPolicy, private DNS, or subnet routing — not an auth issue |

### Validation checklist

- [x] Application starts and `/health` returns `database.status: ok` with `authMode: entra`
- [x] CRUD operations succeed (`POST /deployments`, `GET /deployments`)
- [x] No authentication or token acquisition errors in pod logs
- [x] Pool survives beyond one token lifetime
- [x] No `POSTGRES_PASSWORD` in Key Vault, Helm, Kubernetes Secrets, or application env
