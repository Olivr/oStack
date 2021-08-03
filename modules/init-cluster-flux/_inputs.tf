# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "cluster_path" {
  description = "Path to synchronize Flux with this cluster"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional inputs
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "namespaces" {
  description = "Namespaces to create"
  type        = list(string)
  default     = []
}

variable "deploy_keys" {
  description = "Deploy keys to add. You can pass sensitive values by setting the `private_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`."
  type = map(object({
    name        = string
    namespace   = string
    known_hosts = string
    private_key = string
    public_key  = string
  }))
  default = {}
}

variable "secrets" {
  description = "Secrets to add. You can pass sensitive values by setting any value in `data` to `sensitive::key` where `key` refers to a value in `sensitive_inputs`."
  type = map(object({
    name      = string
    namespace = string
    data      = map(string)
  }))
  default = {}
}

variable "base_dir" {
  description = "Name of the base directory."
  type        = string
  default     = "base"
}

variable "base_path" {
  description = "Path to the base directory relative to the current Terraform configuration root."
  type        = string
  default     = ".."
}

variable "sensitive_inputs" {
  description = "Values that should be marked as sensitive. Supported by `secrets`, `deploy_keys`."
  type        = map(string)
  sensitive   = true
  default     = {}
  validation {
    error_message = "Variable sensitive_inputs cannot be null."
    condition     = var.sensitive_inputs != null
  }
  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition     = alltrue([for v in values(var.sensitive_inputs) : v != null])
  }
}
