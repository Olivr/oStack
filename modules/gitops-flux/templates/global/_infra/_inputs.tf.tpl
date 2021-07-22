# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------
variable "clusters" {
  description = "Clusters and their configuration."
  type = map(object({
    kube_host           = string
    kube_token          = string
    kube_ca_certificate = string
    base_dir            = string
    cluster_path        = string
    namespaces          = set(string)
    deploy_keys = map(object({
      name        = string
      namespace   = string
      known_hosts = string
      public_key  = string
      private_key = string
    }))
    secrets = map(object({
      name       = string
      namespace  = string
      data       = map(string)
    }))
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
    condition     = alltrue(flatten(
      [for sensitive_inputs in values(var.sensitive_inputs_per_cluster) :
        [for v in values(sensitive_inputs): v != null]
      ]
    ))
  }
}
