# Use Terraform

# Context

The project needs repeatable Azure infrastructure for App Service, ACR, PostgreSQL, networking, Key Vault, Container Apps migration jobs, monitoring, managed identities, and RBAC. Manual portal changes are difficult to review, reproduce, and reason about after cleanup or failure.

# Decision

Use Terraform for Azure infrastructure as code. Keep persistent foundation resources in `infra/foundation` and cost-bearing application resources in `infra/runtime`.

# Consequences

Benefits:

- infrastructure changes are reviewable;
- environments can be recreated consistently;
- Azure RBAC, private networking, and managed identities are visible in code;
- bootstrap state can survive normal infra teardown.

Drawbacks and operational impact:

- Terraform state can contain sensitive values and must be protected;
- provider behavior and Azure API constraints become part of the delivery workflow;
- database grants and private-network administration may still require tooling outside Terraform;
- separating bootstrap and infra adds process discipline but avoids destroying the deployment identity.
