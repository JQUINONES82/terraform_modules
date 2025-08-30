/**
 * <!-- This will become the header in README.md
 *      Add a description of the module here.
 *      Do not include Variable or Output descriptions. -->
 * Comprehensive AWS CloudWatch Alarm module that supports all CloudWatch alarm features
 * including metric alarms, composite alarms, anomaly detection, and various notification
 * actions. Follows AWS best practices for monitoring and alerting and includes comprehensive
 * validation and configuration options for enterprise environments.
 */

# Create CloudWatch metric alarm
resource "aws_cloudwatch_metric_alarm" "this" {
  count = var.create_alarm && var.alarm_type == "metric" ? 1 : 0

  alarm_name                = var.alarm_name
  alarm_description         = var.alarm_description
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  metric_name               = var.metric_name
  namespace                 = var.namespace
  period                    = var.period
  statistic                 = var.statistic
  threshold                 = var.threshold
  threshold_metric_id       = var.threshold_metric_id
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  dimensions                = var.dimensions
  datapoints_to_alarm       = var.datapoints_to_alarm
  treat_missing_data        = var.treat_missing_data
  evaluate_low_sample_count_percentiles = var.evaluate_low_sample_count_percentiles
  extended_statistic        = var.extended_statistic
  unit                      = var.unit

  # Metric query configuration
  dynamic "metric_query" {
    for_each = var.metric_queries
    content {
      id          = metric_query.value.id
      label       = metric_query.value.label
      return_data = metric_query.value.return_data
      expression  = metric_query.value.expression
      
      dynamic "metric" {
        for_each = metric_query.value.metric != null ? [metric_query.value.metric] : []
        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = metric.value.unit
          dimensions  = metric.value.dimensions
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true

    precondition {
      condition = var.alarm_type == "metric" && (
        (var.metric_name != null && var.namespace != null) ||
        length(var.metric_queries) > 0
      )
      error_message = "For metric alarms, either metric_name/namespace or metric_queries must be specified."
    }

    precondition {
      condition = var.statistic == null || var.extended_statistic == null
      error_message = "Cannot specify both statistic and extended_statistic."
    }
  }
}

# Create CloudWatch composite alarm
resource "aws_cloudwatch_composite_alarm" "this" {
  count = var.create_alarm && var.alarm_type == "composite" ? 1 : 0

  alarm_name                = var.alarm_name
  alarm_description         = var.alarm_description
  alarm_rule                = var.alarm_rule
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  # Action suppressor configuration
  dynamic "actions_suppressor" {
    for_each = var.actions_suppressor != null ? [var.actions_suppressor] : []
    content {
      alarm            = actions_suppressor.value.alarm
      extension_period = actions_suppressor.value.extension_period
      wait_period      = actions_suppressor.value.wait_period
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.alarm_type == "composite" && var.alarm_rule != null
      error_message = "For composite alarms, alarm_rule must be specified."
    }
  }
}

# Create CloudWatch anomaly alarm
resource "aws_cloudwatch_metric_alarm" "anomaly" {
  count = var.create_alarm && var.alarm_type == "anomaly" ? 1 : 0

  alarm_name                = var.alarm_name
  alarm_description         = var.alarm_description
  comparison_operator       = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods        = var.evaluation_periods
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  datapoints_to_alarm       = var.datapoints_to_alarm
  treat_missing_data        = var.treat_missing_data
  threshold_metric_id       = "ad1"

  metric_query {
    id = "m1"
    
    metric {
      metric_name = var.metric_name
      namespace   = var.namespace
      period      = var.period
      stat        = var.statistic
      dimensions  = var.dimensions
    }
  }

  metric_query {
    id = "ad1"
    expression = "ANOMALY_DETECTION_FUNCTION(m1, ${var.anomaly_threshold})"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true

    precondition {
      condition = var.alarm_type == "anomaly" && var.metric_name != null && var.namespace != null
      error_message = "For anomaly alarms, metric_name and namespace must be specified."
    }
  }
}

# Create CloudWatch anomaly detector (if supported)
# Note: Anomaly detector resource may not be available in all AWS provider versions
# resource "aws_cloudwatch_anomaly_detector" "this" {
#   count = var.create_alarm && var.alarm_type == "anomaly" && var.create_anomaly_detector ? 1 : 0
# 
#   metric_name = var.metric_name
#   namespace   = var.namespace
#   stat        = var.statistic
#   dimensions  = var.dimensions
# 
#   tags = var.tags
# }
