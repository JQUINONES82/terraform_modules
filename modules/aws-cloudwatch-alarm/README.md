# AWS CloudWatch Alarm Module

Comprehensive AWS CloudWatch Alarm module that supports all CloudWatch alarm features including metric alarms, composite alarms, anomaly detection, and various notification actions. Follows AWS best practices for monitoring and alerting and includes comprehensive validation and configuration options for enterprise environments.

## Features

- **Metric Alarms**: Standard CloudWatch metric alarms with customizable thresholds
- **Composite Alarms**: Combine multiple alarms with logical operators
- **Anomaly Detection**: Machine learning-based anomaly detection alarms
- **Multiple Actions**: Support for SNS, Auto Scaling, EC2, and other alarm actions
- **Advanced Statistics**: Support for percentiles and extended statistics
- **Metric Queries**: Complex metric expressions and math operations
- **Action Suppression**: Conditional action suppression based on other alarms
- **Comprehensive Validation**: Input validation for all configuration options

## Usage

### Basic Metric Alarm

```hcl
module "cpu_alarm" {
  source = "../aws-cloudwatch-alarm"

  alarm_name          = "high-cpu-utilization"
  alarm_description   = "Triggers when CPU utilization is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  
  dimensions = {
    InstanceId = "i-1234567890abcdef0"
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Environment = "production"
    Service     = "web-server"
  }
}
```

### Anomaly Detection Alarm

```hcl
module "anomaly_alarm" {
  source = "../aws-cloudwatch-alarm"

  alarm_type          = "anomaly"
  alarm_name          = "request-anomaly"
  alarm_description   = "Detects anomalous request patterns"
  evaluation_periods  = 2
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  anomaly_threshold   = 2
  
  dimensions = {
    LoadBalancer = "app/my-load-balancer/50dc6c495c0c9188"
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn,
    aws_autoscaling_policy.scale_up.arn
  ]

  tags = {
    Environment = "production"
    Type        = "anomaly-detection"
  }
}
```

### Composite Alarm

```hcl
module "composite_alarm" {
  source = "../aws-cloudwatch-alarm"

  alarm_type        = "composite"
  alarm_name        = "application-health"
  alarm_description = "Overall application health based on multiple metrics"
  
  alarm_rule = join(" OR ", [
    "ALARM(${module.cpu_alarm.alarm_name})",
    "ALARM(${module.memory_alarm.alarm_name})",
    "ALARM(${module.disk_alarm.alarm_name})"
  ])

  alarm_actions = [
    aws_sns_topic.critical_alerts.arn
  ]

  # Suppress actions during maintenance window
  actions_suppressor = {
    alarm            = aws_cloudwatch_metric_alarm.maintenance_mode.alarm_name
    extension_period = 300
    wait_period      = 300
  }

  tags = {
    Environment = "production"
    Type        = "composite"
    Criticality = "high"
  }
}
```

### Complex Metric Query Alarm

```hcl
module "error_rate_alarm" {
  source = "../aws-cloudwatch-alarm"

  alarm_name          = "high-error-rate"
  alarm_description   = "Triggers when error rate exceeds 5%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 5
  
  metric_queries = {
    error_rate = {
      id          = "e1"
      expression  = "m2/m1*100"
      label       = "Error Rate"
      return_data = true
    }
    total_requests = {
      id = "m1"
      metric = {
        metric_name = "RequestCount"
        namespace   = "AWS/ApplicationELB"
        period      = 300
        stat        = "Sum"
        dimensions = {
          LoadBalancer = "app/my-load-balancer/50dc6c495c0c9188"
        }
      }
    }
    error_requests = {
      id = "m2"
      metric = {
        metric_name = "HTTPCode_Target_5XX_Count"
        namespace   = "AWS/ApplicationELB"
        period      = 300
        stat        = "Sum"
        dimensions = {
          LoadBalancer = "app/my-load-balancer/50dc6c495c0c9188"
        }
      }
    }
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Environment = "production"
    Type        = "error-rate"
  }
}
```

### Percentile-based Alarm

```hcl
module "latency_alarm" {
  source = "../aws-cloudwatch-alarm"

  alarm_name                = "high-p99-latency"
  alarm_description         = "Triggers when 99th percentile latency is high"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 3
  datapoints_to_alarm       = 2
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = 300
  extended_statistic        = "p99"
  threshold                 = 1.0
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  
  dimensions = {
    LoadBalancer = "app/my-load-balancer/50dc6c495c0c9188"
  }

  alarm_actions = [
    aws_sns_topic.performance_alerts.arn
  ]

  tags = {
    Environment = "production"
    Metric      = "latency"
    Percentile  = "p99"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| create_alarm | Whether to create the CloudWatch alarm | `bool` | `true` | no |
| alarm_type | Type of alarm to create: metric, composite, or anomaly | `string` | `"metric"` | no |
| alarm_name | The descriptive name for the alarm | `string` | n/a | yes |
| alarm_description | The description for the alarm | `string` | `null` | no |
| comparison_operator | The arithmetic operation to use when comparing the specified Statistic and Threshold | `string` | `"GreaterThanThreshold"` | no |
| evaluation_periods | The number of periods over which data is compared to the specified threshold | `number` | `2` | no |
| metric_name | The name for the alarm's associated metric | `string` | `null` | no |
| namespace | The namespace for the alarm's associated metric | `string` | `null` | no |
| period | The period in seconds over which the specified statistic is applied | `number` | `300` | no |
| statistic | The statistic to apply to the alarm's associated metric | `string` | `"Average"` | no |
| threshold | The value against which the specified statistic is compared | `number` | `null` | no |
| alarm_actions | The list of actions to execute when this alarm transitions into an ALARM state | `list(string)` | `[]` | no |
| dimensions | The dimensions for the alarm's associated metric | `map(string)` | `{}` | no |
| metric_queries | Map of metric query configurations for complex alarms | `map(object)` | `{}` | no |
| alarm_rule | Expression that specifies which other alarms are to be evaluated (composite alarms) | `string` | `null` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the CloudWatch alarm |
| id | The ID of the CloudWatch alarm |
| alarm_name | The name of the alarm |
| alarm_description | The description of the alarm |
| metric_alarm_arn | The ARN of the metric alarm |
| composite_alarm_arn | The ARN of the composite alarm |
| anomaly_alarm_arn | The ARN of the anomaly alarm |
| anomaly_detector_arn | The ARN of the anomaly detector |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Alarm Types

### Metric Alarms
Standard CloudWatch alarms that monitor a single metric or metric expression.

### Composite Alarms
Combine multiple alarms using logical operators (AND, OR, NOT) to create complex alerting rules.

### Anomaly Detection Alarms
Use machine learning models to detect unusual patterns in your metrics automatically.

## Best Practices

- Use appropriate evaluation periods and datapoints to alarm ratios to avoid false positives
- Implement composite alarms for complex scenarios requiring multiple conditions
- Use anomaly detection for metrics with unpredictable but normal variance
- Set up proper alarm actions including notification and auto-remediation
- Use percentile statistics for latency and performance metrics
- Implement action suppression during maintenance windows
- Tag alarms appropriately for cost tracking and organization

## Examples

See the `examples/` directory for complete usage examples.
