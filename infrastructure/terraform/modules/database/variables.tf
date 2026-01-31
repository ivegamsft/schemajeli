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

variable "subnet_id" {
  description = "Subnet ID for PostgreSQL deployment"
  type        = string
}

variable "vnet_id" {
  description = "Virtual Network ID for DNS zone linking"
  type        = string
}

variable "admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "sqladmin"
}

variable "admin_password" {
  description = "PostgreSQL admin password (should be retrieved from Key Vault)"
  type        = string
  sensitive   = true
}

variable "app_service_principal_id" {
  description = "Principal ID of the App Service for RBAC access"
  type        = string
  default     = ""
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "schemajeli"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "sku_name" {
  description = "PostgreSQL SKU"
  type        = string
  default     = "B_Standard_B2s"
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}

variable "backup_retention_days" {
  description = "Backup retention days"
  type        = number
  default     = 7
}

variable "max_connections" {
  description = "Maximum database connections"
  type        = number
  default     = 200
}

variable "allow_local_dev" {
  description = "Allow local development connections (dev only)"
  type        = bool
  default     = true
}

variable "allow_azure_services" {
  description = "Allow Azure services to connect"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
