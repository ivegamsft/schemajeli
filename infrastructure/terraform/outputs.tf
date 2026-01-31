# Root Outputs - Aggregated from Modules

# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure location for resources"
  value       = azurerm_resource_group.main.location
}

# Networking Outputs
output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = module.networking.vnet_name
}

output "app_subnet_id" {
  description = "App Service subnet ID"
  value       = module.networking.app_subnet_id
}

output "database_subnet_id" {
  description = "Database subnet ID"
  value       = module.networking.database_subnet_id
}

# Backend API Outputs
output "backend_app_id" {
  description = "Backend App Service ID"
  value       = module.app_service.backend_app_id
}

output "backend_app_name" {
  description = "Backend App Service name"
  value       = module.app_service.backend_app_name
}

output "backend_default_hostname" {
  description = "Backend App Service default hostname"
  value       = module.app_service.backend_default_hostname
}

output "backend_app_url" {
  description = "Backend App Service default URL"
  value       = "https://${module.app_service.backend_default_hostname}"
}

output "backend_principal_id" {
  description = "Principal ID of backend App Service managed identity"
  value       = module.app_service.principal_id
  sensitive   = true
}

# Frontend Outputs
output "static_web_app_id" {
  description = "Static Web App resource ID"
  value       = module.static_web_app.static_site_id
}

output "static_web_app_name" {
  description = "Static Web App name"
  value       = module.static_web_app.static_site_name
}

output "frontend_default_domain" {
  description = "Static Web App default domain"
  value       = module.static_web_app.default_host_name
}

output "frontend_url" {
  description = "Frontend Static Web App default URL"
  value       = "https://${module.static_web_app.default_host_name}"
}

output "frontend_api_key" {
  description = "Static Web App API key"
  value       = module.static_web_app.api_key
  sensitive   = true
}

# Database Outputs
output "database_server_id" {
  description = "PostgreSQL Flexible Server ID"
  value       = module.database.server_id
}

output "database_server_fqdn" {
  description = "PostgreSQL Flexible Server FQDN"
  value       = module.database.server_fqdn
  sensitive   = true
}

output "database_name" {
  description = "PostgreSQL database name"
  value       = module.database.database_name
}

output "database_admin_username" {
  description = "PostgreSQL admin username"
  value       = module.database.admin_username
  sensitive   = true
}

output "database_admin_password" {
  description = "PostgreSQL admin password"
  value       = module.database.admin_password
  sensitive   = true
}

output "database_connection_string" {
  description = "PostgreSQL connection string"
  value       = module.database.connection_string
  sensitive   = true
}

# Storage Outputs
output "storage_account_id" {
  description = "Storage Account ID"
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = module.storage.storage_account_name
}

output "storage_primary_connection_string" {
  description = "Primary connection string for storage account"
  value       = module.storage.primary_connection_string
  sensitive   = true
}

output "storage_sas_token" {
  description = "SAS token for storage account access"
  value       = module.storage.storage_account_sas_token
  sensitive   = true
}

output "uploads_container_name" {
  description = "Name of uploads blob container"
  value       = module.storage.uploads_container_name
}

output "exports_container_name" {
  description = "Name of exports blob container"
  value       = module.storage.exports_container_name
}

output "backups_container_name" {
  description = "Name of backups blob container"
  value       = module.storage.backups_container_name
}

# Key Vault Outputs
output "key_vault_id" {
  description = "Key Vault resource ID"
  value       = module.key_vault.key_vault_id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "Key Vault URI for secret references"
  value       = module.key_vault.key_vault_uri
}

output "database_connection_string_secret_id" {
  description = "Secret ID for database connection string"
  value       = module.key_vault.database_secret_id
  sensitive   = true
}

output "jwt_secret_id" {
  description = "Secret ID for JWT signing secret"
  value       = module.key_vault.jwt_secret_id
  sensitive   = true
}

# Monitoring Outputs
output "app_insights_id" {
  description = "Application Insights resource ID"
  value       = module.monitoring.application_insights_id
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.monitoring.application_insights_instrumentation_key
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = module.monitoring.log_analytics_workspace_name
}

output "action_group_id" {
  description = "Action Group ID for alert notifications"
  value       = module.monitoring.action_group_id
}

# Summary Outputs
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    project      = var.project_name
    environment  = var.environment
    location     = var.location
    backend_url  = "https://${module.app_service.backend_default_hostname}"
    frontend_url = "https://${module.static_web_app.default_host_name}"
    api_url      = "https://${module.app_service.backend_default_hostname}"
  }
}
