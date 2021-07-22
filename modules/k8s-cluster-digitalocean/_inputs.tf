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
  description = "Region name ([available choices](https://developers.digitalocean.com/documentation/v2/#list-available-regions--node-sizes--and-versions-of-kubernetes))."
  type        = string
  default     = "nyc1"
}

variable "nodes" {
  description = "Map of node types and their associated count ([available choices](https://developers.digitalocean.com/documentation/v2/#list-available-regions--node-sizes--and-versions-of-kubernetes))."
  type        = map(number)
  default = {
    "s-1vcpu-2gb" = 1
  }
}

variable "kube_version" {
  description = "Kubernetes version ([available choices](https://developers.digitalocean.com/documentation/v2/#list-available-regions--node-sizes--and-versions-of-kubernetes))."
  type        = string
  default     = "1.21"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = set(string)
  default     = []
}

variable "auto_upgrade" {
  description = "Auto-upgrade patch versions."
  type        = bool
  default     = true
}
