variable "resource_group_name" {
  type    = string
  default = "rg-devops-tracker-dev"
}

variable "location" {
  type    = string
  default = "switzerlandnorth"
}

variable "storage_account_name" {
  type    = string
  default = "stdevopstrackerswn"
}

variable "container_name" {
  type    = string
  default = "tfstate"
}