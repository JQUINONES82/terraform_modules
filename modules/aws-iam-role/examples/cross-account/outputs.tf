output "role_arn" {
  description = "ARN of the cross-account role"
  value       = module.cross_account_role.arn
}

output "role_name" {
  description = "Name of the cross-account role"
  value       = module.cross_account_role.name
}

output "assume_role_command" {
  description = "AWS CLI command to assume this role"
  value = "aws sts assume-role --role-arn ${module.cross_account_role.arn} --role-session-name CrossAccountSession --external-id ${var.external_id}"
}

output "max_session_duration" {
  description = "Maximum session duration for the role"
  value       = module.cross_account_role.max_session_duration
}
