<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_linode"></a> [linode](#requirement_linode)          | ~> 1.18 |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_linode"></a> [linode](#provider_linode) | 1.19.1  |

## Modules

No modules.

## Resources

| Name | Type |
| --- | --- |
| [linode_lke_cluster.cluster](https://registry.terraform.io/providers/linode/linode/latest/docs/resources/lke_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_name"></a> [name](#input_name) | Cluster name. | `string` | n/a | yes |
| <a name="input_kube_version"></a> [kube_version](#input_kube_version) | Kubernetes version ([available choices](https://developers.linode.com/api/v4/lke-versions)). | `string` | `"1.21"` | no |
| <a name="input_nodes"></a> [nodes](#input_nodes) | Map of node types and their associated count ([available choices](https://api.linode.com/v4/linode/types)). <br>Eg. { "g6-standard-1" = 12, "g6-standard-4" = 3 } | `map(number)` | <pre>{<br> "g6-standard-1": 1<br>}</pre> | no |
| <a name="input_region"></a> [region](#input_region) | Region name ([available choices](https://developers.linode.com/api/v4/regions)). | `string` | `"us-central"` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags applied to all resources. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
| --- | --- |
| <a name="output_kube_ca_certificate"></a> [kube_ca_certificate](#output_kube_ca_certificate) | Kubernetes certificate authority certificate (base64 encoded). |
| <a name="output_kube_config"></a> [kube_config](#output_kube_config) | Kubernetes credentials file. |
| <a name="output_kube_host"></a> [kube_host](#output_kube_host) | Kubernetes server. |
| <a name="output_kube_token"></a> [kube_token](#output_kube_token) | Kubernetes authentication token. |
| <a name="output_kube_version"></a> [kube_version](#output_kube_version) | Kubernetes version. |
| <a name="output_ui_url"></a> [ui_url](#output_ui_url) | Management UI. |

<!-- END_TF_DOCS -->
