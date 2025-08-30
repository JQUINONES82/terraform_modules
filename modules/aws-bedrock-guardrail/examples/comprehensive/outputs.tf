output "guardrail_id" {
  description = "The unique identifier of the guardrail"
  value       = module.comprehensive_guardrail.guardrail_id
}

output "guardrail_arn" {
  description = "The Amazon Resource Name (ARN) of the guardrail"
  value       = module.comprehensive_guardrail.guardrail_arn
}

output "guardrail_name" {
  description = "The name of the guardrail"
  value       = module.comprehensive_guardrail.name
}

output "guardrail_version" {
  description = "The version of the guardrail"
  value       = module.comprehensive_guardrail.version
}

output "guardrail_status" {
  description = "The status of the guardrail"
  value       = module.comprehensive_guardrail.status
}
