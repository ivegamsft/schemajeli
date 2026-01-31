terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58"
    }
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-${var.environment}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.retention_in_days

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${var.project_name}-${var.environment}-ai"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id

  sampling_percentage                 = var.sampling_percentage
  disable_ip_masking                  = var.environment != "prod"
  local_authentication_disabled       = false
  internet_ingestion_enabled          = true
  internet_query_enabled              = true
  force_customer_storage_for_profiler = var.environment == "prod"

  tags = var.tags
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.project_name}-${var.environment}-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "SJ-${upper(substr(var.environment, 0, 3))}"

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

# Metric Alert - High error rate
resource "azurerm_monitor_metric_alert" "high_error_rate" {
  name                = "${var.project_name}-${var.environment}-high-error-rate"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when error rate is high"
  severity            = 2
  enabled             = true
  window_size         = "PT5M"
  frequency           = "PT1M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    operator         = "GreaterThan"
    threshold        = 10
    aggregation      = "Count"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Metric Alert - High response time
resource "azurerm_monitor_metric_alert" "high_response_time" {
  name                = "${var.project_name}-${var.environment}-high-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when response time is high"
  severity            = 3
  enabled             = true
  window_size         = "PT5M"
  frequency           = "PT1M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    operator         = "GreaterThan"
    threshold        = 5000
    aggregation      = "Average"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}
