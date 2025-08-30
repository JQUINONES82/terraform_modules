# Required variables
variable "policy" {
  description = "The policy document as a JSON string"
  type        = string

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "Policy must be valid JSON."
  }

  validation {
    condition     = length(var.policy) <= 6144
    error_message = "Policy document cannot exceed 6144 characters."
  }
}

# Optional variables
variable "name" {
  description = "The name of the policy. If omitted, Terraform will assign a random, unique name"
  type        = string
  default     = null

  validation {
    condition = var.name == null || (
      length(var.name) >= 1 &&
      length(var.name) <= 128 &&
      can(regex("^[\\w+=,.@-]+$", var.name))
    )
    error_message = "Policy name must be 1-128 characters and can contain alphanumeric characters and +=,.@- characters."
  }
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name"
  type        = string
  default     = null

  validation {
    condition = var.name_prefix == null || (
      try(length(var.name_prefix), 0) >= 1 &&
      try(length(var.name_prefix), 0) <= 96 &&
      can(regex("^[\\w+=,.@-]+$", var.name_prefix))
    )
    error_message = "Policy name prefix must be 1-96 characters and can contain alphanumeric characters and +=,.@- characters."
  }
}

variable "description" {
  description = "Description of the IAM policy"
  type        = string
  default     = null

  validation {
    condition     = var.description == null || length(var.description) <= 1000
    error_message = "Policy description cannot exceed 1000 characters."
  }
}

variable "path" {
  description = "Path in which to create the policy"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^(/|(/[A-Za-z0-9\\+=,.@\\-_/]+/))$", var.path))
    error_message = "Path must begin and end with / and can contain alphanumeric characters and +=,.@-_ characters."
  }
}

variable "tags" {
  description = "Key-value mapping of tags for the IAM policy"
  type        = map(string)
  default     = {}
}

# Enable/disable features
variable "create_policy" {
  description = "Whether to create the IAM policy"
  type        = bool
  default     = true
}

# Policy attachment variables
variable "attach_to_roles" {
  description = "List of IAM role names to attach this policy to"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for role in var.attach_to_roles : can(regex("^[\\w+=,.@-]+$", role))
    ])
    error_message = "All role names must contain only alphanumeric characters and +=,.@- characters."
  }
}

variable "attach_to_users" {
  description = "List of IAM user names to attach this policy to"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for user in var.attach_to_users : can(regex("^[\\w+=,.@-]+$", user))
    ])
    error_message = "All user names must contain only alphanumeric characters and +=,.@- characters."
  }
}

variable "attach_to_groups" {
  description = "List of IAM group names to attach this policy to"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for group in var.attach_to_groups : can(regex("^[\\w+=,.@-]+$", group))
    ])
    error_message = "All group names must contain only alphanumeric characters and +=,.@- characters."
  }
}
