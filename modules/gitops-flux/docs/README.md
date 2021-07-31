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
| <a name="input_global"></a> [global](#input_global) | Global ops repo configuration. | <pre>object({<br> vcs = object({<br> provider = string<br> http_url = string<br> ssh_url = string<br> branch_default_name = string<br> })<br> backends = map(object({<br> combine_environments = bool<br> vcs_working_directory = string<br> }))<br> })</pre> | n/a | yes |
| <a name="input_namespaces"></a> [namespaces](#input_namespaces) | Namespaces to be used as isolated tenants. | <pre>map(object({<br> name = string<br> environments = set(string)<br> tenant_isolation = bool<br> repos = map(object({<br> name = string<br> type = string<br> vcs = object({<br> provider = string<br> http_url = string<br> ssh_url = string<br> branch_default_name = string<br> })<br> }))<br> }))</pre> | n/a | yes |
| <a name="input_base_dir"></a> [base_dir](#input_base_dir) | Name of the base directory. | `string` | `"_base"` | no |
| <a name="input_cluster_init_path"></a> [cluster_init_path](#input_cluster_init_path) | Path to the cluster init module directory if you'd rather use an inline module rather than an external one. | `string` | `null` | no |
| <a name="input_deploy_keys"></a> [deploy_keys](#input_deploy_keys) | Deploy keys to add to each cluster at bootstrap time. You can pass sensitive values by setting the `private_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs` (defined at run time in the infrastructure backend). | <pre>map(map(object({<br> name = string<br> namespace = string<br> known_hosts = string<br> private_key = string<br> public_key = string<br> })))</pre> | `{}` | no |
| <a name="input_infra_dir"></a> [infra_dir](#input_infra_dir) | Name of the infrastructure directory. | `string` | `"_init"` | no |
| <a name="input_init_cluster"></a> [init_cluster](#input_init_cluster) | Remote Terraform module used to bootstrap a cluster (superseeded by `cluster_init_path`). | <pre>object({<br> module_source = string<br> module_version = string<br> })</pre> | <pre>{<br> "module_source": "Olivr/init-cluster/flux",<br> "module_version": null<br>}</pre> | no |
| <a name="input_local_var_template"></a> [local_var_template](#input_local_var_template) | JSON Terraform variables template with empty values. | `string` | `""` | no |
| <a name="input_secrets"></a> [secrets](#input_secrets) | Secrets to add to each cluster at bootstrap time. You can pass sensitive values by setting the `private_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs` (defined at run time in the infrastructure backend). | <pre>map(map(object({<br> name = string<br> namespace = string<br> data = map(string)<br> })))</pre> | `{}` | no |
| <a name="input_tenants_dir"></a> [tenants_dir](#input_tenants_dir) | Name of the tenants directory. | `string` | `"tenants"` | no |

## Outputs

| Name | Description |
| --- | --- |
| <a name="output_global_files"></a> [global_files](#output_global_files) | Files to add to global ops repo. |
| <a name="output_global_files_strict"></a> [global_files_strict](#output_global_files_strict) | Files to add to global ops repo and that should be tracked for changes. |
| <a name="output_ns_files"></a> [ns_files](#output_ns_files) | Files to add to namespace ops repos. |
| <a name="output_ns_files_strict"></a> [ns_files_strict](#output_ns_files_strict) | Files to add to namespace ops repos and that should be tracked for changes. |

<!-- END_TF_DOCS -->
