# Core variables
variable "create_alarm" {
  description = "Whether to create the CloudWatch alarm"
  type        = bool
  default     = true
}

variable "alarm_type" {
  description = "Type of alarm to create: metric, composite, or anomaly"
  type        = string
  default     = "metric"

  validation {
    condition     = contains(["metric", "composite", "anomaly"], var.alarm_type)
    error_message = "Alarm type must be one of: metric, composite, anomaly."
  }
}

# Basic alarm configuration
variable "alarm_name" {
  description = "The descriptive name for the alarm"
  type        = string

  validation {
    condition = length(var.alarm_name) >= 1 && length(var.alarm_name) <= 255
    error_message = "Alarm name must be 1-255 characters."
  }
}

variable "alarm_description" {
  description = "The description for the alarm"
  type        = string
  default     = null

  validation {
    condition = var.alarm_description == null || length(var.alarm_description) <= 1024
    error_message = "Alarm description must be 1024 characters or less."
  }
}

variable "actions_enabled" {
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state"
  type        = bool
  default     = true
}

# Metric alarm configuration
variable "comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold"
  type        = string
  default     = "GreaterThanThreshold"

  validation {
    condition = contains([
      "GreaterThanOrEqualToThreshold",
      "GreaterThanThreshold", 
      "LessThanThreshold",
      "LessThanOrEqualToThreshold",
      "LessThanLowerOrGreaterThanUpperThreshold",
      "LessThanLowerThreshold",
      "GreaterThanUpperThreshold"
    ], var.comparison_operator)
    error_message = "Invalid comparison operator."
  }
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  type        = number
  default     = 2

  validation {
    condition     = var.evaluation_periods >= 1
    error_message = "Evaluation periods must be at least 1."
  }
}

variable "datapoints_to_alarm" {
  description = "The number of datapoints that must be breaching to trigger the alarm"
  type        = number
  default     = null

  validation {
    condition = var.datapoints_to_alarm == null || var.datapoints_to_alarm >= 1
    error_message = "Datapoints to alarm must be at least 1."
  }
}

variable "metric_name" {
  description = "The name for the alarm's associated metric"
  type        = string
  default     = null
}

variable "namespace" {
  description = "The namespace for the alarm's associated metric"
  type        = string
  default     = null
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied"
  type        = number
  default     = 300

  validation {
    condition = var.period >= 10 && (var.period % 60 == 0 || var.period % 10 == 0)
    error_message = "Period must be at least 10 seconds and be a multiple of 60 for periods >= 60, or multiple of 10 for periods < 60."
  }
}

variable "statistic" {
  description = "The statistic to apply to the alarm's associated metric"
  type        = string
  default     = "Average"

  validation {
    condition = var.statistic == null || contains([
      "SampleCount", "Average", "Sum", "Minimum", "Maximum"
    ], var.statistic)
    error_message = "Statistic must be one of: SampleCount, Average, Sum, Minimum, Maximum."
  }
}

variable "extended_statistic" {
  description = "The percentile statistic for the metric associated with the alarm"
  type        = string
  default     = null

  validation {
    condition = var.extended_statistic == null || can(regex("^p([0-9]|[1-9][0-9]|100)(\\.\\d+)?$", var.extended_statistic))
    error_message = "Extended statistic must be a valid percentile (e.g., p95, p99.9)."
  }
}

variable "threshold" {
  description = "The value against which the specified statistic is compared"
  type        = number
  default     = null
}

variable "threshold_metric_id" {
  description = "If this is an alarm based on an anomaly detection model, make this value match the ID of the ANOMALY_DETECTION_FUNCTION"
  type        = string
  default     = null
}

variable "unit" {
  description = "The unit for the alarm's associated metric"
  type        = string
  default     = null

  validation {
    condition = var.unit == null || contains([
      "Seconds", "Microseconds", "Milliseconds", "Bytes", "Kilobytes", "Megabytes", 
      "Gigabytes", "Terabytes", "Bits", "Kilobits", "Megabits", "Gigabits", 
      "Terabits", "Percent", "Count", "Bytes/Second", "Kilobytes/Second", 
      "Megabytes/Second", "Gigabytes/Second", "Terabytes/Second", "Bits/Second", 
      "Kilobits/Second", "Megabits/Second", "Gigabits/Second", "Terabits/Second", 
      "Count/Second", "None"
    ], var.unit)
    error_message = "Invalid unit specified."
  }
}

variable "dimensions" {
  description = "The dimensions for the alarm's associated metric"
  type        = map(string)
  default     = {}
}

variable "treat_missing_data" {
  description = "Sets how this alarm is to handle missing data points"
  type        = string
  default     = "missing"

  validation {
    condition = contains([
      "breaching", "notBreaching", "ignore", "missing"
    ], var.treat_missing_data)
    error_message = "Treat missing data must be one of: breaching, notBreaching, ignore, missing."
  }
}

variable "evaluate_low_sample_count_percentiles" {
  description = "Used only for alarms based on percentiles"
  type        = string
  default     = null

  validation {
    condition = var.evaluate_low_sample_count_percentiles == null || contains([
      "evaluate", "ignore"
    ], var.evaluate_low_sample_count_percentiles)
    error_message = "Evaluate low sample count percentiles must be 'evaluate' or 'ignore'."
  }
}

# Actions
variable "alarm_actions" {
  description = "The list of actions to execute when this alarm transitions into an ALARM state"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.alarm_actions) <= 5
    error_message = "Maximum of 5 alarm actions allowed."
  }
}

variable "ok_actions" {
  description = "The list of actions to execute when this alarm transitions into an OK state"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.ok_actions) <= 5
    error_message = "Maximum of 5 OK actions allowed."
  }
}

variable "insufficient_data_actions" {
  description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.insufficient_data_actions) <= 5
    error_message = "Maximum of 5 insufficient data actions allowed."
  }
}

# Metric queries for complex alarms
variable "metric_queries" {
  description = "Map of metric query configurations for complex alarms"
  type = map(object({
    id          = string
    label       = optional(string)
    return_data = optional(bool, true)
    metric = optional(object({
      metric_name = string
      namespace   = string
      period      = number
      stat        = string
      unit        = optional(string)
      dimensions  = optional(map(string), {})
    }))
    expression = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for query in values(var.metric_queries) : 
      (query.metric != null && query.expression == null) || 
      (query.metric == null && query.expression != null)
    ])
    error_message = "Each metric query must have either a metric or expression, but not both."
  }
}

# Composite alarm configuration
variable "alarm_rule" {
  description = "An expression that specifies which other alarms are to be evaluated to determine this composite alarm's state"
  type        = string
  default     = null
}

variable "actions_suppressor" {
  description = "Actions will be suppressed if the suppressor alarm is in the ALARM state"
  type = object({
    alarm            = string
    extension_period = number
    wait_period      = number
  })
  default = null

  validation {
    condition = var.actions_suppressor == null || (
      var.actions_suppressor.extension_period >= 0 &&
      var.actions_suppressor.wait_period >= 0
    )
    error_message = "Extension period and wait period must be non-negative."
  }
}

# Anomaly detection configuration
variable "create_anomaly_detector" {
  description = "Whether to create an anomaly detector for anomaly alarms"
  type        = bool
  default     = true
}

variable "anomaly_threshold" {
  description = "The value used to compare with the anomaly detection band"
  type        = number
  default     = 2

  validation {
    condition     = var.anomaly_threshold > 0
    error_message = "Anomaly threshold must be greater than 0."
  }
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
