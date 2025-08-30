output "inference_profile_arn" {
  description = "The Amazon Resource Name (ARN) of the inference profile"
  value       = module.bedrock_inference_profile.arn
}

output "inference_profile_id" {
  description = "The unique identifier of the inference profile"
  value       = module.bedrock_inference_profile.id
}

output "inference_profile_name" {
  description = "The name of the inference profile"
  value       = module.bedrock_inference_profile.name
}

output "inference_profile_status" {
  description = "The status of the inference profile"
  value       = module.bedrock_inference_profile.status
}

output "inference_profile_type" {
  description = "The type of the inference profile"
  value       = module.bedrock_inference_profile.type
}

output "models" {
  description = "Information about models in the inference profile"
  value       = module.bedrock_inference_profile.models
}

output "account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}
