/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * L1 Module to create an AWS Bedrock Guardrail.
  *
  * This module provides a Terraform resource for managing an Amazon Bedrock Guardrail,
  * which helps control and filter content in AI-powered applications by defining
  * policies for content filtering, sensitive information protection, topic restrictions,
  * and word filtering.
  */

resource "aws_bedrock_guardrail" "this" {
  name                      = var.name
  blocked_input_messaging   = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_outputs_messaging
  description               = var.description
  kms_key_arn              = var.kms_key_arn
  tags                     = var.tags

  # Content Policy Configuration
  dynamic "content_policy_config" {
    for_each = var.content_policy_config != null ? [var.content_policy_config] : []
    content {
      dynamic "filters_config" {
        for_each = content_policy_config.value.filters_config != null ? content_policy_config.value.filters_config : []
        content {
          input_strength  = filters_config.value.input_strength
          output_strength = filters_config.value.output_strength
          type           = filters_config.value.type
        }
      }
      
      # Note: tier_config block commented out due to AWS provider compatibility
      # dynamic "tier_config" {
      #   for_each = content_policy_config.value.tier_config != null ? [content_policy_config.value.tier_config] : []
      #   content {
      #     tier_name = tier_config.value.tier_name
      #   }
      # }
    }
  }

  # Contextual Grounding Policy Configuration
  dynamic "contextual_grounding_policy_config" {
    for_each = var.contextual_grounding_policy_config != null ? [var.contextual_grounding_policy_config] : []
    content {
      dynamic "filters_config" {
        for_each = contextual_grounding_policy_config.value.filters_config
        content {
          threshold = filters_config.value.threshold
          type      = filters_config.value.type
        }
      }
      
      # Note: cross_region_config block commented out due to AWS provider compatibility  
      # dynamic "cross_region_config" {
      #   for_each = contextual_grounding_policy_config.value.cross_region_config != null ? [contextual_grounding_policy_config.value.cross_region_config] : []
      #   content {
      #     guardrail_profile_identifier = cross_region_config.value.guardrail_profile_identifier
      #   }
      # }
    }
  }

  # Sensitive Information Policy Configuration
  dynamic "sensitive_information_policy_config" {
    for_each = var.sensitive_information_policy_config != null ? [var.sensitive_information_policy_config] : []
    content {
      dynamic "pii_entities_config" {
        for_each = sensitive_information_policy_config.value.pii_entities_config != null ? sensitive_information_policy_config.value.pii_entities_config : []
        content {
          action = pii_entities_config.value.action
          type   = pii_entities_config.value.type
        }
      }

      dynamic "regexes_config" {
        for_each = sensitive_information_policy_config.value.regexes_config != null ? sensitive_information_policy_config.value.regexes_config : []
        content {
          action      = regexes_config.value.action
          description = regexes_config.value.description
          name        = regexes_config.value.name
          pattern     = regexes_config.value.pattern
        }
      }
    }
  }

  # Topic Policy Configuration
  dynamic "topic_policy_config" {
    for_each = var.topic_policy_config != null ? [var.topic_policy_config] : []
    content {
      dynamic "topics_config" {
        for_each = topic_policy_config.value.topics_config
        content {
          name       = topics_config.value.name
          examples   = topics_config.value.examples
          type       = topics_config.value.type
          definition = topics_config.value.definition
        }
      }
      
      # Note: tier_config block commented out due to AWS provider compatibility
      # dynamic "tier_config" {
      #   for_each = topic_policy_config.value.tier_config != null ? [topic_policy_config.value.tier_config] : []
      #   content {
      #     tier_name = tier_config.value.tier_name
      #   }
      # }
    }
  }

  # Word Policy Configuration
  dynamic "word_policy_config" {
    for_each = var.word_policy_config != null ? [var.word_policy_config] : []
    content {
      dynamic "managed_word_lists_config" {
        for_each = word_policy_config.value.managed_word_lists_config != null ? word_policy_config.value.managed_word_lists_config : []
        content {
          type = managed_word_lists_config.value.type
        }
      }
      
      dynamic "words_config" {
        for_each = word_policy_config.value.words_config != null ? word_policy_config.value.words_config : []
        content {
          text = words_config.value.text
        }
      }
    }
  }
}
