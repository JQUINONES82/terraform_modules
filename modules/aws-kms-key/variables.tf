/**
 * Variables for AWS KMS Key module
 */

# Core variables following AVM methodology
variable "create_key" {
  type        = bool
  default     = true
  description = "Whether to create a KMS key."
}

variable "create_external_key" {
  type        = bool
  default     = false
  description = "Whether to create an external KMS key for imported key material."
}

variable "description" {
  type        = string
  default     = "KMS key created by Terraform"
  description = "The description of the key as viewed in AWS console."
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT, SIGN_VERIFY, GENERATE_VERIFY_MAC."

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "Key usage must be one of: ENCRYPT_DECRYPT, SIGN_VERIFY, GENERATE_VERIFY_MAC."
  }
}

variable "key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies the type of key material in the CMK. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, ECC_SECG_P256K1, HMAC_224, HMAC_256, HMAC_384, HMAC_512, SM2."

  validation {
    condition = contains([
      "SYMMETRIC_DEFAULT", "RSA_2048", "RSA_3072", "RSA_4096",
      "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1",
      "HMAC_224", "HMAC_256", "HMAC_384", "HMAC_512", "SM2"
    ], var.key_spec)
    error_message = "Key spec must be a valid AWS KMS key specification."
  }
}

variable "policy" {
  type        = string
  default     = null
  description = "A valid policy JSON document. If not specified, AWS will generate a default policy."
}

variable "bypass_policy_lockout_safety_check" {
  type        = bool
  default     = false
  description = "A flag to indicate whether to bypass the key policy lockout safety check."
}

variable "deletion_window_in_days" {
  type        = number
  default     = 30
  description = "Duration in days after which the key is deleted after destruction of the resource."

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled."
}

variable "rotation_period_in_days" {
  type        = number
  default     = 365
  description = "Custom period of time between each rotation date. Must be a value between 90 and 2560 (inclusive)."

  validation {
    condition     = var.rotation_period_in_days >= 90 && var.rotation_period_in_days <= 2560
    error_message = "Rotation period must be between 90 and 2560 days."
  }
}

variable "multi_region" {
  type        = bool
  default     = false
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the key."
}

# Aliases configuration
variable "aliases" {
  type        = map(string)
  default     = {}
  description = "A map of aliases to create for the key. Map key is the alias name, value is optional description."
}

# Grants configuration
variable "grants" {
  type = map(object({
    grantee_principal = string
    operations        = list(string)
    constraints = optional(object({
      encryption_context_equals = optional(map(string))
      encryption_context_subset = optional(map(string))
    }))
    retiring_principal = optional(string)
  }))
  default     = {}
  description = "A map of grants to create for the key."
}

# External key variables
variable "key_material_base64" {
  type        = string
  default     = null
  description = "Base64 encoded 256-bit symmetric encryption key material to import."
}

variable "valid_to" {
  type        = string
  default     = null
  description = "Time at which the imported key material expires. When the key material expires, AWS KMS deletes the key material."
}

# Replica keys configuration
variable "replica_keys" {
  type = map(object({
    primary_key_arn = string
    policy          = optional(string)
    tags            = optional(map(string), {})
  }))
  default     = {}
  description = "A map of replica keys to create in different regions."
}

# Enable resource configuration
variable "enable_default_policy" {
  type        = bool
  default     = true
  description = "Whether to enable the default key policy."
}

variable "enable_alias" {
  type        = bool
  default     = false
  description = "Whether to create aliases for the key."
}

variable "enable_grants" {
  type        = bool
  default     = false
  description = "Whether to create grants for the key."
}

variable "enable_replica_keys" {
  type        = bool
  default     = false
  description = "Whether to create replica keys."
}

# Advanced configuration
variable "origin" {
  type        = string
  default     = "AWS_KMS"
  description = "The source of the key material for the CMK. Valid values: AWS_KMS, EXTERNAL, AWS_CLOUDHSM."

  validation {
    condition     = contains(["AWS_KMS", "EXTERNAL", "AWS_CLOUDHSM"], var.origin)
    error_message = "Origin must be one of: AWS_KMS, EXTERNAL, AWS_CLOUDHSM."
  }
}

variable "is_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the key is enabled."
}
