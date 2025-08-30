output "account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

# Development profile outputs
output "dev_profile_arn" {
  description = "ARN of the development inference profile"
  value       = module.dev_inference_profile.arn
}

output "dev_profile_id" {
  description = "ID of the development inference profile"
  value       = module.dev_inference_profile.id
}

output "dev_profile_status" {
  description = "Status of the development inference profile"
  value       = module.dev_inference_profile.status
}

# Staging profile outputs
output "staging_profile_arn" {
  description = "ARN of the staging inference profile"
  value       = module.staging_inference_profile.arn
}

output "staging_profile_id" {
  description = "ID of the staging inference profile"
  value       = module.staging_inference_profile.id
}

output "staging_profile_status" {
  description = "Status of the staging inference profile"
  value       = module.staging_inference_profile.status
}

# Production profile outputs
output "prod_profile_arn" {
  description = "ARN of the production inference profile"
  value       = module.prod_inference_profile.arn
}

output "prod_profile_id" {
  description = "ID of the production inference profile"
  value       = module.prod_inference_profile.id
}

output "prod_profile_status" {
  description = "Status of the production inference profile"
  value       = module.prod_inference_profile.status
}

# Cross-account profile outputs (conditional)
output "cross_account_profile_arn" {
  description = "ARN of the cross-account inference profile"
  value       = var.enable_cross_account_profile ? module.cross_account_inference_profile[0].arn : null
}

output "cross_account_profile_id" {
  description = "ID of the cross-account inference profile"
  value       = var.enable_cross_account_profile ? module.cross_account_inference_profile[0].id : null
}

output "cross_account_profile_status" {
  description = "Status of the cross-account inference profile"
  value       = var.enable_cross_account_profile ? module.cross_account_inference_profile[0].status : null
}

# Summary outputs
output "all_profile_arns" {
  description = "List of all created inference profile ARNs"
  value = compact([
    module.dev_inference_profile.arn,
    module.staging_inference_profile.arn,
    module.prod_inference_profile.arn,
    var.enable_cross_account_profile ? module.cross_account_inference_profile[0].arn : ""
  ])
}

output "profile_count" {
  description = "Total number of inference profiles created"
  value       = var.enable_cross_account_profile ? 4 : 3
}
