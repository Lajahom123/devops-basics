# Use managed identity for database authentication

# Context

The initial database connection model uses a PostgreSQL username and password in a connection string. Even when stored in Key Vault, the application still depends on a long-lived credential and Terraform state can contain sensitive generated values.

# Decision

Move the production database authentication model to managed identity and Entra authentication. The Web App obtains an Entra token with its user-assigned managed identity and PostgreSQL maps that principal to a database role.

# Consequences

Benefits:

- removes application-owned database passwords;
- aligns runtime database access with Azure identity;
- enables clearer audit and revocation paths;
- reduces credential rotation burden.

Drawbacks and operational impact:

- application code must handle token acquisition and refresh;
- PostgreSQL principals and grants must be created explicitly;
- password authentication may remain temporarily enabled during migration;
- troubleshooting now spans identity, token acquisition, private networking, and PostgreSQL authorization.
