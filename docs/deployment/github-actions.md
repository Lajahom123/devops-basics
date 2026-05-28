# GitHub Actions deployment

GitHub Actions deploys without Azure client secrets, ACR admin credentials, or Web App publish profiles. Azure authentication uses GitHub OIDC federation with Microsoft Entra ID, and runner registration is GitHub App based.

- Environment: `dev`
- Deployment strategy: staging slot swap

The staging slot is not a separate environment. It is a deployment slot used to validate a release candidate before swapping it into production.

## Identity model

The foundation layer creates the Entra applications, service principals, and federated credentials used by GitHub Actions. Repository secrets hold identifiers, not Azure passwords:

```text
AZURE_DEPLOY_CLIENT_ID
AZURE_DEV_OPERATOR_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
FRONT_DOOR_URL
```

GitHub-hosted runners use OIDC for Azure API operations. The self-hosted runner uses GitHub App based registration and is used for private validation, not as the main deployment identity.

## Workflow stages

The main deployment workflow is intentionally split by responsibility:

- Build/push: build the application image and push immutable/latest tags to ACR.
- Migrations: build the Flyway image, update the Container Apps Job, and run migrations before app promotion.
- Staging deployment: update and restart the staging slot with the new image.
- Private validation: run health/version checks from the VNet runner against the staging private endpoint.
- Slot swap: swap staging into production from a GitHub-hosted runner through Azure APIs.
- Production validation: run health/version checks from the VNet runner against the production private endpoint and validate Front Door.

The private validation stages target runners with self-hosted VNet labels. The runner exists so validation can exercise private DNS and private endpoint routing instead of relying on public App Service access.

## Runner architecture

The runtime layer creates a persistent Ubuntu VM runner:

- no public IP;
- dedicated `snet-github-runner` subnet;
- user-assigned managed identity;
- Key Vault access for GitHub App registration material;
- persistent GitHub Actions runner service;
- labels for private/VNet workload targeting.

Runner outbound traffic uses the NAT Gateway associated with its subnet. NAT provides a centralized outbound IP, but it is not a firewall or inbound access mechanism.

## Private endpoint validation

Runtime creates private endpoints for:

- production App Service, subresource `sites`;
- staging slot, subresource `sites-staging`.

Both use the shared App Service private DNS zone `privatelink.azurewebsites.net`. Validation checks should run from inside the VNet or another connected private network.

## Rollback

Rollback is modeled as a slot swap through `.github/workflows/rollback-production.yml`. It uses OIDC to perform the Azure operation and then validates production. Because rollback is slot based, staging must still hold the previously known-good production version for rollback to be meaningful.
