# GitHub Actions deployment

GitHub Actions deploys the application without static Azure credentials, ACR admin credentials, or Web App publish profiles. Authentication is based on GitHub OIDC federation with Microsoft Entra ID.

## Bootstrap identity

The OIDC identity is managed in `infra/foundation`. This layer creates:

- an Entra application;
- a service principal;
- a federated identity credential for the configured GitHub repository and branch.

The bootstrap layer is intentionally separate from the application infrastructure. It should not be destroyed during normal infra cleanup because the deployment pipeline depends on it.

After bootstrap apply, these outputs become GitHub repository secrets:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

The `github_actions_principal_id` output is passed into the infra layer so Terraform can assign Azure RBAC.

## Workflow authentication

The workflow grants the minimal GitHub token permissions required for OIDC:

```yaml
permissions:
  id-token: write
  contents: read
```

`azure/login` exchanges the GitHub OIDC token for Azure credentials:

```yaml
- name: Azure login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

No client secret is required. The trust decision is encoded in the federated credential subject:

```text
repo:<owner>/<repo>:ref:refs/heads/<branch>
```

## Deployment sequence

The deployment sequence is:

1. Check out the repository.
2. Authenticate to Azure with OIDC.
3. Log in to ACR with `az acr login`.
4. Build the Docker image.
5. Push immutable and `latest` tags to ACR.
6. Update the Web App container image reference.
7. Restart the Web App.
8. App Service pulls the image using its managed identity.
9. The application connects to PostgreSQL over private networking.

The workflow currently updates the Web App container image through Azure CLI:

```bash
az webapp config container set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --container-image-name "$ACR_LOGIN_SERVER/$IMAGE_NAME:${GITHUB_SHA}" \
  --container-registry-url "https://$ACR_LOGIN_SERVER"
```

## Terraform deployment flow

Terraform can be run as a separate workflow stage or manually during early project development.

Expected order:

1. Apply `infra/foundation` once to establish the OIDC identity and persistent backbone.
2. Store bootstrap outputs as GitHub secrets.
3. Pass `github_actions_principal_id` into `infra/runtime`.
4. Apply `infra/runtime` to create ACR, App Service, PostgreSQL, Key Vault runtime settings, and runtime RBAC.
5. Run the application deployment workflow.

For production pipelines, Terraform should use remote state and plan/apply controls rather than local state.

## Managed identity image pull

ACR admin credentials are disabled. The Web App uses a user-assigned managed identity for image pull. Terraform assigns `AcrPull` to that identity on the registry and configures App Service to use the managed identity for container registry access.

GitHub Actions has `AcrPush`, allowing it to publish images, but it is not the runtime image pull identity.

## Managed identity database authentication

The production database authentication target uses the Web App managed identity to acquire an Entra token for PostgreSQL. This is separate from deployment authentication:

- GitHub Actions identity deploys the system.
- Web App identity runs the system.
- PostgreSQL maps the Web App identity to a database role.

Keeping those identities separate reduces blast radius and makes operational responsibility clearer.

## Why OIDC over static GitHub secrets

OIDC is preferred because:

- there is no Azure client secret to rotate;
- token issuance is scoped to repository, branch, and workflow context;
- compromised repository secrets do not include a reusable cloud password;
- access can be revoked or changed in Entra and Azure RBAC;
- short-lived tokens align better with production deployment controls.
