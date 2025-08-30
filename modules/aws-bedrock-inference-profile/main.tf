/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * L1 Module to create an AWS Bedrock Inference Profile.
  *
  * This module provides a Terraform resource for managing an Amazon Bedrock Inference Profile,
  * which allows you to track metrics and costs for specific AI models, enabling better
  * cost allocation and usage monitoring across different projects or use cases.
  */

resource "aws_bedrock_inference_profile" "this" {
  name        = var.name
  description = var.description
  tags        = var.tags

  model_source {
    copy_from = var.model_source.copy_from
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
