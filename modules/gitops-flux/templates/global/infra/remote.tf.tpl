# ---------------------------------------------------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.0"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubectl" {
  host                   = var.kube_host
  token                  = var.kube_token
  cluster_ca_certificate = base64decode(var.kube_ca_certificate)
  load_config_file       = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------------------------------------------------
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

variable "kube_host" {
  description = "Kubernetes host to connect to."
  type        = string
  validation {
    error_message = "Variable kube_host cannot be null."
    condition     = var.kube_host != null
  }
}

variable "kube_ca_certificate" {
  description = "Kubernetes host certificate (base64 encoded)."
  type        = string
  validation {
    error_message = "Variable kube_ca_certificate cannot be null."
    condition     = var.kube_ca_certificate != null
  }
}

variable "kube_token" {
  description = "Kubernetes token."
  type        = string
  sensitive   = true
  validation {
    error_message = "Variable kube_token cannot be null."
    condition     = var.kube_token != null
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "bootstrap" {
  source = "${module_source}"

  base_dir         = "${base_dir}"
  base_path        = "${base_path}"
  cluster_path     = "${cluster_path}"
  deploy_keys      = ${deploy_keys}
  secrets          = ${secrets}
  namespaces       = ["${namespaces}"]
  sensitive_inputs = var.sensitive_inputs
}
