<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0   |
| <a name="requirement_gpg"></a> [gpg](#requirement_gpg)                   | ~> 0.1.0 |
| <a name="requirement_tls"></a> [tls](#requirement_tls)                   | ~> 3.1.0 |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_gpg"></a> [gpg](#provider_gpg) | 0.1.0   |
| <a name="provider_tls"></a> [tls](#provider_tls) | 3.1.0   |

## Modules

| Name | Source | Version |
| --- | --- | --- |
| <a name="module_backends_globalops_tfe"></a> [backends_globalops_tfe](#module_backends_globalops_tfe) | ../backend-tfe | n/a |
| <a name="module_backends_namespaces_tfe"></a> [backends_namespaces_tfe](#module_backends_namespaces_tfe) | ../backend-tfe | n/a |
| <a name="module_cloud_clusters_k8s_digitalocean"></a> [cloud_clusters_k8s_digitalocean](#module_cloud_clusters_k8s_digitalocean) | ../k8s-cluster-digitalocean | n/a |
| <a name="module_cloud_clusters_k8s_linode"></a> [cloud_clusters_k8s_linode](#module_cloud_clusters_k8s_linode) | ../k8s-cluster-linode | n/a |
| <a name="module_gitops_flux"></a> [gitops_flux](#module_gitops_flux) | ../gitops-flux | n/a |
| <a name="module_vcs_repo_globalconfig_github"></a> [vcs_repo_globalconfig_github](#module_vcs_repo_globalconfig_github) | ../repo-github | n/a |
| <a name="module_vcs_repo_globalinfra_github"></a> [vcs_repo_globalinfra_github](#module_vcs_repo_globalinfra_github) | ../repo-github | n/a |
| <a name="module_vcs_repo_globalops_github"></a> [vcs_repo_globalops_github](#module_vcs_repo_globalops_github) | ../repo-github | n/a |
| <a name="module_vcs_repos_namespaces_github"></a> [vcs_repos_namespaces_github](#module_vcs_repos_namespaces_github) | ../repo-github | n/a |
| <a name="module_vcs_teams_github"></a> [vcs_teams_github](#module_vcs_teams_github) | ../teams-github | n/a |

## Resources

| Name | Type |
| --- | --- |
| [gpg_private_key.cluster_keys](https://registry.terraform.io/providers/Olivr/gpg/latest/docs/resources/private_key) | resource |
| [tls_private_key.ci_keys](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.cluster_keys](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.ns_keys](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_cloud_default_provider"></a> [cloud_default_provider](#input_cloud_default_provider) | Default cloud provider. | `string` | n/a | yes |
| <a name="input_organization_name"></a> [organization_name](#input_organization_name) | Computer-friendly organization name (eg. my-startup).<br>Use only letters, numbers and dashes to maximize compatibility across every system. | `string` | n/a | yes |
| <a name="input_vcs_write_token"></a> [vcs_write_token](#input_vcs_write_token) | VCS token with write access, per VCS provider.<br>Used for updating commit statuses in GitOps and is also added as a secret to each repo for automerge.<br>This behaviour can be overriden in `repo_secrets` in `vcs_config_base` or per repo in `namespaces`. | `map(string)` | n/a | yes |
| <a name="input_backend_config_base"></a> [backend_config_base](#input_backend_config_base) | Base backend configuration per provider. | <pre>map(object({<br> allow_destroy_plan = optional(bool)<br> separate_environments = optional(bool)<br> env_vars = optional(map(string))<br> speculative_enabled = optional(bool)<br> tf_vars = optional(map(string))<br> tf_vars_hcl = optional(map(string))<br> tfe_oauth_token_id = optional(string)<br> }))</pre> | <pre>{<br> "tfe": {}<br>}</pre> | no |
| <a name="input_backend_default_provider"></a> [backend_default_provider](#input_backend_default_provider) | Default backend provider. | `string` | `"tfe"` | no |
| <a name="input_backend_organization_name"></a> [backend_organization_name](#input_backend_organization_name) | Backend organization name. | `string` | `null` | no |
| <a name="input_cloud_cluster_config_base"></a> [cloud_cluster_config_base](#input_cloud_cluster_config_base) | Base cluster configuration per cloud provider. | <pre>map(object({<br> autoscale = optional(bool)<br> kube_version = optional(string)<br> nodes = optional(map(number))<br> region = optional(string)<br> tags = optional(set(string))<br> }))</pre> | `{}` | no |
| <a name="input_continuous_delivery"></a> [continuous_delivery](#input_continuous_delivery) | Should continuous delivery be applied by default. This applies to all aspects of the stack (devops, gitops, iac). | `bool` | `true` | no |
| <a name="input_dev_mode"></a> [dev_mode](#input_dev_mode) | For expert users or oStack developers. Set it to a map of dev settings to use it. | `map(any)` | `null` | no |
| <a name="input_environments"></a> [environments](#input_environments) | Environment names and their optional configuration.<br>Each environment contains one or more Kubernetes clusters.<br>If you want to later rename your environments, do not change the key name or Terraform will destroy it and create a new one from scratch which will have dramatic effects on your deployments.<br>For this reason, it is recommended to use generic key names for both environments and clusters, you can name both by using the `name` parameter.<br>By default a staging environment is created with one cluster using the default cluster configuration on your default cloud provider | <pre>map(object({<br> name = optional(string)<br> promotion_order = optional(number)<br> continuous_delivery = optional(bool)<br> clusters = map(object({<br> name = optional(string)<br> autoscale = optional(bool)<br> create = optional(bool)<br> gpg_fingerprint = optional(string)<br> gpg_public_key = optional(string)<br> kube_version = optional(string)<br> nodes = optional(map(number))<br> provider = optional(string)<br> region = optional(string)<br> tags = optional(set(string))<br> kube_config = optional(object({<br> ca_certificate = string<br> host = string<br> token = string<br> }))<br> }))<br> }))</pre> | <pre>{<br> "stage": {<br> "clusters": {<br> "cluster1": {}<br> },<br> "name": "staging"<br> }<br>}</pre> | no |
| <a name="input_gitops_config_base"></a> [gitops_config_base](#input_gitops_config_base) | Base GitOps configuration per provider. | <pre>map(object({<br> base_dir = optional(string)<br> init_cluster = optional(object({<br> module_source = optional(string)<br> module_version = optional(string)<br> }))<br> }))</pre> | <pre>{<br> "flux": {}<br>}</pre> | no |
| <a name="input_gitops_default_provider"></a> [gitops_default_provider](#input_gitops_default_provider) | Default GitOps provider. | `string` | `"flux"` | no |
| <a name="input_globalinfra_backend_workspace_name"></a> [globalinfra_backend_workspace_name](#input_globalinfra_backend_workspace_name) | Name of the global infra backend workspace name so that oStack can propagate backend runs.<br>This is used because Terraform Cloud won't trigger a run when variables values change, but oStack needs to in order to keep the configuration up to date!<br>It must be created already on the default backend provider.<br>Set to `null` if you don't want runs to propagate. | `string` | `null` | no |
| <a name="input_globalinfra_vcs_repo_name"></a> [globalinfra_vcs_repo_name](#input_globalinfra_vcs_repo_name) | Name of the global infra repo so that oStack can apply its settings to it (eg. branch protection, team access)<br>It must be created already on the default VCS provider.<br>Set to `null` if you don't want oStack to manage this repo at all. | `string` | `null` | no |
| <a name="input_lang"></a> [lang](#input_lang) | Translation file to use. This can be one of the bundled translations of oStack or a custom translation object.<br>This can be used to overwrite how things are called throughout your stack. | `any` | `"en"` | no |
| <a name="input_namespaces"></a> [namespaces](#input_namespaces) | Namespaces and their optional configuration.<br>A namespace can be a project or a group of projects (if using a monorepo structure).<br>By default a namespace called "Main" will be created.<br>If you want to later rename your namespaces, do not change the key name or Terraform will destroy it and create a new one from scratch which will have dramatic effects on your repos.<br>For this reason, it is recommended to use generic key names such as ns1, ns2.<br>By default a main namespace will be created with a typical repo structure (infra/apps/ops). | <pre>map(object({<br> title = string<br> name = optional(string)<br> description = optional(string)<br> environments = optional(list(string))<br> repos = map(object({<br> type = string<br> name = optional(string)<br> description = optional(string)<br> continuous_delivery = optional(bool)<br> backend = optional(object({<br> allow_destroy_plan = optional(bool)<br> create = optional(bool)<br> env_vars = optional(map(string))<br> provider = optional(string)<br> separate_environments = optional(bool)<br> speculative_enabled = optional(bool)<br> tf_vars = optional(map(string))<br> tf_vars_hcl = optional(map(string))<br> tfe_oauth_token_id = optional(string)<br> }))<br> vcs = optional(object({<br> branch_default_name = optional(string)<br> branch_delete_on_merge = optional(bool)<br> branch_protection = optional(bool)<br> branch_protection_enforce_admins = optional(bool)<br> branch_review_count = optional(number)<br> branch_status_checks = optional(list(string))<br> create = optional(bool)<br> file_templates = optional(map(string))<br> files = optional(map(string))<br> files_strict = optional(map(string))<br> provider = optional(string)<br> repo_allow_merge_commit = optional(bool)<br> repo_allow_rebase_merge = optional(bool)<br> repo_allow_squash_merge = optional(bool)<br> repo_archive_on_destroy = optional(bool)<br> repo_auto_init = optional(bool)<br> repo_enable_issues = optional(bool)<br> repo_enable_projects = optional(bool)<br> repo_enable_wikis = optional(bool)<br> repo_homepage_url = optional(string)<br> repo_is_template = optional(bool)<br> repo_issue_labels = optional(map(string))<br> repo_private = optional(bool)<br> repo_secrets = optional(map(string))<br> repo_template = optional(string)<br> repo_vulnerability_alerts = optional(bool)<br> tags = optional(set(string))<br> }))<br> }))<br> }))</pre> | <pre>{<br> "ns1": {<br> "repos": {<br> "apps": {<br> "type": "apps"<br> },<br> "infra": {<br> "type": "infra"<br> },<br> "ops": {<br> "type": "ops"<br> }<br> },<br> "title": "Main"<br> }<br>}</pre> | no |
| <a name="input_organization_title"></a> [organization_title](#input_organization_title) | Human-friendly organization title (eg. My Startup). | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input_prefix) | Prefix to prepend to all generated resource names. It is not applied wherever you specify resource names explicitly. | `string` | `""` | no |
| <a name="input_sensitive_inputs"></a> [sensitive_inputs](#input_sensitive_inputs) | Values that should be marked as sensitive.<br>Supported by `repo_secrets` (vcs), `env_vars` (backend), `tf_vars` (backend), `tf_vars_hcl` (backend), `kube_config` (cluster). | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to be applied to all resources that support it. It is not applied wherever you specify resource tags explicitly. | `set(string)` | <pre>[<br> "oStack"<br>]</pre> | no |
| <a name="input_vcs_config_base"></a> [vcs_config_base](#input_vcs_config_base) | Base VCS configuration per provider. | <pre>map(object({<br> branch_default_name = optional(string)<br> branch_delete_on_merge = optional(bool)<br> branch_protection = optional(bool)<br> branch_protection_enforce_admins = optional(bool)<br> branch_review_count = optional(number)<br> branch_status_checks = optional(set(string))<br> file_templates = optional(map(string))<br> files = optional(map(string))<br> files_strict = optional(map(string))<br> repo_allow_merge_commit = optional(bool)<br> repo_allow_rebase_merge = optional(bool)<br> repo_allow_squash_merge = optional(bool)<br> repo_archive_on_destroy = optional(bool)<br> repo_auto_init = optional(bool)<br> repo_enable_issues = optional(bool)<br> repo_enable_projects = optional(bool)<br> repo_enable_wikis = optional(bool)<br> repo_homepage_url = optional(string)<br> repo_is_template = optional(bool)<br> repo_issue_labels = optional(map(string))<br> repo_private = optional(bool)<br> repo_secrets = optional(map(string))<br> repo_vulnerability_alerts = optional(bool)<br> tags = optional(set(string))<br> repo_templates = optional(object({<br> apps = optional(string)<br> globalconfig = optional(string)<br> globalops = optional(string)<br> infra = optional(string)<br> ops = optional(string)<br> }))<br> }))</pre> | `{}` | no |
| <a name="input_vcs_default_provider"></a> [vcs_default_provider](#input_vcs_default_provider) | Default VCS provider. | `string` | `"github"` | no |
| <a name="input_vcs_organization_name"></a> [vcs_organization_name](#input_vcs_organization_name) | VCS Organization name. | `string` | `null` | no |

## Outputs

| Name | Description |
| --- | --- |
| <a name="output_environments"></a> [environments](#output_environments) | Full configuration for each environment. |
| <a name="output_globalconfig"></a> [globalconfig](#output_globalconfig) | Global configuration repo(s). |
| <a name="output_globalconfig_files"></a> [globalconfig_files](#output_globalconfig_files) | Global configuration repo(s) files. |
| <a name="output_globalconfig_files_strict"></a> [globalconfig_files_strict](#output_globalconfig_files_strict) | Global configuration repo(s) strictly tracked files. |
| <a name="output_globalops"></a> [globalops](#output_globalops) | Global operations repo configuration. |
| <a name="output_globalops_files"></a> [globalops_files](#output_globalops_files) | Global operations repo files. |
| <a name="output_globalops_files_strict"></a> [globalops_files_strict](#output_globalops_files_strict) | Global operations repo strictly tracked files. |
| <a name="output_namespaces"></a> [namespaces](#output_namespaces) | Full configuration for all namespaces. |
| <a name="output_namespaces_files"></a> [namespaces_files](#output_namespaces_files) | Namespaces files are in a separate output for easier readability of the main `namespaces` output. |
| <a name="output_namespaces_files_strict"></a> [namespaces_files_strict](#output_namespaces_files_strict) | Namespaces files are in a separate output for easier readability of the main `namespaces` output. |
| <a name="output_sensitive_outputs"></a> [sensitive_outputs](#output_sensitive_outputs) | Sensitive outputs. |
| <a name="output_teams_flat"></a> [teams_flat](#output_teams_flat) | Teams created, per provider in flat format. |
| <a name="output_teams_tree"></a> [teams_tree](#output_teams_tree) | Teams created, per provider in hierarchical format. |

<!-- END_TF_DOCS -->
