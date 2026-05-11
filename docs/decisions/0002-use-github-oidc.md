# Use GitHub OIDC

# Context

The deployment workflow needs Azure access to push images, update App Service, and potentially run Terraform. Static Azure client secrets, ACR admin passwords, and Web App publish profiles create long-lived credentials in GitHub.

# Decision

Use GitHub Actions OIDC federation with Microsoft Entra ID. Manage the Entra application, service principal, and federated credential in `infra/foundation`.

# Consequences

Benefits:

- no Azure client secret is stored in GitHub;
- tokens are short-lived;
- trust is scoped to repository and branch through the federated credential subject;
- Azure access is controlled through RBAC;
- bootstrap identity can survive application infrastructure recreation.

Drawbacks and operational impact:

- bootstrap must be applied before infra and deployment workflows work;
- branch names in the federated credential must match workflow branches;
- troubleshooting requires understanding GitHub OIDC, Entra federation, and Azure RBAC;
- accidental bootstrap destroy breaks deployments until identity is recreated or imported.
