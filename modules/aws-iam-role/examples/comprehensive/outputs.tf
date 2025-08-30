output "role_arn" {
  description = "ARN of the comprehensive IAM role"
  value       = module.comprehensive_iam_role.arn
}

output "role_name" {
  description = "Name of the comprehensive IAM role"
  value       = module.comprehensive_iam_role.name
}

output "role_unique_id" {
  description = "Unique ID of the IAM role"
  value       = module.comprehensive_iam_role.unique_id
}

output "role_path" {
  description = "Path of the IAM role"
  value       = module.comprehensive_iam_role.path
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = module.comprehensive_iam_role.instance_profile_arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = module.comprehensive_iam_role.instance_profile_name
}

output "managed_policy_arns" {
  description = "Set of managed policy ARNs attached to the role"
  value       = module.comprehensive_iam_role.managed_policy_arns
}

output "inline_policy_names" {
  description = "List of inline policy names attached to the role"
  value       = module.comprehensive_iam_role.inline_policy_names
}

output "max_session_duration" {
  description = "Maximum session duration for the role"
  value       = module.comprehensive_iam_role.max_session_duration
}

output "tags_all" {
  description = "All tags applied to the role"
  value       = module.comprehensive_iam_role.tags_all
}
