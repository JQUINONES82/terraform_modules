output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = module.policy_with_attachments.arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = module.policy_with_attachments.name
}

output "attached_roles" {
  description = "Roles attached to the policy"
  value       = module.policy_with_attachments.attached_roles
}

output "attached_users" {
  description = "Users attached to the policy"
  value       = module.policy_with_attachments.attached_users
}

output "attached_groups" {
  description = "Groups attached to the policy"
  value       = module.policy_with_attachments.attached_groups
}

output "attachment_count" {
  description = "Total number of attachments"
  value       = module.policy_with_attachments.attachment_count
}
