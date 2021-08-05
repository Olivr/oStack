# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "Name of the key to generate."
  type        = string

  validation {
    error_message = "GPG key name cannot be left empty."
    condition     = var.name != null && var.name != ""
  }
}

variable "key_length" {
  description = "Key length."
  type        = number
  default     = 4096

  validation {
    error_message = "GPG key length cannot be null."
    condition     = var.key_length != null
  }
}

variable "comment" {
  description = "Comment to add to the key."
  type        = string
  default     = ""

  validation {
    error_message = "GPG key comment cannot be null."
    condition     = var.comment != null
  }
}
