terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Random suffix for globally unique names
resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "${var.project_name}-${var.environment}-kv-${random_string.kv_suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.environment == "prod"
  sku_name                    = "standard"
  enable_rbac_authorization   = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# RBAC Role Assignment for Terraform principal
resource "azurerm_role_assignment" "terraform_kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# RBAC Role Assignment for App Service identity
resource "azurerm_role_assignment" "app_service_kv_secrets_user" {
  count                = var.app_service_principal_id != "" ? 1 : 0
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.app_service_principal_id
}

# Random password for Database
resource "random_password" "database_admin" {
  length  = 32
  special = true
}

# Database admin password secret
resource "azurerm_key_vault_secret" "database_admin_password" {
  name         = "database-admin-password"
  value        = random_password.database_admin.result
  key_vault_id = azurerm_key_vault.main.id
}

# Database connection string secret
resource "azurerm_key_vault_secret" "database_connection_string" {
  name         = "database-connection-string"
  value        = var.database_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

# JWT Secret
resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret"
  value        = var.jwt_secret
  key_vault_id = azurerm_key_vault.main.id
}

# Additional secrets (converted to non-sensitive for for_each usage)
resource "azurerm_key_vault_secret" "additional_secrets" {
  for_each     = { for k, v in var.additional_secrets : k => tostring(v) }
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.main.id
}

# Current Azure client configuration
data "azurerm_client_config" "current" {}
