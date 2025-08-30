# Outputs for Complete Budget Example

# SNS Topic
output "budget_alerts_topic_arn" {
  description = "ARN of the SNS topic for budget alerts"
  value       = aws_sns_topic.budget_alerts.arn
}

# Budget Outputs
output "account_budget_summary" {
  description = "Summary of the total account budget"
  value       = module.account_budget.budget_summary
}

output "ai_services_budget_summary" {
  description = "Summary of the AI/ML services budget"
  value       = module.ai_services_budget.budget_summary
}

output "compute_budget_summary" {
  description = "Summary of the compute services budget"
  value       = module.compute_budget.budget_summary
}

output "storage_budget_summary" {
  description = "Summary of the storage services budget"
  value       = module.storage_budget.budget_summary
}

output "database_budget_summary" {
  description = "Summary of the database services budget"
  value       = module.database_budget.budget_summary
}

output "dev_environment_budget_summary" {
  description = "Summary of the development environment budget"
  value       = module.dev_environment_budget.budget_summary
}

output "prod_environment_budget_summary" {
  description = "Summary of the production environment budget"
  value       = module.prod_environment_budget.budget_summary
}

output "ec2_usage_budget_summary" {
  description = "Summary of the EC2 usage budget"
  value       = module.ec2_usage_budget.budget_summary
}

# Budget ARNs for integration
output "budget_arns" {
  description = "Map of budget ARNs for integration with other systems"
  value = {
    account_budget         = module.account_budget.budget_arn
    ai_services_budget     = module.ai_services_budget.budget_arn
    compute_budget         = module.compute_budget.budget_arn
    storage_budget         = module.storage_budget.budget_arn
    database_budget        = module.database_budget.budget_arn
    dev_environment_budget = module.dev_environment_budget.budget_arn
    prod_environment_budget = module.prod_environment_budget.budget_arn
    ec2_usage_budget       = module.ec2_usage_budget.budget_arn
  }
}

# Anomaly Detection
output "anomaly_detector_arns" {
  description = "Map of anomaly detector ARNs"
  value = {
    account_budget      = module.account_budget.anomaly_detector_arn
    ai_services_budget  = module.ai_services_budget.anomaly_detector_arn
    prod_environment_budget = module.prod_environment_budget.anomaly_detector_arn
  }
}

# Total Budget Configuration
output "total_budgets_configured" {
  description = "Total number of budgets configured"
  value = 8
}

output "budget_configuration_summary" {
  description = "Summary of all budget configurations"
  value = {
    total_budgets = 8
    budgets_with_anomaly_detection = 3
    total_monthly_limit = tonumber(var.total_budget_limit)
    environment = var.environment
    region = var.aws_region
  }
}
