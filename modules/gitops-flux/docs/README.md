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
| <a name="input_environments"></a> [environments](#input_environments) | Environments and their clusters. | <pre>map(object({<br> name = string<br> clusters = map(object({<br> name = string<br> bootstrap = bool<br> gpg_fingerprint = string<br> gpg_public_key = string<br> }))<br> }))</pre> | n/a | yes |
| <a name="input_repo_ssh_url"></a> [repo_ssh_url](#input_repo_ssh_url) | SSH URL for cloning the repository. | `string` | n/a | yes |
| <a name="input_tenants"></a> [tenants](#input_tenants) | Tenants and their repos. | <pre>map(object({<br> name = string<br> environments = set(string)<br> repos = map(object({<br> name = string<br> type = string<br> vcs = object({<br> provider = string<br> repo_http_url = string<br> repo_ssh_url = string<br> branch_default_name = string<br> })<br> }))<br> }))</pre> | n/a | yes |
| <a name="input_base_dir"></a> [base_dir](#input_base_dir) | Name of the base directory where contributors must place their base files. | `string` | `"_base"` | no |
| <a name="input_branch_name"></a> [branch_name](#input_branch_name) | Main repository branch name. | `string` | `"main"` | no |
| <a name="input_cluster_init_path"></a> [cluster_init_path](#input_cluster_init_path) | Path to the cluster init module directory if you'd rather use an inline module rather than an external one. | `string` | `null` | no |
| <a name="input_commit_status_http_url"></a> [commit_status_http_url](#input_commit_status_http_url) | HTTP URL of the repository. | `string` | `null` | no |
| <a name="input_commit_status_provider"></a> [commit_status_provider](#input_commit_status_provider) | Name of the VCS provider (used to define if Flux can send commit statuses). | `string` | `null` | no |
| <a name="input_deploy_keys"></a> [deploy_keys](#input_deploy_keys) | Deploy keys to add to each cluster at bootstrap time. You can pass sensitive values by setting the `private_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs` (defined at run time in the infrastructure backend). | <pre>map(map(object({<br> name = string<br> namespace = string<br> known_hosts = string<br> private_key = string<br> public_key = string<br> })))</pre> | `{}` | no |
| <a name="input_infra_dir"></a> [infra_dir](#input_infra_dir) | Name of the infrastructure directory. | `string` | `"_init"` | no |
| <a name="input_init_cluster"></a> [init_cluster](#input_init_cluster) | Remote Terraform module used to bootstrap a cluster (superseeded by `cluster_init_path`). | <pre>object({<br> module_source = string<br> module_version = string<br> })</pre> | <pre>{<br> "module_source": "Olivr/init-cluster/flux",<br> "module_version": null<br>}</pre> | no |
| <a name="input_local_var_template"></a> [local_var_template](#input_local_var_template) | JSON Terraform variables template with empty values. | `string` | `""` | no |
| <a name="input_overlay_dir"></a> [overlay_dir](#input_overlay_dir) | Name of the overlay directory where contributors must place their overlay files. | `string` | `"_overlays"` | no |
| <a name="input_secrets"></a> [secrets](#input_secrets) | Secrets to add to each cluster at bootstrap time. You can pass sensitive values by setting the `private_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs` (defined at run time in the infrastructure backend). | <pre>map(map(object({<br> name = string<br> namespace = string<br> data = map(string)<br> })))</pre> | `{}` | no |
| <a name="input_system_dir"></a> [system_dir](#input_system_dir) | Name of the system directory. | `string` | `"_ostack"` | no |
| <a name="input_tenants_dir"></a> [tenants_dir](#input_tenants_dir) | Name of the tenants directory. | `string` | `"tenants"` | no |

## Outputs

| Name | Description |
| --- | --- |
| <a name="output_repo_files"></a> [repo_files](#output_repo_files) | Files to add to the main repo. These are files that are expected to be modified by collaborators. |
| <a name="output_repo_system_files"></a> [repo_system_files](#output_repo_system_files) | Files to add to the main repo. These are files that are not expected to be modified by collaborators. |
| <a name="output_tenants_files"></a> [tenants_files](#output_tenants_files) | Files to add to namespace ops repos. These are files that are expected to be modified by collaborators. |
| <a name="output_tenants_system_files"></a> [tenants_system_files](#output_tenants_system_files) | System files to add to tenant repos. These are files that are not expected to be modified by collaborators. |

<!-- END_TF_DOCS -->
