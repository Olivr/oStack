<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                              | Version |
| --------------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)          | ~> 1.0  |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement_digitalocean) | 2.10.1  |

## Providers

| Name                                                                        | Version |
| --------------------------------------------------------------------------- | ------- |
| <a name="provider_digitalocean"></a> [digitalocean](#provider_digitalocean) | 2.10.1  |

## Modules

No modules.

## Resources

| Name | Type |
| --- | --- |
| [digitalocean_kubernetes_cluster.cluster](https://registry.terraform.io/providers/digitalocean/digitalocean/2.10.1/docs/resources/kubernetes_cluster) | resource |
| [digitalocean_kubernetes_versions.cluster](https://registry.terraform.io/providers/digitalocean/digitalocean/2.10.1/docs/data-sources/kubernetes_versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_name"></a> [name](#input_name) | Cluster name. | `string` | n/a | yes |
| <a name="input_auto_upgrade"></a> [auto_upgrade](#input_auto_upgrade) | Auto-upgrade patch versions. | `bool` | `true` | no |
| <a name="input_kube_version"></a> [kube_version](#input_kube_version) | Kubernetes version ([available choices](https://developers.digitalocean.com/documentation/v2/#list-available-regions--node-sizes--and-versions-of-kubernetes)). | `string` | `"1.21"` | no |
| <a name="input_nodes"></a> [nodes](#input_nodes) | Map of node types and their associated count ([available choices](https://developers.digitalocean.com/documentation/v2/#list-available-regions--node-sizes--and-versions-of-kubernetes)). | `map(number)` | <pre>{<br> "s-1vcpu-2gb": 1<br>}</pre> | no |
| <a name="input_region"></a> [region](#input_region) | Region name ([available choices](https://developers.digitalocean.com/documentation/v2/#list-available-regions--node-sizes--and-versions-of-kubernetes)). | `string` | `"nyc1"` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags applied to all resources. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
| --- | --- |
| <a name="output_kube_ca_certificate"></a> [kube_ca_certificate](#output_kube_ca_certificate) | Kubernetes certificate authority certificate. |
| <a name="output_kube_config"></a> [kube_config](#output_kube_config) | Kubernetes credentials file. |
| <a name="output_kube_host"></a> [kube_host](#output_kube_host) | Kubernetes server. |
| <a name="output_kube_token"></a> [kube_token](#output_kube_token) | Kubernetes authentication token. |
| <a name="output_kube_version"></a> [kube_version](#output_kube_version) | Kubernetes version. |
| <a name="output_ui_url"></a> [ui_url](#output_ui_url) | Management UI. |

<!-- END_TF_DOCS -->
