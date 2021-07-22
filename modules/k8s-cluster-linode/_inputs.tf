# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "Cluster name."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional inputs
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  description = "Region name ([available choices](https://developers.linode.com/api/v4/regions))."
  type        = string
  default     = "us-central"
}

variable "nodes" {
  description = "Map of node types and their associated count ([available choices](https://api.linode.com/v4/linode/types)). \nEg. { \"g6-standard-1\" = 12,  \"g6-standard-4\" = 3 }"
  type        = map(number)
  default = {
    "g6-standard-1" = 1
  }
}

variable "kube_version" {
  description = "Kubernetes version ([available choices](https://developers.linode.com/api/v4/lke-versions))."
  type        = string
  default     = "1.21"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = set(string)
  default     = []
}
