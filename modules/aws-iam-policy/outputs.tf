output "arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = try(aws_iam_policy.this[0].arn, "")
}

output "id" {
  description = "The policy ID"
  value       = try(aws_iam_policy.this[0].id, "")
}

output "name" {
  description = "The name of the policy"
  value       = try(aws_iam_policy.this[0].name, "")
}

output "path" {
  description = "The path of the policy in IAM"
  value       = try(aws_iam_policy.this[0].path, "")
}

output "policy" {
  description = "The policy document"
  value       = try(aws_iam_policy.this[0].policy, "")
}

output "policy_id" {
  description = "The policy's ID"
  value       = try(aws_iam_policy.this[0].policy_id, "")
}

output "description" {
  description = "The description of the policy"
  value       = try(aws_iam_policy.this[0].description, "")
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = try(aws_iam_policy.this[0].tags_all, {})
}

# Attachment outputs
output "attached_roles" {
  description = "List of roles this policy is attached to"
  value       = var.attach_to_roles
}

output "attached_users" {
  description = "List of users this policy is attached to"
  value       = var.attach_to_users
}

output "attached_groups" {
  description = "List of groups this policy is attached to"
  value       = var.attach_to_groups
}

# Policy version outputs - Note: AWS provider doesn't support policy versions resource
# Use AWS CLI or console for policy version management

output "attachment_count" {
  description = "Total number of attachments (roles + users + groups)"
  value       = length(var.attach_to_roles) + length(var.attach_to_users) + length(var.attach_to_groups)
}
