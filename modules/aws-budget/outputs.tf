/**
 * AWS Budget Module Outputs
 */

# Budget Outputs
output "budget_id" {
  description = "The ID of the created budget"
  value       = var.create_budget ? aws_budgets_budget.this[0].id : null
}

output "budget_name" {
  description = "The name of the created budget"
  value       = var.create_budget ? aws_budgets_budget.this[0].name : null
}

output "budget_arn" {
  description = "The ARN of the created budget"
  value       = var.create_budget ? aws_budgets_budget.this[0].arn : null
}

output "budget_type" {
  description = "The type of the created budget"
  value       = var.create_budget ? aws_budgets_budget.this[0].budget_type : null
}

output "budget_limit_amount" {
  description = "The limit amount of the budget"
  value       = var.create_budget ? aws_budgets_budget.this[0].limit_amount : null
}

output "budget_limit_unit" {
  description = "The limit unit of the budget"
  value       = var.create_budget ? aws_budgets_budget.this[0].limit_unit : null
}

output "budget_time_unit" {
  description = "The time unit of the budget"
  value       = var.create_budget ? aws_budgets_budget.this[0].time_unit : null
}

output "budget_time_period_start" {
  description = "The start time of the budget period"
  value       = var.create_budget ? aws_budgets_budget.this[0].time_period_start : null
}

output "budget_time_period_end" {
  description = "The end time of the budget period"
  value       = var.create_budget ? aws_budgets_budget.this[0].time_period_end : null
}

# Anomaly Detection Outputs
output "anomaly_detector_arn" {
  description = "The ARN of the cost anomaly detector"
  value       = var.enable_anomaly_detection ? aws_ce_anomaly_detector.this[0].arn : null
}

output "anomaly_detector_name" {
  description = "The name of the cost anomaly detector"
  value       = var.enable_anomaly_detection ? aws_ce_anomaly_detector.this[0].name : null
}

output "anomaly_subscription_arn" {
  description = "The ARN of the cost anomaly subscription"
  value       = var.enable_anomaly_detection ? aws_ce_anomaly_subscription.this[0].arn : null
}

output "anomaly_subscription_name" {
  description = "The name of the cost anomaly subscription"
  value       = var.enable_anomaly_detection ? aws_ce_anomaly_subscription.this[0].name : null
}

# CloudWatch Alarm Outputs
output "budget_alarm_arn" {
  description = "The ARN of the budget CloudWatch alarm"
  value       = length(aws_cloudwatch_metric_alarm.budget_alarm) > 0 ? aws_cloudwatch_metric_alarm.budget_alarm[0].arn : null
}

output "budget_alarm_name" {
  description = "The name of the budget CloudWatch alarm"
  value       = length(aws_cloudwatch_metric_alarm.budget_alarm) > 0 ? aws_cloudwatch_metric_alarm.budget_alarm[0].alarm_name : null
}

# Configuration Summary
output "budget_summary" {
  description = "Summary of the budget configuration"
  value = var.create_budget ? {
    budget_name           = aws_budgets_budget.this[0].name
    budget_type          = aws_budgets_budget.this[0].budget_type
    limit_amount         = aws_budgets_budget.this[0].limit_amount
    limit_unit           = aws_budgets_budget.this[0].limit_unit
    time_unit            = aws_budgets_budget.this[0].time_unit
    account_id           = aws_budgets_budget.this[0].account_id
    notifications_count  = length(var.notifications)
    cost_filters_applied = length(local.cost_filters)
    anomaly_detection    = var.enable_anomaly_detection
    auto_adjust_enabled  = var.auto_adjust_type != null
  } : null
}

# Notification Configuration
output "notification_configuration" {
  description = "Summary of notification configuration"
  value = {
    notification_count = length(var.notifications)
    notifications = [
      for idx, notification in var.notifications : {
        index                      = idx
        comparison_operator        = notification.comparison_operator
        threshold                 = notification.threshold
        threshold_type            = notification.threshold_type
        notification_type         = notification.notification_type
        email_subscribers_count    = notification.subscriber_email_addresses != null ? length(notification.subscriber_email_addresses) : 0
        sns_subscribers_count      = notification.subscriber_sns_topic_arns != null ? length(notification.subscriber_sns_topic_arns) : 0
      }
    ]
  }
}

# Cost Filter Summary
output "cost_filter_summary" {
  description = "Summary of applied cost filters"
  value = {
    filter_count     = length(local.cost_filters)
    applied_filters  = keys(local.cost_filters)
    filter_details   = local.cost_filters
  }
}

# Account and Region Information
output "account_id" {
  description = "AWS Account ID where the budget is created"
  value       = local.account_id
}

output "region" {
  description = "AWS Region where the budget is created"
  value       = data.aws_region.current.name
}

# Tags Applied
output "tags_applied" {
  description = "Tags applied to the budget resources"
  value       = local.common_tags
}
