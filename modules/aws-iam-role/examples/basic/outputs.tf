output "role_arn" {
  description = "ARN of the IAM role"
  value       = module.basic_iam_role.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = module.basic_iam_role.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = module.basic_iam_role.instance_profile_arn
}
