# Use Container Apps Job for migrations

# Context

The application needs repeatable database migrations against a PostgreSQL server that is reachable only through private networking. Running migrations from a developer laptop or a public GitHub-hosted runner would require opening network access that the architecture is intentionally avoiding.

# Decision

Run Flyway migrations from an Azure Container Apps Job attached to the VNet through the Container Apps Environment. Build the migration image in GitHub Actions, push it to ACR, update the job image, and execute the job before the Web App staging slot is swapped into production.

# Consequences

Benefits:

- migrations run from inside the private network boundary;
- schema changes are separated from Web App startup;
- deployments fail before production slot swap if migrations fail;
- the migration image is versioned with the application deployment;
- the job can use a separate managed identity for ACR pull.

Drawbacks and operational impact:

- the first Terraform apply requires a bootstrap migration image because Container Apps Job creation needs a valid image;
- migration execution now depends on Container Apps Environment health and diagnostics;
- database credentials for migrations must be handled carefully;
- rollback remains slot based, so migrations should be backward compatible whenever possible.
