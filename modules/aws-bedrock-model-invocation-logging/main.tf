/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * L1 Module to create an AWS Bedrock Model Invocation Logging Configuration.
  *
  * This module provides a Terraform resource for managing Amazon Bedrock model invocation 
  * logging configuration, which enables comprehensive logging and monitoring of AI model 
  * invocations for compliance, debugging, and usage analysis purposes. The configuration 
  * supports logging to both S3 and CloudWatch with flexible data delivery options.
  */

resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  logging_config {
    embedding_data_delivery_enabled = var.logging_config.embedding_data_delivery_enabled
    image_data_delivery_enabled     = var.logging_config.image_data_delivery_enabled
    text_data_delivery_enabled      = var.logging_config.text_data_delivery_enabled
    video_data_delivery_enabled     = var.logging_config.video_data_delivery_enabled

    # S3 Configuration
    dynamic "s3_config" {
      for_each = var.logging_config.s3_config != null ? [var.logging_config.s3_config] : []
      content {
        bucket_name = s3_config.value.bucket_name
        key_prefix  = s3_config.value.key_prefix
      }
    }

    # CloudWatch Configuration
    dynamic "cloudwatch_config" {
      for_each = var.logging_config.cloudwatch_config != null ? [var.logging_config.cloudwatch_config] : []
      content {
        log_group_name = cloudwatch_config.value.log_group_name
        role_arn      = cloudwatch_config.value.role_arn

        # Large Data Delivery S3 Configuration
        dynamic "large_data_delivery_s3_config" {
          for_each = cloudwatch_config.value.large_data_delivery_s3_config != null ? [cloudwatch_config.value.large_data_delivery_s3_config] : []
          content {
            bucket_name = large_data_delivery_s3_config.value.bucket_name
            key_prefix  = large_data_delivery_s3_config.value.key_prefix
          }
        }
      }
    }
  }
}
