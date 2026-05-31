resource "azurerm_monitor_action_group" "rotation_alerts" {
  name                = "ag-key-rotation-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "keyrtn"

  email_receiver {
    name          = "ops-email"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "function_errors" {
  name                = "alert-rotation-function-errors"
  resource_group_name = var.resource_group_name
  scopes              = [var.function_id]
  description         = "Alert when key rotation function fails"

  criteria {
    metric_name      = "FunctionExecutionCount"
    metric_namespace = "Microsoft.Web/sites"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "ExecutionStatus"
      operator = "Include"
      values   = ["Failed"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.rotation_alerts.id
  }
}
