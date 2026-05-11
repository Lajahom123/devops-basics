data "azurerm_client_config" "current" {}

resource "azuread_application" "github_actions" {
  display_name = "github-${var.project_name}-${var.environment}-deploy"
}

resource "azuread_service_principal" "github_actions" {
  client_id = azuread_application.github_actions.client_id
}

resource "azuread_application_federated_identity_credential" "github_branch" {
  application_id = azuread_application.github_actions.id

  display_name = "github-${var.github_branch}"
  description  = "GitHub Actions OIDC for ${var.github_owner}/${var.github_repo} on ${var.github_branch}"

  audiences = [
    "api://AzureADTokenExchange"
  ]

  issuer = "https://token.actions.githubusercontent.com"

  subject = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
}

# Reader role mainly for testing
resource "azurerm_role_assignment" "github_resource_group_reader" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.github_actions.object_id
}