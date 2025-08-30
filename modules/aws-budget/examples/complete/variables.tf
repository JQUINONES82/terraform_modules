# Variables for Complete Budget Example

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

# Budget Limits
variable "total_budget_limit" {
  description = "Total account budget limit in USD"
  type        = string
  default     = "5000"
}

variable "ai_services_budget_limit" {
  description = "AI/ML services budget limit in USD"
  type        = string
  default     = "1000"
}

variable "compute_budget_limit" {
  description = "Compute services budget limit in USD"
  type        = string
  default     = "2000"
}

variable "storage_budget_limit" {
  description = "Storage services budget limit in USD"
  type        = string
  default     = "500"
}

variable "database_budget_limit" {
  description = "Database services budget limit in USD"
  type        = string
  default     = "800"
}

variable "dev_environment_limit" {
  description = "Development environment budget limit in USD"
  type        = string
  default     = "300"
}

variable "prod_environment_limit" {
  description = "Production environment budget limit in USD"
  type        = string
  default     = "3000"
}

variable "ec2_usage_hours_limit" {
  description = "EC2 usage hours limit per month"
  type        = string
  default     = "1000"
}

# Notification Settings
variable "notification_email" {
  description = "Primary email for budget notifications"
  type        = string
  default     = "ops-team@company.com"
}

variable "finance_email" {
  description = "Finance team email for budget notifications"
  type        = string
  default     = "finance@company.com"
}

variable "ai_team_email" {
  description = "AI/ML team email for AI services budget"
  type        = string
  default     = "ai-team@company.com"
}

variable "ops_team_email" {
  description = "Operations team email"
  type        = string
  default     = "ops-team@company.com"
}

variable "storage_team_email" {
  description = "Storage team email"
  type        = string
  default     = "storage-team@company.com"
}

variable "database_team_email" {
  description = "Database team email"
  type        = string
  default     = "database-team@company.com"
}

variable "dev_team_email" {
  description = "Development team email"
  type        = string
  default     = "dev-team@company.com"
}

# Anomaly Detection
variable "anomaly_threshold" {
  description = "Dollar threshold for anomaly detection alerts"
  type        = number
  default     = 200
}

# Filtering
variable "allowed_regions" {
  description = "List of allowed AWS regions for cost tracking"
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
}

# Tags
variable "tags" {
  description = "Common tags to apply to all budgets"
  type        = map(string)
  default = {
    Terraform   = "true"
    Module      = "aws-budget"
    Environment = "production"
    Owner       = "finance-team"
    Project     = "cost-management"
  }
}
