variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_address_space" {
  description = "Address space for app subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "database_subnet_address_space" {
  description = "Address space for database subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
