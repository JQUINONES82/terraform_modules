/**
 * AWS Budget Module Main Configuration
 * 
 * This module creates AWS Budgets with comprehensive cost monitoring,
 * spending limits, and anomaly detection capabilities.
 */

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current region
data "aws_region" "current" {}

# Local values for calculations
locals {
  account_id = var.account_id != null ? var.account_id : data.aws_caller_identity.current.account_id
  
  # Calculate time period start if not provided (first day of current month)
  time_period_start = var.time_period_start != null ? var.time_period_start : formatdate("YYYY-MM-01_00:00", timestamp())
  
  # Build cost filters dynamically
  cost_filters = {
    for key, value in var.cost_filters : upper(replace(key, "_", "")) => value if value != null && length(value) > 0
  }
  
  # Common tags
  common_tags = merge(var.tags, {
    Module      = "aws-budget"
    ManagedBy   = "terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })
}

# AWS Budget
resource "aws_budgets_budget" "this" {
  count = var.create_budget ? 1 : 0

  # Basic Configuration
  name         = var.budget_name
  budget_type  = var.budget_type
  limit_amount = var.limit_amount
  limit_unit   = var.limit_unit
  time_unit    = var.time_unit
  account_id   = local.account_id

  # Time Period
  time_period_start = local.time_period_start
  time_period_end   = var.time_period_end

  # Cost Filters
  dynamic "cost_filter" {
    for_each = local.cost_filters
    content {
      name   = cost_filter.key
      values = cost_filter.value
    }
  }

  # Auto Adjustment
  dynamic "auto_adjust_data" {
    for_each = var.auto_adjust_type != null ? [1] : []
    content {
      auto_adjust_type = var.auto_adjust_type
      
      dynamic "historical_options" {
        for_each = var.auto_adjust_type == "HISTORICAL" ? [1] : []
        content {
          budget_adjustment_period = var.historical_options_budget_adjustment_period
        }
      }
    }
  }

  # Notifications
  dynamic "notification" {
    for_each = var.notifications
    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                 = notification.value.threshold
      threshold_type            = notification.value.threshold_type
      notification_type         = notification.value.notification_type
      subscriber_email_addresses = notification.value.subscriber_email_addresses
      subscriber_sns_topic_arns  = notification.value.subscriber_sns_topic_arns
    }
  }

  # Tags
  tags = local.common_tags
}

# Cost Anomaly Detector
resource "aws_ce_anomaly_detector" "this" {
  count = var.enable_anomaly_detection ? 1 : 0

  name         = var.anomaly_detection_name != null ? var.anomaly_detection_name : "${var.budget_name}-anomaly-detector"
  detector_type = "CUSTOM"

  specification = jsonencode({
    Dimension = var.anomaly_monitor_specification.dimension_key != null ? {
      Key           = var.anomaly_monitor_specification.dimension_key
      Values        = [var.anomaly_monitor_specification.dimension_value]
      MatchOptions  = var.anomaly_monitor_specification.match_options != null ? var.anomaly_monitor_specification.match_options : ["EQUALS"]
    } : null
    
    Tags = var.anomaly_monitor_specification.tags != null ? var.anomaly_monitor_specification.tags : {}
  })

  tags = local.common_tags
}

# Cost Anomaly Subscription
resource "aws_ce_anomaly_subscription" "this" {
  count = var.enable_anomaly_detection ? 1 : 0

  name      = "${var.budget_name}-anomaly-subscription"
  frequency = var.anomaly_subscription_frequency
  
  monitor_arn_list = [aws_ce_anomaly_detector.this[0].arn]
  
  dynamic "subscriber" {
    for_each = var.anomaly_subscriber_email_addresses
    content {
      type    = "EMAIL"
      address = subscriber.value
    }
  }
  
  dynamic "subscriber" {
    for_each = var.anomaly_subscriber_sns_topic_arns
    content {
      type    = "SNS"
      address = subscriber.value
    }
  }

  threshold_expression {
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        values        = [tostring(var.anomaly_threshold_value)]
        match_options = [var.anomaly_threshold_expression]
      }
    }
  }

  tags = local.common_tags
}

# CloudWatch Metric Alarm for Budget (if SNS topics are provided)
resource "aws_cloudwatch_metric_alarm" "budget_alarm" {
  count = var.create_budget && length(flatten([for n in var.notifications : n.subscriber_sns_topic_arns != null ? n.subscriber_sns_topic_arns : []])) > 0 ? 1 : 0

  alarm_name          = "${var.budget_name}-budget-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400" # 24 hours
  statistic           = "Maximum"
  threshold           = tonumber(var.limit_amount) * 0.8 # Alert at 80% of budget
  alarm_description   = "This metric monitors estimated charges for budget ${var.budget_name}"
  alarm_actions       = distinct(flatten([for n in var.notifications : n.subscriber_sns_topic_arns != null ? n.subscriber_sns_topic_arns : []]))

  dimensions = {
    Currency = var.limit_unit
  }

  tags = local.common_tags
}

# Output file for budget tracking (optional)
resource "local_file" "budget_summary" {
  count = var.create_budget ? 1 : 0
  
  filename = "${path.module}/budget-${var.budget_name}-summary.json"
  content = jsonencode({
    budget_name = var.budget_name
    budget_type = var.budget_type
    limit_amount = var.limit_amount
    limit_unit = var.limit_unit
    time_unit = var.time_unit
    account_id = local.account_id
    cost_filters = local.cost_filters
    notifications_count = length(var.notifications)
    anomaly_detection_enabled = var.enable_anomaly_detection
    created_date = timestamp()
  })
}
