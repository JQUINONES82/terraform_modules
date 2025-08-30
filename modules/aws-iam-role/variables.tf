# Required variables
variable "assume_role_policy" {
  description = "Policy that grants an entity permission to assume the role"
  type        = string
}

# Optional variables
variable "name" {
  description = "Friendly name of the role. If omitted, Terraform will assign a random, unique name"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique friendly name beginning with the specified prefix. Conflicts with name"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "path" {
  description = "Path to the role"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^(/|(/[A-Za-z0-9\\+=,.@\\-_/]+/))$", var.path))
    error_message = "Path must begin and end with / and can contain alphanumeric characters and +=,.@-_ characters."
  }
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 and 43200 seconds (1 to 12 hours)."
  }
}

variable "permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the role"
  type        = string
  default     = null

  validation {
    condition = var.permissions_boundary == null || can(regex("^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:policy/", var.permissions_boundary))
    error_message = "Permissions boundary must be a valid IAM policy ARN."
  }
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = false
}

variable "managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the IAM role"
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for arn in var.managed_policy_arns : can(regex("^arn:aws[a-zA-Z-]*:iam::(aws|[0-9]{12}):policy/", arn))
    ])
    error_message = "All managed policy ARNs must be valid IAM policy ARNs."
  }
}

variable "inline_policies" {
  description = "Map of inline policies to attach to the role"
  type = map(object({
    policy = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, policy in var.inline_policies : can(jsondecode(policy.policy))
    ])
    error_message = "All inline policies must be valid JSON."
  }
}

variable "tags" {
  description = "Key-value mapping of tags for the IAM role"
  type        = map(string)
  default     = {}
}

# Enable/disable features
variable "create_role" {
  description = "Whether to create the IAM role"
  type        = bool
  default     = true
}

variable "create_instance_profile" {
  description = "Whether to create an instance profile for the role (useful for EC2)"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Name of the instance profile. If not provided, role name will be used"
  type        = string
  default     = null
}

variable "instance_profile_path" {
  description = "Path for the instance profile"
  type        = string
  default     = "/"
}
