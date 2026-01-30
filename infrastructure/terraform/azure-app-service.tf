# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-${var.environment}-asp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  
  tags = local.common_tags
}

# Linux Web App (Backend API)
resource "azurerm_linux_web_app" "backend" {
  name                = "${var.project_name}-${var.environment}-backend-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  
  https_only = true
  
  site_config {
    always_on        = var.environment != "dev"
    http2_enabled    = true
    
    application_stack {
      node_version = "18-lts"
    }
    
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
    
    cors {
      allowed_origins = var.environment == "prod" ? [
        "https://schemajeli.example.com"
      ] : ["*"]
      support_credentials = true
    }
  }
  
  app_settings = {
    "NODE_ENV"                              = var.environment
    "PORT"                                  = "8080"
    "DATABASE_URL"                          = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.postgres_connection_string.id})"
    "JWT_SECRET"                            = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt_secret.id})"
    "JWT_EXPIRY"                            = "3600"
    "BCRYPT_ROUNDS"                         = "12"
    "LOG_LEVEL"                             = var.environment == "prod" ? "info" : "debug"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    
    application_logs {
      file_system_level = "Information"
    }
    
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
  
  tags = local.common_tags
}

# Deployment Slot for Blue-Green Deployment (Production only)
resource "azurerm_linux_web_app_slot" "backend_staging" {
  count          = var.environment == "prod" ? 1 : 0
  name           = "staging"
  app_service_id = azurerm_linux_web_app.backend.id
  
  https_only = true
  
  site_config {
    always_on     = true
    http2_enabled = true
    
    application_stack {
      node_version = "18-lts"
    }
    
    health_check_path = "/health"
  }
  
  app_settings = azurerm_linux_web_app.backend.app_settings
  
  tags = local.common_tags
}

# Static Web App (Frontend)
resource "azurerm_static_site" "frontend" {
  name                = "${var.project_name}-${var.environment}-frontend"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"  # Static Web Apps limited regions
  sku_tier            = var.environment == "prod" ? "Standard" : "Free"
  sku_size            = var.environment == "prod" ? "Standard" : "Free"
  
  tags = local.common_tags
}

# Grant App Service access to Key Vault
resource "azurerm_key_vault_access_policy" "backend" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = azurerm_linux_web_app.backend.identity[0].tenant_id
  object_id    = azurerm_linux_web_app.backend.identity[0].principal_id
  
  secret_permissions = [
    "Get",
    "List"
  ]
}

# Custom Domain (Production only)
# resource "azurerm_app_service_custom_hostname_binding" "backend" {
#   count               = var.environment == "prod" ? 1 : 0
#   hostname            = "api.schemajeli.example.com"
#   app_service_name    = azurerm_linux_web_app.backend.name
#   resource_group_name = azurerm_resource_group.main.name
# }

# SSL Certificate (Production only)
# resource "azurerm_app_service_managed_certificate" "backend" {
#   count                      = var.environment == "prod" ? 1 : 0
#   custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.backend[0].id
# }

# Output backend URL
output "backend_staging_slot_url" {
  description = "Backend staging slot URL (production only)"
  value       = var.environment == "prod" ? "https://${azurerm_linux_web_app_slot.backend_staging[0].default_hostname}" : null
}
