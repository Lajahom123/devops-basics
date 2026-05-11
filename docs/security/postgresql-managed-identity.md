# PostgreSQL managed identity authentication

The database authentication model is moving from a static password in a connection string to managed identity backed by Microsoft Entra authentication.

The infrastructure already enables Entra authentication on Azure Database for PostgreSQL Flexible Server and assigns a user-managed identity to the Web App. The application still contains a transitional `DATABASE_URL` path. This document describes the production target and the operational steps required to complete the migration.

## Previous flow

```text
Application
  -> DATABASE_URL
  -> static PostgreSQL username/password
  -> PostgreSQL
```

This model is easy to bootstrap but has operational drawbacks:

- password rotation must be handled explicitly;
- secrets can appear in Terraform state;
- the app depends on a long-lived credential;
- access is harder to reason about through Azure identity and RBAC.

In this repository, the transitional connection string is stored in Key Vault and referenced from App Service, which is better than plain app settings but still not the final model.

## Target flow

```text
Application
  -> ManagedIdentityCredential
  -> Entra access token
  -> PostgreSQL TLS connection
  -> PostgreSQL role mapped to managed identity
```

The Web App obtains an access token for Azure PostgreSQL from the instance metadata service through its user-assigned managed identity. The token is passed to the PostgreSQL driver as the password. PostgreSQL validates the token through Entra integration and maps it to a database role.

## Application implementation shape

The Node.js implementation should use `ManagedIdentityCredential` from Azure Identity and pass the token into `pg`.

Representative shape:

```js
const { ManagedIdentityCredential } = require("@azure/identity");
const { Pool } = require("pg");

const credential = new ManagedIdentityCredential(process.env.AZURE_CLIENT_ID);
const scope = "https://ossrdbms-aad.database.windows.net/.default";

async function createPool() {
  const token = await credential.getToken(scope);

  return new Pool({
    host: process.env.POSTGRES_HOST,
    port: 5432,
    database: process.env.POSTGRES_DATABASE,
    user: process.env.POSTGRES_USER,
    password: token.token,
    ssl: { rejectUnauthorized: true },
  });
}
```

Long-running processes must account for token expiry. A pool created with a token as a static password can outlive the token used to create new connections. Production code should refresh tokens before creating new connections or use a connection factory/pool lifecycle that can rotate credentials.

## PostgreSQL principal mapping

Entra authentication on the server is necessary but not sufficient. PostgreSQL still needs a database principal that maps to the managed identity.

From a network location that can reach the private PostgreSQL endpoint, connect as the Entra administrator and enable/create the principal:

```sql
CREATE EXTENSION IF NOT EXISTS pgaadauth;

SELECT * FROM pgaadauth_create_principal(
  'id-devops-tracker-webapp',
  false,
  false
);
```

Then grant only the permissions the application needs:

```sql
GRANT CONNECT ON DATABASE devops_tracker TO "id-devops-tracker-webapp";
GRANT USAGE ON SCHEMA public TO "id-devops-tracker-webapp";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "id-devops-tracker-webapp";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "id-devops-tracker-webapp";
```

The exact role name depends on how the principal is created and displayed by PostgreSQL. Validate with:

```sql
\du
```

## Why password auth may remain temporarily enabled

The Terraform configuration currently enables both Entra authentication and password authentication. This is a pragmatic transition state.

Reasons to keep password auth temporarily:

- initial schema/bootstrap tasks may still use administrator credentials;
- the application code may still use `DATABASE_URL`;
- recovery access is useful while validating Entra principal creation;
- Terraform does not cleanly manage all PostgreSQL grants and role mappings over a private endpoint.

The production end state should disable password authentication once the app, migrations, and operational access paths work with Entra authentication.

## Operational implications

Managed identity authentication changes the failure modes:

- token acquisition can fail if the identity is not attached or the wrong client ID is used;
- PostgreSQL login can fail even with a valid token if the database role was not created;
- new connections can fail after token expiration if the pool does not refresh credentials;
- private DNS or VNet issues can look like authentication failures from the application perspective.

Operational checks should separate:

- network resolution and routing;
- token acquisition;
- PostgreSQL role mapping;
- table/schema grants;
- application connection pool behavior.
