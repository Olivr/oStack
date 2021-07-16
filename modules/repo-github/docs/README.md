<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_github"></a> [github](#requirement_github)          | ~> 4.0  |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_github"></a> [github](#provider_github) | 4.12.2  |

## Modules

No modules.

## Resources

| Name | Type |
| --- | --- |
| [github_actions_secret.secret](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_branch_protection.branch](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_issue_label.labels](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/issue_label) | resource |
| [github_repository.repo](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_deploy_key.deploy_keys](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key) | resource |
| [github_repository_file.files](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.initial_files](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_team_repository.permissions](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_repository.repo](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_name"></a> [name](#input_name) | The name of the repository. | `string` | n/a | yes |
| <a name="input_allow_merge_commit"></a> [allow_merge_commit](#input_allow_merge_commit) | Allow merge commits. | `bool` | `true` | no |
| <a name="input_allow_rebase_merge"></a> [allow_rebase_merge](#input_allow_rebase_merge) | Allow rebase merge. | `bool` | `true` | no |
| <a name="input_allow_squash_merge"></a> [allow_squash_merge](#input_allow_squash_merge) | Allow squash merge. | `bool` | `true` | no |
| <a name="input_archive_on_destroy"></a> [archive_on_destroy](#input_archive_on_destroy) | Set to `true` to archive the repository instead of deleting on destroy. | `bool` | `false` | no |
| <a name="input_auto_init"></a> [auto_init](#input_auto_init) | Set to `true` to produce an initial commit in the repository. | `bool` | `false` | no |
| <a name="input_branch_delete_on_merge"></a> [branch_delete_on_merge](#input_branch_delete_on_merge) | Automatically delete branch after a pull request is merged. | `bool` | `false` | no |
| <a name="input_branch_protection"></a> [branch_protection](#input_branch_protection) | Enable branch protection. <br>For private repos, it is only available on the paid plan. | `bool` | `false` | no |
| <a name="input_branch_protection_enforce_admins"></a> [branch_protection_enforce_admins](#input_branch_protection_enforce_admins) | Enforce admins on branch protection. | `bool` | `true` | no |
| <a name="input_branch_review_count"></a> [branch_review_count](#input_branch_review_count) | Number of required reviews before merging pull requests. | `number` | `0` | no |
| <a name="input_branch_status_checks"></a> [branch_status_checks](#input_branch_status_checks) | List of status checks required before merging pull requests. | `list(string)` | `[]` | no |
| <a name="input_deploy_keys"></a> [deploy_keys](#input_deploy_keys) | Map of repository deploy keys. Set the `ssh_key` parameter to `null` to use the corresponding value in `sensitive_inputs` (store it in the format `my_key_ssh_key`). | <pre>map(object({<br> title = string<br> ssh_key = string<br> read_only = optional(bool)<br> }))</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input_description) | A description of the repository. | `string` | `null` | no |
| <a name="input_enable"></a> [enable](#input_enable) | Enable this module. If set to false, no resources will be created. | `bool` | `true` | no |
| <a name="input_files"></a> [files](#input_files) | Files to add to the repository's default branch. | `map(string)` | `{}` | no |
| <a name="input_has_issues"></a> [has_issues](#input_has_issues) | Set to `true` to enable the GitHub Issues features on the repository. | `bool` | `true` | no |
| <a name="input_has_projects"></a> [has_projects](#input_has_projects) | Set to `true` to enable the GitHub Projects features on the repository. | `bool` | `true` | no |
| <a name="input_has_wiki"></a> [has_wiki](#input_has_wiki) | Set to `true` to enable the GitHub Wiki features on the repository. | `bool` | `null` | no |
| <a name="input_homepage_url"></a> [homepage_url](#input_homepage_url) | URL of a page describing the project. | `string` | `null` | no |
| <a name="input_is_template"></a> [is_template](#input_is_template) | Repository is a template repository. | `bool` | `false` | no |
| <a name="input_issue_labels"></a> [issue_labels](#input_issue_labels) | Map of labels and their colors to add to the repository. <br>In the format { "label" = "#FFFFFF" } | `map(string)` | `{}` | no |
| <a name="input_private"></a> [private](#input_private) | Set to `true` to create a private repository. | `bool` | `true` | no |
| <a name="input_repo_exists"></a> [repo_exists](#input_repo_exists) | Set to `true` if the repository aalready exists. | `bool` | `false` | no |
| <a name="input_secrets"></a> [secrets](#input_secrets) | Pass secrets. Set a secret to null to use the sensitive_inputs value corresponding to its key. | `map(string)` | `{}` | no |
| <a name="input_sensitive_inputs"></a> [sensitive_inputs](#input_sensitive_inputs) | Pass sensitive inputs here. | `map(string)` | `{}` | no |
| <a name="input_team_permissions"></a> [team_permissions](#input_team_permissions) | Teams access levels. | <pre>object({<br> pull = optional(list(string))<br> triage = optional(list(string))<br> push = optional(list(string))<br> maintain = optional(list(string))<br> admin = optional(list(string))<br> })</pre> | `{}` | no |
| <a name="input_teams"></a> [teams](#input_teams) | Map of GitHub teams. | <pre>map(object({<br> id = string<br> node_id = string<br> }))</pre> | `{}` | no |
| <a name="input_template"></a> [template](#input_template) | Template to use when creating repository. | `string` | `null` | no |
| <a name="input_topics"></a> [topics](#input_topics) | The list of topics of the repository. | `set(string)` | `[]` | no |
| <a name="input_vulnerability_alerts"></a> [vulnerability_alerts](#input_vulnerability_alerts) | Set to `true` to enable security alerts for vulnerable dependencies. Enabling requires alerts to be enabled on the owner level. | `bool` | `null` | no |

## Outputs

| Name | Description |
| --- | --- |
| <a name="output_default_branch"></a> [default_branch](#output_default_branch) | Default branch. |
| <a name="output_full_name"></a> [full_name](#output_full_name) | Repository full name (with owner in path). |
| <a name="output_name"></a> [name](#output_name) | Repository name. |
| <a name="output_ui_url"></a> [ui_url](#output_ui_url) | URL to the repository on the web. |

<!-- END_TF_DOCS -->
