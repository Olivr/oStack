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

provider "kubectl" {}

# ---------------------------------------------------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------------------------------------------------
variable "cluster_path" {
  description = "Cluster path, relative to root of the repository."
  type        = string
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

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "bootstrap" {
  source = "${module_source}"

  base_dir         = "${base_dir}"
  base_path        = "../../.."
  cluster_path     = var.cluster_path
  deploy_keys      = ${deploy_keys}
  namespaces       = ["${namespaces}"]
  sensitive_inputs = var.sensitive_inputs # You should fill the corresponding values in terraform.tfvars.json
  secrets          = {}
  # Unlike the remote clusters, we do not pass the VCS tokens used by Flux Notifications API to update the status of each commit.
  # You might see some errors related to this in your local cluster, you can safely ignore them. The 3 reasons for this are:
  # 1. Local commits won't benefit from this anyway
  # 2. We don't want to pollute existing notifications channels with errors happenning on your local cluster
  # 3. These are tokens with write permissions to all repos and we dont want them laying around non-encrypted
}
