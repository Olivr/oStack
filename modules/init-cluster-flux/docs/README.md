<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                        | Version  |
| --------------------------------------------------------------------------- | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | ~> 1.0   |
| <a name="requirement_kubectl"></a> [kubectl](#requirement_kubectl)          | >= 1.7.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | 2.3.2    |

## Providers

| Name                                                                  | Version  |
| --------------------------------------------------------------------- | -------- |
| <a name="provider_kubectl"></a> [kubectl](#provider_kubectl)          | >= 1.7.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | 2.3.2    |

## Modules

No modules.

## Resources

| Name | Type |
| --- | --- |
| [kubectl_manifest.install](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.sync](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.flux_system](https://registry.terraform.io/providers/hashicorp/kubernetes/2.3.2/docs/resources/namespace) | resource |
| [kubernetes_namespace.namespaces](https://registry.terraform.io/providers/hashicorp/kubernetes/2.3.2/docs/resources/namespace) | resource |
| [kubernetes_secret.deploy_keys](https://registry.terraform.io/providers/hashicorp/kubernetes/2.3.2/docs/resources/secret) | resource |
| [kubernetes_secret.secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/2.3.2/docs/resources/secret) | resource |
| [kubectl_file_documents.install](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.sync](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/file_documents) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_cluster_path"></a> [cluster_path](#input_cluster_path) | Path to synchronize Flux with this cluster | `string` | n/a | yes |
| <a name="input_base_dir"></a> [base_dir](#input_base_dir) | Name of the base directory. | `string` | `"_base"` | no |
| <a name="input_deploy_keys"></a> [deploy_keys](#input_deploy_keys) | Deploy keys to add. You can pass sensitive values by setting the `private_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`. | <pre>map(object({<br> name = string<br> namespace = string<br> known_hosts = string<br> private_key = string<br> public_key = string<br> }))</pre> | `{}` | no |
| <a name="input_namespaces"></a> [namespaces](#input_namespaces) | Namespaces to create | `set(string)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input_secrets) | Secrets to add. You can pass sensitive values by setting any value in `data` to `sensitive::key` where `key` refers to a value in `sensitive_inputs`. | <pre>map(object({<br> name = string<br> namespace = string<br> data = map(string)<br> }))</pre> | `{}` | no |
| <a name="input_sensitive_inputs"></a> [sensitive_inputs](#input_sensitive_inputs) | Values that should be marked as sensitive. Supported by `secrets`, `deploy_keys`. | `map(string)` | `{}` | no |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
