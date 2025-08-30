output "comprehensive_policy_arn" {
  description = "ARN of the comprehensive IAM policy"
  value       = module.comprehensive_iam_policy.arn
}

output "comprehensive_policy_name" {
  description = "Name of the comprehensive IAM policy"
  value       = module.comprehensive_iam_policy.name
}

output "comprehensive_policy_path" {
  description = "Path of the comprehensive IAM policy"
  value       = module.comprehensive_iam_policy.path
}

output "versioned_policy_arn" {
  description = "ARN of the versioned IAM policy"
  value       = module.versioned_policy.arn
}

output "versioned_policy_versions" {
  description = "Policy versions created"
  value       = module.versioned_policy.policy_versions
}
