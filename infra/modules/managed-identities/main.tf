resource "azurerm_user_assigned_identity" "main" {
  for_each = local.identities

  name                = each.value
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azuread_group" "postgres_admins" {
  display_name     = "devops-tracker-postgres-admins"
  security_enabled = true
}

resource "azuread_group_member" "bootstrap_identity_postgres_admin" {
  group_object_id  = azuread_group.postgres_admins.object_id
  member_object_id = azurerm_user_assigned_identity.main["postgres_bootstrap"].principal_id
}

resource "azuread_group_member" "general_postgres_admin" {
  group_object_id  = azuread_group.postgres_admins.object_id
  member_object_id = var.postgres_admin_member_object_id
}
