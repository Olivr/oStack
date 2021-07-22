<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_flux"></a> [flux](#requirement_flux)                | 0.1.10  |

## Providers

| Name                                                | Version |
| --------------------------------------------------- | ------- |
| <a name="provider_flux"></a> [flux](#provider_flux) | 0.1.10  |

## Modules

No modules.

## Resources

| Name | Type |
| --- | --- |
| [flux_install.main](https://registry.terraform.io/providers/fluxcd/flux/0.1.10/docs/data-sources/install) | data source |
| [flux_sync.main](https://registry.terraform.io/providers/fluxcd/flux/0.1.10/docs/data-sources/sync) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_environments"></a> [environments](#input_environments) | Clusters per environments. | <pre>map(object({<br> name = string<br> clusters = map(object({<br> name = string<br> }))<br> }))</pre> | n/a | yes |
| <a name="input_global"></a> [global](#input_global) | Global ops repo configuration. | <pre>object({<br> provider = string<br> http_url = string<br> ssh_url = string<br> branch_default_name = string<br> })</pre> | n/a | yes |
| <a name="input_namespaces"></a> [namespaces](#input_namespaces) | Namespaces to be used as isolated tenants. | <pre>map(object({<br> name = string<br> environments = set(string)<br> repos = map(object({<br> name = string<br> type = string<br> vcs = object({<br> provider = string<br> http_url = string<br> ssh_url = string<br> branch_default_name = string<br> })<br> }))<br> }))</pre> | n/a | yes |
| <a name="input_base_dir"></a> [base_dir](#input_base_dir) | Name of the base directory. | `string` | `"_base"` | no |
| <a name="input_cluster_init_module"></a> [cluster_init_module](#input_cluster_init_module) | Remote Terraform module used to bootstrap a cluster (superseeded by `cluster_init_path`). | `string` | `"Olivr/init-cluster/flux"` | no |
| <a name="input_cluster_init_path"></a> [cluster_init_path](#input_cluster_init_path) | Path to the cluster init module directory if you'd rather use an inline module rather than an external one. | `string` | `null` | no |
| <a name="input_infra_dir"></a> [infra_dir](#input_infra_dir) | Name of the infrastructure directory. | `string` | `"_infra"` | no |
| <a name="input_tenants_dir"></a> [tenants_dir](#input_tenants_dir) | Name of the tenants directory. | `string` | `"tenants"` | no |

## Outputs

| Name | Description |
| --- | --- |
| <a name="output_global_files"></a> [global_files](#output_global_files) | Files to add to global ops repo. |
| <a name="output_ns_files"></a> [ns_files](#output_ns_files) | Files to add to namespace ops repos. |

<!-- END_TF_DOCS -->
