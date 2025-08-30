/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * L1 Module to create an AWS Bedrock Guardrail Version.
  *
  * This module provides a Terraform resource for managing an Amazon Bedrock Guardrail Version,
  * which allows you to create versioned snapshots of guardrail configurations for better
  * deployment management and rollback capabilities in AI-powered applications.
  */

resource "aws_bedrock_guardrail_version" "this" {
  guardrail_arn = var.guardrail_arn
  description   = var.description
  skip_destroy  = var.skip_destroy

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }
}
