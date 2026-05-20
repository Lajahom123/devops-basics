# Operations and lessons learned

This project surfaces several operational details that are easy to miss when a system is still small.

## Private DNS only resolves inside linked VNets

Private PostgreSQL is not just PostgreSQL with a firewall rule. The hostname is expected to resolve to a private IP from inside the linked VNet. A laptop outside the VNet cannot rely on the same DNS behavior and cannot route to the private address.

When connectivity fails, verify DNS first:

```bash
nslookup <postgres-server>.postgres.database.azure.com
```

Run that check from the Web App environment, an Azure VM in the VNet, or another approved private access path. Running it locally can produce misleading results.

## Terraform does not manage every PostgreSQL concern cleanly

Terraform is strong for Azure resource lifecycle, RBAC, and network topology. It is less clean for PostgreSQL database grants and Entra principal setup when the database is private-only.

Database role setup may require:

- a jump host or private runner;
- explicit `psql` execution;
- migration tooling that runs inside the private network;
- careful separation between infra provisioning and schema/database authorization.

The operational boundary is: Terraform creates the database service and identities; database-level grants may still need a database administration path.

## Managed identity auth still requires PostgreSQL principal creation

Entra authentication on PostgreSQL does not automatically grant application access. The managed identity must be represented as a PostgreSQL principal, and that role must receive schema/table permissions.

Missing role mapping and missing grants fail differently:

- no mapped principal: login fails;
- missing table grants: login succeeds, queries fail;
- expired token: new connections fail after previously working.

Runbooks should make those checks separate.

## Migrations should stay outside App Service startup

The current architecture runs Flyway migrations through a Container Apps Job before the Web App slot swap. That keeps schema changes out of process startup and makes deployment failures easier to understand.

Keep this separation as the project grows:

- migrations as a separate deployment step;
- idempotent migration tooling;
- readiness endpoints for dependency availability;
- liveness endpoints for process health.

An app that fails to start because the database is temporarily unavailable can trigger restart loops and obscure the underlying platform issue.

## Separate liveness and readiness

`/health` currently reports database state. That is useful for learning, but production systems usually separate:

- liveness: is the process alive and able to respond?
- readiness: can the instance serve traffic with its dependencies?

This distinction matters in App Service health checks and orchestrated environments. A transient database problem should not always imply the process is dead.

## Private networking complicates local administration

Private-only PostgreSQL improves security but removes convenient local access. That is the point, but it changes workflows.

Production-style options:

- private admin VM with just-in-time access;
- VPN into the VNet;
- self-hosted runner in the VNet;
- database migration job running inside Azure;
- approved break-glass path documented and audited.

Avoid restoring public database access just to make routine administration easier.

## Slot swaps improve deployment safety but need discipline

The deployment workflow updates the staging slot, verifies `/health` and `/version`, then swaps staging into production. This is safer than updating production directly, but it relies on the staging slot containing a meaningful release candidate.

Operational notes:

- keep sticky settings limited to values that truly differ per slot;
- verify that staging uses the same private dependencies as production;
- remember that rollback is another slot swap, so staging must still contain the previously good production version;
- make migration changes backward compatible when possible because schema changes happen before the app slot swap.

## Token based auth introduces refresh concerns

Managed identity database auth removes password rotation but introduces token lifecycle management. Entra tokens expire. Connection pools can hold connections across token boundaries, and new connections may need a fresh token.

Applications should:

- fetch tokens close to connection creation;
- avoid assuming a token can be reused indefinitely;
- reconnect gracefully;
- expose enough logs to distinguish token acquisition failure from database authorization failure.

## Bootstrap state should survive infra cleanup

The GitHub Actions OIDC identity is intentionally separated from the runtime infrastructure. Destroying runtime should not destroy the identity that deploys runtime. Otherwise the next deployment cannot authenticate without manual repair.

Normal cleanup should target `infra/runtime`, not `infra/foundation`.
