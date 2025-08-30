output "role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.lambda_execution_role.arn
}

output "role_name" {
  description = "Name of the Lambda execution role"
  value       = module.lambda_execution_role.name
}

output "inline_policies" {
  description = "Inline policies attached to the role"
  value       = module.lambda_execution_role.inline_policy_names
}
