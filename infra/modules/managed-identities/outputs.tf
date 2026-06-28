output "identities" {
  description = "Managed identity details keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.main : key => {
      name         = identity.name
      id           = identity.id
      client_id    = identity.client_id
      principal_id = identity.principal_id
    }
  }
}
