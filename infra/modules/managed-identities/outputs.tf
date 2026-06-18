output "identity_ids" {
  description = "User-assigned identity resource IDs keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.main : key => identity.id
  }
}

output "client_ids" {
  description = "User-assigned identity client IDs keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.main : key => identity.client_id
  }
}

output "principal_ids" {
  description = "User-assigned identity principal IDs keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.main : key => identity.principal_id
  }
}
