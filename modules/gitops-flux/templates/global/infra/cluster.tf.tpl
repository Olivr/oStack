provider "kubectl" {
  alias                  = "${cluster}"
  host                   = var.clusters["${cluster}"].kube_host
  cluster_ca_certificate = base64decode(var.clusters["${cluster}"].kube_ca_certificate)
  load_config_file       = false
  token                  = can(regex("^sensitive::", var.clusters["${cluster}"].kube_token)
    ) ? (sensitive(var.sensitive_inputs_per_cluster["${cluster}"][trimprefix(var.clusters["${cluster}"].kube_token, "sensitive::")])
    ) : (var.clusters["${cluster}"].kube_token
  )
}

module "${cluster}" {
  source = "${module_source}"
  providers = {
    kubectl    = kubectl.${cluster}
  }

  base_dir         = "${base_dir}"
  base_path        = "${base_path}"
  cluster_path     = "${cluster_path}"
  deploy_keys      = ${deploy_keys}
  secrets          = ${secrets}
  namespaces       = ["${namespaces}"]
  sensitive_inputs = var.sensitive_inputs_per_cluster["${cluster}"]
}
