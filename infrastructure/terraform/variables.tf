# Root Variables for SchemaJeli Infrastructure

# Basic Configuration
variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "schemajeli"

  validation {
    condition     = length(var.project_name) <= 24
    error_message = "Project name must be 24 characters or less for Azure naming constraints."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"

  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}

variable "cost_center" {
  description = "Cost center for billing and tagging"
  type        = string
  default     = "engineering"
}

# Networking Configuration
variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_address" {
  description = "Address prefix for App Service subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "database_subnet_address" {
  description = "Address prefix for Database subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# App Service Configuration
variable "app_service_sku" {
  description = "SKU for App Service Plan (e.g., B2, B3, P1v2)"
  type        = string
  default     = "B2"

  validation {
    condition     = contains(["B1", "B2", "B3", "S1", "S2", "S3", "P1v2", "P2v2", "P3v2"], var.app_service_sku)
    error_message = "Invalid App Service SKU. Use B1/B2/B3 for dev, S1/S2/S3 for staging, P1v2+ for production."
  }
}

variable "cors_allowed_origins" {
  description = "List of allowed CORS origins for the API"
  type        = list(string)
  default     = ["http://localhost:5173", "http://localhost:3000"]
}

variable "additional_app_settings" {
  description = "Additional app settings for App Service"
  type        = map(string)
  default = {
    "LOG_LEVEL" = "debug"
  }
}

# Database Configuration
variable "db_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "schemajeli_admin"

  validation {
    condition     = length(var.db_admin_username) > 0 && length(var.db_admin_username) <= 63
    error_message = "Admin username must be 1-63 characters."
  }
}

variable "db_admin_password" {
  description = "PostgreSQL admin password (change this in production!)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_admin_password) >= 8
    error_message = "Admin password must be at least 8 characters."
  }
}

variable "db_name" {
  description = "Default database name to create"
  type        = string
  default     = "schemajeli"

  validation {
    condition     = length(var.db_name) > 0 && length(var.db_name) <= 63
    error_message = "Database name must be 1-63 characters."
  }
}

variable "postgres_version" {
  description = "PostgreSQL version (e.g., 13, 14, 15)"
  type        = string
  default     = "15"

  validation {
    condition     = contains(["12", "13", "14", "15", "16"], var.postgres_version)
    error_message = "Postgres version must be 12, 13, 14, 15, or 16."
  }
}

variable "db_sku" {
  description = "Database SKU (e.g., Standard_B1ms for dev, Standard_B4ms for prod)"
  type        = string
  default     = "Standard_B1ms"
}

variable "db_storage_mb" {
  description = "Database storage in MB (32768 = 32GB minimum)"
  type        = number
  default     = 32768

  validation {
    condition     = var.db_storage_mb >= 32768 && var.db_storage_mb <= 65536
    error_message = "Storage must be between 32GB (32768MB) and 64GB (65536MB)."
  }
}

variable "db_backup_days" {
  description = "Number of days to retain backups (7-35)"
  type        = number
  default     = 7

  validation {
    condition     = var.db_backup_days >= 7 && var.db_backup_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

variable "db_max_connections" {
  description = "Maximum number of database connections"
  type        = number
  default     = 100

  validation {
    condition     = var.db_max_connections >= 10 && var.db_max_connections <= 1000
    error_message = "Max connections must be between 10 and 1000."
  }
}

# Storage Configuration
variable "storage_account_tier" {
  description = "Storage account tier (Standard, Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage tier must be Standard or Premium."
  }
}

variable "storage_account_replication" {
  description = "Storage replication type (LRS, GRS, RAGRS, ZRS, GZRS)"
  type        = string
  default     = "GRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS"], var.storage_account_replication)
    error_message = "Replication must be LRS, GRS, RAGRS, ZRS, or GZRS."
  }
}

# Static Web App Configuration
variable "static_app_sku_tier" {
  description = "Static Web App SKU tier (Free or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard"], var.static_app_sku_tier)
    error_message = "SWA SKU must be Free or Standard."
  }
}

variable "static_app_sku_size" {
  description = "Static Web App SKU size"
  type        = string
  default     = "Standard"
}

variable "frontend_custom_domain" {
  description = "Custom domain for frontend (optional)"
  type        = string
  default     = null
}

variable "frontend_app_settings" {
  description = "Frontend app settings"
  type        = map(string)
  default = {
    "VITE_ENV" = "development"
  }
}

# Monitoring Configuration
variable "log_analytics_sku" {
  description = "Log Analytics SKU"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "Log Analytics retention in days (0 = unlimited)"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days == 0 || (var.log_retention_days >= 7 && var.log_retention_days <= 730)
    error_message = "Retention must be 0 (unlimited) or between 7 and 730 days."
  }
}

variable "alert_email_addresses" {
  description = "List of email addresses for alert notifications"
  type        = list(string)
  default     = ["ops@example.com"]
}

# Security Configuration
variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "JWT secret must be at least 32 characters."
  }
}

variable "app_service_principal_id" {
  description = "Principal ID of App Service managed identity (leave empty on first deploy)"
  type        = string
  default     = null
}

variable "additional_secrets" {
  description = "Additional secrets to store in Key Vault"
  type        = map(string)
  sensitive   = true
  default     = {}
}
