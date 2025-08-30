output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = module.basic_iam_policy.arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = module.basic_iam_policy.name
}

output "policy_id" {
  description = "ID of the IAM policy"
  value       = module.basic_iam_policy.policy_id
}
