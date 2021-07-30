<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0    |
| <a name="requirement_tfe"></a> [tfe](#requirement_tfe)                   | ~> 0.25.0 |

## Providers

| Name                                             | Version   |
| ------------------------------------------------ | --------- |
| <a name="provider_tfe"></a> [tfe](#provider_tfe) | ~> 0.25.0 |

## Modules

No modules.

## Resources

| Name | Type |
| --- | --- |
| [tfe_variable.env_variables](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.tf_vars](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.tf_vars_hcl](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_workspace.workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_tfe_oauth_token_id"></a> [tfe_oauth_token_id](#input_tfe_oauth_token_id) | Terraform Cloud <> VCS OAuth connection ID. | `string` | n/a | yes |
| <a name="input_vcs_repo_path"></a> [vcs_repo_path](#input_vcs_repo_path) | VCS repository path (<organization>/<repository>). | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace_name](#input_workspace_name) | Terraform Cloud workspace name. | `string` | n/a | yes |
| <a name="input_workspace_organization"></a> [workspace_organization](#input_workspace_organization) | Terraform Cloud organization name. | `string` | n/a | yes |
| <a name="input_sensitive_inputs"></a> [sensitive_inputs](#input_sensitive_inputs) | Values that should be marked as sensitive. Supported by `workspace_tf_vars`, `workspace_tf_vars_hcl`, `workspace_env_vars`. | `map(string)` | `{}` | no |
| <a name="input_vcs_branch_name"></a> [vcs_branch_name](#input_vcs_branch_name) | VCS repository branch to track. | `string` | `"main"` | no |
| <a name="input_vcs_trigger_paths"></a> [vcs_trigger_paths](#input_vcs_trigger_paths) | VCS repository branch to track. | `set(string)` | `[]` | no |
| <a name="input_vcs_working_directory"></a> [vcs_working_directory](#input_vcs_working_directory) | VCS repository branch to track. | `string` | `""` | no |
| <a name="input_workspace_auto_apply"></a> [workspace_auto_apply](#input_workspace_auto_apply) | Auto apply changes (Continuous delivery). | `bool` | `false` | no |
| <a name="input_workspace_description"></a> [workspace_description](#input_workspace_description) | Terraform Cloud workspace description. | `string` | `null` | no |
| <a name="input_workspace_env_vars"></a> [workspace_env_vars](#input_workspace_env_vars) | Environment variables to add to the workspace. You can pass sensitive values by setting the secret value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`. | `map(string)` | `{}` | no |
| <a name="input_workspace_tf_vars"></a> [workspace_tf_vars](#input_workspace_tf_vars) | Secrets to add to the workspace. You can pass sensitive values by setting the secret value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`. | `map(string)` | `{}` | no |
| <a name="input_workspace_tf_vars_hcl"></a> [workspace_tf_vars_hcl](#input_workspace_tf_vars_hcl) | Terraform variables to add to the workspace. You can pass sensitive values by setting the secret value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`. | `map(string)` | `{}` | no |

## Outputs

| Name                                                  | Description   |
| ----------------------------------------------------- | ------------- |
| <a name="output_ui_url"></a> [ui_url](#output_ui_url) | Management UI |

<!-- END_TF_DOCS -->
