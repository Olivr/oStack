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

variable "gpg_key_private_sops" {
  description = "GPG private key for sops."
  type        = string
  sensitive   = true
}

%{ for provider in vcs_providers ~}
variable "ssh_key_private_${provider}" {
  description = "SSH private key for accessing ${provider} repos."
  type        = string
  sensitive   = true
}

variable "ssh_key_public_${provider}" {
  description = "SSH public key for accessing ${provider} repos."
  type        = string
}
%{ endfor ~}

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
  secrets          = ${secrets}
  # Unlike the live clusters, we do not pass the VCS tokens used by Flux Notifications API to update the status of each commit.
  # You might see some errors related to this in your local cluster, you can safely ignore them. The 3 reasons for this are:
  # 1. Local commits won't benefit from this anyway
  # 2. We don't want to pollute existing notifications channels with errors happenning on your local cluster
  # 3. These are tokens with write permissions to all repos and we dont want them laying around non-encrypted
}
