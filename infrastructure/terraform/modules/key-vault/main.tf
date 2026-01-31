terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
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

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Key Vault Access Policy for current user/SP
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update",
  ]
}

# Access policy for App Service
resource "azurerm_key_vault_access_policy" "app_service" {
  count        = var.app_service_principal_id != null ? 1 : 0
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.app_service_principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
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
