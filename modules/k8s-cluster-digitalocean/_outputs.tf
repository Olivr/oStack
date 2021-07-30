# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "kube_config" {
  description = "Kubernetes credentials file."
  value       = digitalocean_kubernetes_cluster.cluster.kube_config[0].raw_config
  sensitive   = true
}

output "kube_version" {
  description = "Kubernetes version."
  value       = digitalocean_kubernetes_cluster.cluster.version
}

output "ui_url" {
  description = "Management UI."
  value       = "https://cloud.digitalocean.com/kubernetes/clusters/${digitalocean_kubernetes_cluster.cluster.id}"
}

output "kube_host" {
  description = "Kubernetes server."
  value       = digitalocean_kubernetes_cluster.cluster.endpoint
}

output "kube_ca_certificate" {
  description = "Kubernetes certificate authority certificate."
  value       = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  sensitive   = true
}

output "kube_token" {
  description = "Kubernetes authentication token."
  value       = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  sensitive   = true
}
