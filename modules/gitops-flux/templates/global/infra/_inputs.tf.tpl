# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------
variable "clusters" {
  description = "Clusters and their configuration. Certificate must be base64 encoded."
  type = map(object({
    kube_host           = string
    kube_token          = string
    kube_ca_certificate = string
  }))
}

variable "sensitive_inputs_per_cluster" {
  description = "Values that should be marked as sensitive, per cluster. Supported by `kube_token` (clusters), `private_key` (clusters deploy keys)."
  type        = map(map(string))
  sensitive   = true
  default     = {}
  validation {
    error_message = "Variable sensitive_inputs_per_cluster cannot be null."
    condition     = var.sensitive_inputs_per_cluster != null
  }
  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition = alltrue(flatten(
      [for sensitive_inputs in values(var.sensitive_inputs_per_cluster) :
        [for v in values(sensitive_inputs) : v != null]
      ]
    ))
  }
}
