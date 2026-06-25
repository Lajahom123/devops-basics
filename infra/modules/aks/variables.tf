variable "name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the AKS cluster is created."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster API server."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the AKS default node pool."
  type        = string
}

variable "node_count" {
  description = "Node count for the AKS default system node pool."
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for the AKS default system node pool."
  type        = string
  default     = "Standard_B2s_v2"
}

variable "acr_id" {
  type        = string
  description = "Resource ID of the Azure Container Registry used by AKS for image pulls."
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID used by Container Insights."
  type        = string
}

variable "identity_ids" {
  description = "User-assigned managed identity IDs for the AKS control plane."
  type        = list(string)
}

variable "pod_cidr" {
  description = "Pod CIDR used by Azure CNI Overlay."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "Kubernetes service CIDR."
  type        = string
  default     = "10.245.0.0/16"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP. Must be inside service_cidr."
  type        = string
  default     = "10.245.0.10"
}

variable "tags" {
  description = "Tags to apply to the AKS cluster."
  type        = map(string)
  default     = {}
}
