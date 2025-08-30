/**
 * AWS Budget Module Variables
 * 
 * This module creates AWS Budgets for cost monitoring, spending limits,
 * and anomaly detection with customizable alerts and notifications.
 */

# Core Budget Configuration
variable "budget_name" {
  description = "Name of the budget"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.budget_name))
    error_message = "Budget name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "budget_type" {
  description = "The type of budget (COST, USAGE, RI_UTILIZATION, RI_COVERAGE, SAVINGS_PLANS_UTILIZATION, SAVINGS_PLANS_COVERAGE)"
  type        = string
  default     = "COST"
  
  validation {
    condition = contains([
      "COST", "USAGE", "RI_UTILIZATION", "RI_COVERAGE", 
      "SAVINGS_PLANS_UTILIZATION", "SAVINGS_PLANS_COVERAGE"
    ], var.budget_type)
    error_message = "Budget type must be one of: COST, USAGE, RI_UTILIZATION, RI_COVERAGE, SAVINGS_PLANS_UTILIZATION, SAVINGS_PLANS_COVERAGE."
  }
}

variable "time_unit" {
  description = "The length of time until a budget resets the actual and forecasted spend (MONTHLY, QUARTERLY, ANNUALLY)"
  type        = string
  default     = "MONTHLY"
  
  validation {
    condition     = contains(["MONTHLY", "QUARTERLY", "ANNUALLY"], var.time_unit)
    error_message = "Time unit must be one of: MONTHLY, QUARTERLY, ANNUALLY."
  }
}

variable "limit_amount" {
  description = "The amount of cost or usage being measured for a budget"
  type        = string
  
  validation {
    condition     = can(tonumber(var.limit_amount)) && tonumber(var.limit_amount) > 0
    error_message = "Limit amount must be a positive number."
  }
}

variable "limit_unit" {
  description = "The unit of measurement for the budget forecast, actual spend, or budget threshold (USD, etc.)"
  type        = string
  default     = "USD"
}

# Time Period Configuration
variable "time_period_start" {
  description = "Start time of the budget (YYYY-MM-DD_HH:MM format). If not provided, defaults to current month start."
  type        = string
  default     = null
  
  validation {
    condition = var.time_period_start == null || can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}:[0-9]{2}$", var.time_period_start))
    error_message = "Time period start must be in YYYY-MM-DD_HH:MM format."
  }
}

variable "time_period_end" {
  description = "End time of the budget (YYYY-MM-DD_HH:MM format). If not provided, defaults to indefinite."
  type        = string
  default     = null
  
  validation {
    condition = var.time_period_end == null || can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}:[0-9]{2}$", var.time_period_end))
    error_message = "Time period end must be in YYYY-MM-DD_HH:MM format."
  }
}

# Cost Filters
variable "cost_filters" {
  description = "Map of cost filters to apply to the budget"
  type = object({
    # AWS Service filters
    service = optional(list(string))
    
    # Linked Account filters (for organizational accounts)
    linked_account = optional(list(string))
    
    # Tag filters
    tag = optional(map(list(string)))
    
    # Availability Zone filters
    availability_zone = optional(list(string))
    
    # Instance Type filters
    instance_type = optional(list(string))
    
    # Region filters
    region = optional(list(string))
    
    # Usage Type filters
    usage_type = optional(list(string))
    
    # Usage Type Group filters
    usage_type_group = optional(list(string))
    
    # Record Type filters (Credit, Discount, Fee, Refund, Tax, Usage, etc.)
    record_type = optional(list(string))
    
    # Operating System filters
    operating_system = optional(list(string))
    
    # Tenancy filters
    tenancy = optional(list(string))
    
    # Scope filters
    scope = optional(list(string))
    
    # Platform filters
    platform = optional(list(string))
    
    # Subscription filters
    subscription_id = optional(list(string))
    
    # Legal Entity Name filters
    legal_entity_name = optional(list(string))
    
    # Deployment Option filters
    deployment_option = optional(list(string))
    
    # Database Engine filters
    database_engine = optional(list(string))
    
    # Cache Engine filters
    cache_engine = optional(list(string))
    
    # Instance Type Family filters
    instance_type_family = optional(list(string))
    
    # Billing Entity filters
    billing_entity = optional(list(string))
    
    # Reservation ID filters
    reservation_id = optional(list(string))
    
    # Resource ID filters
    resource_id = optional(list(string))
    
    # Rightsizing Type filters
    rightsizing_type = optional(list(string))
    
    # Savings Plans Type filters
    savings_plans_type = optional(list(string))
    
    # Service Code filters
    service_code = optional(list(string))
    
    # Usage Account ID filters
    usage_account_id = optional(list(string))
    
    # Purchase Type filters
    purchase_type = optional(list(string))
  })
  default = {}
}

# Notifications Configuration
variable "notifications" {
  description = "List of notification configurations for budget alerts"
  type = list(object({
    # Comparison operator for the notification
    comparison_operator = string
    
    # Threshold for the notification (percentage for PERCENTAGE, amount for ABSOLUTE_VALUE)
    threshold = number
    
    # Type of threshold (PERCENTAGE or ABSOLUTE_VALUE)
    threshold_type = string
    
    # Type of notification (ACTUAL or FORECASTED)
    notification_type = string
    
    # List of email addresses to notify
    subscriber_email_addresses = optional(list(string))
    
    # List of SNS topic ARNs to notify
    subscriber_sns_topic_arns = optional(list(string))
  }))
  default = []
  
  validation {
    condition = alltrue([
      for notification in var.notifications : contains([
        "GREATER_THAN", "LESS_THAN", "EQUAL_TO"
      ], notification.comparison_operator)
    ])
    error_message = "Comparison operator must be one of: GREATER_THAN, LESS_THAN, EQUAL_TO."
  }
  
  validation {
    condition = alltrue([
      for notification in var.notifications : contains([
        "PERCENTAGE", "ABSOLUTE_VALUE"
      ], notification.threshold_type)
    ])
    error_message = "Threshold type must be one of: PERCENTAGE, ABSOLUTE_VALUE."
  }
  
  validation {
    condition = alltrue([
      for notification in var.notifications : contains([
        "ACTUAL", "FORECASTED"
      ], notification.notification_type)
    ])
    error_message = "Notification type must be one of: ACTUAL, FORECASTED."
  }
  
  validation {
    condition = alltrue([
      for notification in var.notifications : notification.threshold > 0
    ])
    error_message = "Threshold must be greater than 0."
  }
}

# Budget Actions (Auto Actions)
variable "auto_adjust_type" {
  description = "The type of auto adjustment (HISTORICAL, FORECAST)"
  type        = string
  default     = null
  
  validation {
    condition = var.auto_adjust_type == null || contains([
      "HISTORICAL", "FORECAST"
    ], var.auto_adjust_type)
    error_message = "Auto adjust type must be one of: HISTORICAL, FORECAST."
  }
}

variable "historical_options_budget_adjustment_period" {
  description = "The number of budget periods for historical adjustments (1-60)"
  type        = number
  default     = 1
  
  validation {
    condition     = var.historical_options_budget_adjustment_period >= 1 && var.historical_options_budget_adjustment_period <= 60
    error_message = "Historical options budget adjustment period must be between 1 and 60."
  }
}

# Advanced Configuration
variable "cost_filter_match_options" {
  description = "Match options for cost filters (EQUALS, ABSENT, STARTS_WITH, ENDS_WITH, CONTAINS, CASE_SENSITIVE, CASE_INSENSITIVE)"
  type        = list(string)
  default     = ["EQUALS"]
  
  validation {
    condition = alltrue([
      for option in var.cost_filter_match_options : contains([
        "EQUALS", "ABSENT", "STARTS_WITH", "ENDS_WITH", 
        "CONTAINS", "CASE_SENSITIVE", "CASE_INSENSITIVE"
      ], option)
    ])
    error_message = "Match options must be valid cost filter match options."
  }
}

variable "account_id" {
  description = "Account ID for the budget. If not specified, uses current account."
  type        = string
  default     = null
  
  validation {
    condition = var.account_id == null || can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Account ID must be a 12-digit number."
  }
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the budget"
  type        = map(string)
  default     = {}
}

# Module Control
variable "create_budget" {
  description = "Whether to create the budget"
  type        = bool
  default     = true
}

# Anomaly Detection
variable "enable_anomaly_detection" {
  description = "Whether to enable cost anomaly detection"
  type        = bool
  default     = false
}

variable "anomaly_detection_name" {
  description = "Name for the cost anomaly detector"
  type        = string
  default     = null
}

variable "anomaly_monitor_specification" {
  description = "Configuration for anomaly detection monitoring"
  type = object({
    dimension_key   = optional(string)
    dimension_value = optional(string)
    match_options   = optional(list(string))
    tags            = optional(map(list(string)))
  })
  default = {}
}

variable "anomaly_subscription_frequency" {
  description = "Frequency of anomaly detection notifications (DAILY, IMMEDIATE, WEEKLY)"
  type        = string
  default     = "DAILY"
  
  validation {
    condition     = contains(["DAILY", "IMMEDIATE", "WEEKLY"], var.anomaly_subscription_frequency)
    error_message = "Anomaly subscription frequency must be one of: DAILY, IMMEDIATE, WEEKLY."
  }
}

variable "anomaly_threshold_expression" {
  description = "Expression to determine when to trigger anomaly alerts"
  type        = string
  default     = "GREATER_THAN_OR_EQUAL"
  
  validation {
    condition = contains([
      "GREATER_THAN_OR_EQUAL", "LESS_THAN_OR_EQUAL"
    ], var.anomaly_threshold_expression)
    error_message = "Anomaly threshold expression must be GREATER_THAN_OR_EQUAL or LESS_THAN_OR_EQUAL."
  }
}

variable "anomaly_threshold_value" {
  description = "Dollar value threshold for anomaly detection"
  type        = number
  default     = 100
  
  validation {
    condition     = var.anomaly_threshold_value >= 0
    error_message = "Anomaly threshold value must be non-negative."
  }
}

variable "anomaly_subscriber_email_addresses" {
  description = "List of email addresses for anomaly detection alerts"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for email in var.anomaly_subscriber_email_addresses : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All email addresses must be valid."
  }
}

variable "anomaly_subscriber_sns_topic_arns" {
  description = "List of SNS topic ARNs for anomaly detection alerts"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for arn in var.anomaly_subscriber_sns_topic_arns : can(regex("^arn:aws:sns:[a-z0-9-]+:[0-9]{12}:[a-zA-Z0-9_-]+$", arn))
    ])
    error_message = "All SNS topic ARNs must be valid."
  }
}
