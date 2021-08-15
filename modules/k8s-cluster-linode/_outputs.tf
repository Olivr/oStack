# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "kube_config" {
  description = "Kubernetes credentials file."
  value       = base64decode(linode_lke_cluster.cluster.kubeconfig)
  sensitive   = true
}

output "kube_version" {
  description = "Kubernetes version."
  value       = linode_lke_cluster.cluster.k8s_version
}

output "ui_url" {
  description = "Management UI."
  value       = "https://cloud.linode.com/kubernetes/clusters/${linode_lke_cluster.cluster.id}/summary"
}

output "kube_host" {
  description = "Kubernetes server."
  value       = nonsensitive(one(local.kube_config.clusters).cluster.server)
}

output "kube_ca_certificate" {
  description = "Kubernetes certificate authority certificate (base64 encoded)."
  value       = one(local.kube_config.clusters).cluster.certificate-authority-data
  sensitive   = true
}

output "kube_token" {
  description = "Kubernetes authentication token."
  value       = one(local.kube_config.users).user.token
  sensitive   = true
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  kube_config = yamldecode(base64decode(linode_lke_cluster.cluster.kubeconfig))
}
