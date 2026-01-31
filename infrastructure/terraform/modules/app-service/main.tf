terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-${var.environment}-asp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = var.tags
}

# Backend API Web App
resource "azurerm_linux_web_app" "backend" {
  name                = "${var.project_name}-${var.environment}-backend-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  https_only = true

  site_config {
    always_on     = var.environment != "dev"
    http2_enabled = true

    application_stack {
      node_version = "18-lts"
    }

    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5

    cors {
      allowed_origins     = var.cors_allowed_origins
      support_credentials = true
    }
  }

  app_settings = merge(
    {
      "NODE_ENV"                              = var.environment
      "PORT"                                  = "8080"
      "DATABASE_URL"                          = "postgresql://${var.database_user}:${var.database_password}@${var.database_host}:5432/${var.database_name}"
      "JWT_SECRET"                            = var.jwt_secret
      "JWT_EXPIRY"                            = "3600"
      "BCRYPT_ROUNDS"                         = "12"
      "LOG_LEVEL"                             = var.environment == "prod" ? "info" : "debug"
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
    },
    var.additional_app_settings
  )

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

  tags = var.tags
}

# Deployment Slot for Blue-Green Deployment (Production only)
resource "azurerm_linux_web_app_slot" "staging" {
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

    cors {
      allowed_origins     = var.cors_allowed_origins
      support_credentials = true
    }
  }

  app_settings = azurerm_linux_web_app.backend.app_settings

  tags = var.tags
}
