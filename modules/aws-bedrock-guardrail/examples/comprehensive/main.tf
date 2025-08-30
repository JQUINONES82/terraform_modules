terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "comprehensive_guardrail" {
  source = "../../"

  name                      = var.guardrail_name
  blocked_input_messaging   = "Your input violates our content policy and has been blocked."
  blocked_outputs_messaging = "The AI response has been filtered for policy compliance."
  description              = "Comprehensive example with all guardrail policies enabled"

  # Content filtering policies
  content_policy_config = {
    filters_config = [
      {
        input_strength  = "MEDIUM"
        output_strength = "MEDIUM"
        type           = "HATE"
      },
      {
        input_strength  = "HIGH"
        output_strength = "HIGH"
        type           = "VIOLENCE"
      },
      {
        input_strength  = "MEDIUM"
        output_strength = "MEDIUM"
        type           = "SEXUAL"
      }
    ]
    tier_config = {
      tier_name = "STANDARD"
    }
  }

  # Sensitive information protection
  sensitive_information_policy_config = {
    pii_entities_config = [
      {
        action = "BLOCK"
        type   = "NAME"
      },
      {
        action = "ANONYMIZE"
        type   = "EMAIL"
      },
      {
        action = "BLOCK"
        type   = "PHONE"
      }
    ]
    regexes_config = [
      {
        action      = "BLOCK"
        description = "Social Security Number pattern"
        name        = "ssn_pattern"
        pattern     = "^\\d{3}-\\d{2}-\\d{4}$"
      },
      {
        action      = "ANONYMIZE"
        description = "Credit card number pattern"
        name        = "credit_card_pattern"
        pattern     = "^\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}$"
      }
    ]
  }

  # Topic restrictions
  topic_policy_config = {
    topics_config = [
      {
        name       = "investment_advice"
        examples   = ["Where should I invest my money?", "What stocks should I buy?", "How should I manage my portfolio?"]
        type       = "DENY"
        definition = "Investment advice refers to inquiries, guidance, or recommendations regarding financial investments, portfolio management, or asset allocation."
      },
      {
        name       = "medical_advice"
        examples   = ["What medication should I take?", "How do I treat this condition?"]
        type       = "DENY"
        definition = "Medical advice includes diagnosis, treatment recommendations, or specific medical guidance that should be provided by licensed healthcare professionals."
      }
    ]
    tier_config = {
      tier_name = "STANDARD"
    }
  }

  # Word filtering
  word_policy_config = {
    managed_word_lists_config = [
      {
        type = "PROFANITY"
      }
    ]
    words_config = [
      {
        text = "inappropriate"
      },
      {
        text = "banned_word"
      }
    ]
  }

  # Contextual grounding policy
  contextual_grounding_policy_config = {
    filters_config = [
      {
        threshold = 0.8
        type      = "GROUNDING"
      },
      {
        threshold = 0.7
        type      = "RELEVANCE"
      }
    ]
  }

  tags = var.tags
}
