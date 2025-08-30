output "guardrail_id" {
  description = "The unique identifier of the guardrail"
  value       = module.bedrock_guardrail.guardrail_id
}

output "guardrail_arn" {
  description = "The Amazon Resource Name (ARN) of the guardrail"
  value       = module.bedrock_guardrail.guardrail_arn
}

output "guardrail_name" {
  description = "The name of the guardrail"
  value       = module.bedrock_guardrail.name
}
