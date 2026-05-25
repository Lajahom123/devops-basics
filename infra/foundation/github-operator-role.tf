resource "azurerm_role_definition" "dev_stop_start_operator" {
  name        = "DevOps Tracker Dev Stop Start Operator"
  scope       = data.azurerm_resource_group.main.id
  description = "Can stop, start, scale and delete selected dev resources."

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/resources/read",

      "Microsoft.DBforPostgreSQL/flexibleServers/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/start/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/stop/action",

      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachines/delete",

      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/delete",

      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/networkInterfaces/delete",

      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/delete",

      "Microsoft.Network/networkSecurityGroups/read",

      "Microsoft.Cdn/profiles/read",
      "Microsoft.Cdn/profiles/afdEndpoints/read",
      "Microsoft.Cdn/profiles/afdEndpoints/write",

      "Microsoft.Web/serverfarms/read",
      "Microsoft.Web/serverfarms/write"
    ]
  }

  assignable_scopes = [
    data.azurerm_resource_group.main.id
  ]
}

resource "azurerm_role_assignment" "github_actions_dev_operator_stop_start" {
  scope              = data.azurerm_resource_group.main.id
  role_definition_id = azurerm_role_definition.dev_stop_start_operator.role_definition_resource_id
  principal_id       = azuread_service_principal.github_actions_dev_operator.object_id
}