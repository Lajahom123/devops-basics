variable "resource_group_name" {
  description = "Resource group where the network resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for network resources."
  type        = string
}

variable "project" {
  description = "Project name used for tagging."
  type        = string
}

variable "environment" {
  description = "Environment name used for tagging."
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string
}

variable "address_space" {
  description = "Virtual network address space."
  type        = list(string)
}

variable "subnets" {
  description = "Subnets keyed by logical name."
  type = map(object({
    name                                          = string
    address_prefixes                              = list(string)
    private_endpoint_network_policies             = optional(string)
    private_link_service_network_policies_enabled = optional(bool)
    service_endpoints                             = optional(list(string), [])
    delegations = optional(map(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    })), {})
  }))
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}
