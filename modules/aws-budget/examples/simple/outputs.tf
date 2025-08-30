output "monthly_budget_arn" {
  description = "ARN of the monthly budget"
  value       = module.monthly_budget.budget_arn
}

output "bedrock_budget_arn" {
  description = "ARN of the Bedrock budget"
  value       = module.bedrock_budget.budget_arn
}

output "bedrock_anomaly_detector_arn" {
  description = "ARN of the Bedrock anomaly detector"
  value       = module.bedrock_budget.anomaly_detector_arn
}
