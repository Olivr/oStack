<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |

## Providers

No providers.

## Modules

| Name | Source | Version |
| --- | --- | --- |
| <a name="module_fingerprint"></a> [fingerprint](#module_fingerprint) | github.com/politician/terraform-shell-resource | v1.4.0 |
| <a name="module_generate_key"></a> [generate_key](#module_generate_key) | github.com/politician/terraform-shell-resource | v1.4.0 |
| <a name="module_private_key"></a> [private_key](#module_private_key) | github.com/politician/terraform-shell-resource | v1.4.0 |
| <a name="module_public_key"></a> [public_key](#module_public_key) | github.com/politician/terraform-shell-resource | v1.4.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_name"></a> [name](#input_name) | Name of the key to generate. | `string` | n/a | yes |
| <a name="input_comment"></a> [comment](#input_comment) | Comment to add to the key. | `string` | `""` | no |
| <a name="input_key_length"></a> [key_length](#input_key_length) | Key length. | `number` | `4096` | no |

## Outputs

| Name | Description |
| --- | --- |
| <a name="output_fingerprint"></a> [fingerprint](#output_fingerprint) | Key fingerprint. |
| <a name="output_private_key"></a> [private_key](#output_private_key) | Private key in armored format. |
| <a name="output_public_key"></a> [public_key](#output_public_key) | Public key in armored format. |

<!-- END_TF_DOCS -->
