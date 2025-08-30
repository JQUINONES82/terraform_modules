output "arn" {
  description = "Amazon Resource Name (ARN) specifying the role"
  value       = try(aws_iam_role.this[0].arn, "")
}

output "id" {
  description = "Name of the role"
  value       = try(aws_iam_role.this[0].id, "")
}

output "name" {
  description = "Name of the role"
  value       = try(aws_iam_role.this[0].name, "")
}

output "unique_id" {
  description = "Stable and unique string identifying the role"
  value       = try(aws_iam_role.this[0].unique_id, "")
}

output "create_date" {
  description = "Creation date of the IAM role"
  value       = try(aws_iam_role.this[0].create_date, "")
}

output "path" {
  description = "Path of the role"
  value       = try(aws_iam_role.this[0].path, "")
}

output "max_session_duration" {
  description = "Maximum session duration (in seconds) for the role"
  value       = try(aws_iam_role.this[0].max_session_duration, null)
}

output "permissions_boundary" {
  description = "The ARN of the permissions boundary for the role"
  value       = try(aws_iam_role.this[0].permissions_boundary, "")
}

output "assume_role_policy" {
  description = "Policy document associated with the role"
  value       = try(aws_iam_role.this[0].assume_role_policy, "")
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = try(aws_iam_role.this[0].tags_all, {})
}

# Instance Profile outputs
output "instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, "")
}

output "instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.this[0].id, "")
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].name, "")
}

output "instance_profile_unique_id" {
  description = "Unique ID assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.this[0].unique_id, "")
}

# Policy attachment outputs
output "managed_policy_arns" {
  description = "Set of managed policy ARNs attached to the role"
  value       = var.managed_policy_arns
}

output "inline_policy_names" {
  description = "List of inline policy names attached to the role"
  value       = keys(var.inline_policies)
}
