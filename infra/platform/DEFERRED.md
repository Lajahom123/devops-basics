# Deferred Platform Inventory

The platform root is intentionally network-only for the first student-environment apply. These items existed in the previous platform configuration and are tracked here so they are not forgotten.

## Module-ready platform pieces

- ACR: `infra/modules/acr`
  - Previous resource: `azurerm_container_registry.main`
  - Add after the network plan is applied.
  - Keep SKU `Basic`, admin disabled, and public network access enabled until private endpoints are introduced.
- Key Vault: `infra/modules/key-vault`
  - Previous resource: `azurerm_key_vault.main`
  - Add after ACR if secrets or app configuration are needed.
  - Keep purge protection disabled in dev unless cleanup pain is acceptable.
- Managed identities: `infra/modules/managed-identities`
  - Previous identities: web app, migration job, GitHub runner.
  - For the AKS path, prefer initial names like `id-devops-tracker-dev-aks-workload` and `id-devops-tracker-dev-github-actions`.
  - Add federated credentials only after the GitHub OIDC subject details are final.
- Private DNS: `infra/modules/private-dns`
  - Previous zones: `private.postgres.database.azure.com`, `privatelink.azurewebsites.net`.
  - Likely future zones: `privatelink.postgres.database.azure.com`, `privatelink.vaultcore.azure.net`, `privatelink.azurecr.io`.
  - Add only when PostgreSQL, Key Vault, ACR private endpoints, or private web endpoints are introduced.
- Monitoring: `infra/modules/monitoring`
  - Previous resources: Log Analytics Workspace and Application Insights.
  - Keep retention low and create Application Insights only when runtime needs it.
- NSGs: `infra/modules/network-security-groups`
  - Previous NSGs: GitHub runner and AKS nodes.
  - Add only when there are concrete rules to enforce or a subnet needs an association.
- GitHub OIDC base identities: `infra/modules/github-oidc`
  - Previous resources: deploy app, deploy service principal, branch federated credential, dev-operator app, dev-operator service principal, environment federated credential.
  - Requires the `azuread` provider in whichever live root calls it.

## Intentionally not in active platform

- NAT Gateway: `infra/modules/nat-gateway`
  - Previous resources: NAT public IP, NAT Gateway, public IP association, subnet associations for GitHub runner and AKS nodes.
  - Keep out of platform for now because it has a standing cost.
  - Add later from a lab or runtime-specific root if stable outbound IP is required.
- Bastion: `infra/modules/bastion`
  - Previous resources: Bastion host and public IP.
  - Requires an `AzureBastionSubnet`; add a subnet only when Bastion is intentionally enabled.
  - Keep out for now because it is not needed for the first platform apply.
- Role assignments
  - Previous assignments included ACR pull for workload identities, Key Vault roles, GitHub reader, ACR build executor, and a custom dev stop/start operator role.
  - Add these next to the resources and principals they connect, after those modules exist in a live root.

## Old runtime-shaped items already outside platform

Keep these out of platform and attach them to `runtime-aks`, another runtime root, or a lab when they are intentionally reintroduced:

- AKS
- PostgreSQL Flexible Server
- Front Door
- App Service and slots
- App Service plans
- Container Apps environment and migration job
- Self-hosted runner VM
- Private endpoints
- Runtime diagnostics and alerts
