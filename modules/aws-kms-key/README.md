# AWS KMS Key Module

Comprehensive AWS KMS Key module that supports all KMS key features including customer managed keys, key policies, grants, aliases, and key rotation. Follows AWS best practices for encryption key management and includes comprehensive validation and lifecycle management.

This module supports:
- Customer managed KMS keys with full configuration options
- External keys for imported key material
- Multi-region keys and replica keys
- Key aliases for easier key management
- Key grants for fine-grained access control
- Automatic key rotation with custom periods
- Comprehensive key policies and validation
- Integration with external key material import
- Support for all key specifications and usage types

## Features

- **Complete KMS Key Management**: Support for all AWS KMS key types and configurations
- **Security Best Practices**: Implements AWS security recommendations and validation
- **Multi-Region Support**: Create primary keys and replica keys across regions
- **Flexible Access Control**: Support for key policies and grants
- **Key Rotation**: Automatic key rotation with configurable periods
- **External Key Import**: Support for importing your own key material
- **Comprehensive Validation**: Input validation and lifecycle management
- **Tag Management**: Full support for resource tagging
- **AVM Compliance**: Follows Azure Verified Modules methodology adapted for AWS

## Usage

### Basic Usage

```hcl
module "kms_key" {
  source = "../../modules/aws-kms-key"

  description         = "My application encryption key"
  enable_key_rotation = true
  
  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Advanced Usage with Aliases and Grants

```hcl
module "kms_key" {
  source = "../../modules/aws-kms-key"

  description         = "Multi-feature KMS key"
  enable_key_rotation = true
  rotation_period_in_days = 90
  multi_region        = true
  
  enable_alias  = true
  enable_grants = true
  
  aliases = {
    "my-app-key"     = "Primary application key"
    "my-app-backup"  = "Backup key alias"
  }
  
  grants = {
    "application-grant" = {
      grantee_principal = "arn:aws:iam::123456789012:role/MyApplicationRole"
      operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
      constraints = {
        encryption_context_equals = {
          "Application" = "MyApp"
          "Environment" = "Production"
        }
      }
    }
  }
  
  tags = {
    Environment = "production"
    Application = "my-app"
    Owner       = "platform-team"
  }
}
```

### External Key Import

```hcl
module "external_kms_key" {
  source = "../../modules/aws-kms-key"

  create_key          = false
  create_external_key = true
  
  description           = "Imported key material"
  key_material_base64   = base64encode("my-256-bit-key-material-here...")
  deletion_window_in_days = 7
  
  enable_alias = true
  aliases = {
    "imported-key" = "Key with imported material"
  }
  
  tags = {
    Environment = "production"
    KeyType     = "imported"
  }
}
```

### Multi-Region Key with Replicas

```hcl
module "multi_region_key" {
  source = "../../modules/aws-kms-key"

  description   = "Multi-region application key"
  multi_region  = true
  
  enable_replica_keys = true
  replica_keys = {
    "us-west-2" = {
      primary_key_arn = module.primary_key.key_arn
      tags = {
        Region = "us-west-2"
      }
    }
    "eu-west-1" = {
      primary_key_arn = module.primary_key.key_arn
      tags = {
        Region = "eu-west-1"
      }
    }
  }
  
  tags = {
    Environment = "production"
    KeyType     = "multi-region"
  }
}
```

### Signing Key for Digital Signatures

```hcl
module "signing_key" {
  source = "../../modules/aws-kms-key"

  description           = "RSA key for digital signatures"
  key_usage            = "SIGN_VERIFY"
  key_spec             = "RSA_2048"
  enable_key_rotation  = false  # Not supported for signing keys
  
  tags = {
    Environment = "production"
    Purpose     = "digital-signing"
  }
}
```

## Examples

- [Basic KMS Key](examples/basic/README.md) - Simple KMS key with basic configuration
- [Key with Aliases](examples/with-aliases/README.md) - KMS key with multiple aliases
- [Key with Grants](examples/with-grants/README.md) - KMS key with access grants
- [External Key Import](examples/external-key/README.md) - Import external key material
- [Multi-Region Key](examples/multi-region/README.md) - Multi-region key setup
- [Comprehensive](examples/comprehensive/README.md) - All features enabled

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_grant.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [aws_kms_external_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_external_key) | resource |
| [aws_kms_alias.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_replica_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aliases"></a> [aliases](#input\_aliases) | A map of aliases to create for the key. Map key is the alias name, value is optional description. | `map(string)` | `{}` | no |
| <a name="input_bypass_policy_lockout_safety_check"></a> [bypass\_policy\_lockout\_safety\_check](#input\_bypass\_policy\_lockout\_safety\_check) | A flag to indicate whether to bypass the key policy lockout safety check. | `bool` | `false` | no |
| <a name="input_create_external_key"></a> [create\_external\_key](#input\_create\_external\_key) | Whether to create an external KMS key for imported key material. | `bool` | `false` | no |
| <a name="input_create_key"></a> [create\_key](#input\_create\_key) | Whether to create a KMS key. | `bool` | `true` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Duration in days after which the key is deleted after destruction of the resource. | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the key as viewed in AWS console. | `string` | `"KMS key created by Terraform"` | no |
| <a name="input_enable_alias"></a> [enable\_alias](#input\_enable\_alias) | Whether to create aliases for the key. | `bool` | `false` | no |
| <a name="input_enable_default_policy"></a> [enable\_default\_policy](#input\_enable\_default\_policy) | Whether to enable the default key policy. | `bool` | `true` | no |
| <a name="input_enable_grants"></a> [enable\_grants](#input\_enable\_grants) | Whether to create grants for the key. | `bool` | `false` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Specifies whether key rotation is enabled. | `bool` | `true` | no |
| <a name="input_enable_replica_keys"></a> [enable\_replica\_keys](#input\_enable\_replica\_keys) | Whether to create replica keys. | `bool` | `false` | no |
| <a name="input_grants"></a> [grants](#input\_grants) | A map of grants to create for the key. | <pre>map(object({<br>    grantee_principal = string<br>    operations        = list(string)<br>    constraints = optional(object({<br>      encryption_context_equals = optional(map(string))<br>      encryption_context_subset = optional(map(string))<br>    }))<br>    retiring_principal = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Specifies whether the key is enabled. | `bool` | `true` | no |
| <a name="input_key_material_base64"></a> [key\_material\_base64](#input\_key\_material\_base64) | Base64 encoded 256-bit symmetric encryption key material to import. | `string` | `null` | no |
| <a name="input_key_spec"></a> [key\_spec](#input\_key\_spec) | Specifies the type of key material in the CMK. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, ECC\_SECG\_P256K1, HMAC\_224, HMAC\_256, HMAC\_384, HMAC\_512, SM2. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Specifies the intended use of the key. Valid values: ENCRYPT\_DECRYPT, SIGN\_VERIFY, GENERATE\_VERIFY\_MAC. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_multi_region"></a> [multi\_region](#input\_multi\_region) | Indicates whether the KMS key is a multi-Region (true) or regional (false) key. | `bool` | `false` | no |
| <a name="input_origin"></a> [origin](#input\_origin) | The source of the key material for the CMK. Valid values: AWS\_KMS, EXTERNAL, AWS\_CLOUDHSM. | `string` | `"AWS_KMS"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid policy JSON document. If not specified, AWS will generate a default policy. | `string` | `null` | no |
| <a name="input_replica_keys"></a> [replica\_keys](#input\_replica\_keys) | A map of replica keys to create in different regions. | <pre>map(object({<br>    primary_key_arn = string<br>    policy          = optional(string)<br>    tags            = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_rotation_period_in_days"></a> [rotation\_period\_in\_days](#input\_rotation\_period\_in\_days) | Custom period of time between each rotation date. Must be a value between 90 and 2560 (inclusive). | `number` | `365` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the key. | `map(string)` | `{}` | no |
| <a name="input_valid_to"></a> [valid\_to](#input\_valid\_to) | Time at which the imported key material expires. When the key material expires, AWS KMS deletes the key material. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arns"></a> [alias\_arns](#output\_alias\_arns) | Map of alias ARNs. |
| <a name="output_alias_names"></a> [alias\_names](#output\_alias\_names) | Map of alias names to their target key IDs. |
| <a name="output_all_key_arns"></a> [all\_key\_arns](#output\_all\_key\_arns) | List of all key ARNs (primary, external, and replicas). |
| <a name="output_all_key_ids"></a> [all\_key\_ids](#output\_all\_key\_ids) | List of all key IDs (primary, external, and replicas). |
| <a name="output_aws_account_id"></a> [aws\_account\_id](#output\_aws\_account\_id) | The AWS account ID of the account that owns the CMK. |
| <a name="output_creation_date"></a> [creation\_date](#output\_creation\_date) | The date and time when the CMK was created. |
| <a name="output_deletion_date"></a> [deletion\_date](#output\_deletion\_date) | The date and time after which AWS KMS deletes the CMK. |
| <a name="output_description"></a> [description](#output\_description) | The description of the key. |
| <a name="output_enable_key_rotation"></a> [enable\_key\_rotation](#output\_enable\_key\_rotation) | Whether key rotation is enabled. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the key is enabled. |
| <a name="output_external_alias_names"></a> [external\_alias\_names](#output\_external\_alias\_names) | Map of external alias names to their target key IDs. |
| <a name="output_external_key_arn"></a> [external\_key\_arn](#output\_external\_key\_arn) | The Amazon Resource Name (ARN) of the external key. |
| <a name="output_external_key_expiration_model"></a> [external\_key\_expiration\_model](#output\_external\_key\_expiration\_model) | Whether the key material expires. |
| <a name="output_external_key_id"></a> [external\_key\_id](#output\_external\_key\_id) | The globally unique identifier for the external key. |
| <a name="output_external_key_state"></a> [external\_key\_state](#output\_external\_key\_state) | The state of the external CMK. |
| <a name="output_external_key_usage"></a> [external\_key\_usage](#output\_external\_key\_usage) | The cryptographic operations for which you can use the external key. |
| <a name="output_grant_ids"></a> [grant\_ids](#output\_grant\_ids) | Map of grant names to their IDs. |
| <a name="output_grant_tokens"></a> [grant\_tokens](#output\_grant\_tokens) | Map of grant names to their tokens. |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The Amazon Resource Name (ARN) of the key. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The globally unique identifier for the key. |
| <a name="output_key_spec"></a> [key\_spec](#output\_key\_spec) | The type of key material in the CMK. |
| <a name="output_key_state"></a> [key\_state](#output\_key\_state) | The state of the CMK. |
| <a name="output_key_usage"></a> [key\_usage](#output\_key\_usage) | The cryptographic operations for which you can use the key. |
| <a name="output_multi_region"></a> [multi\_region](#output\_multi\_region) | Whether the key is a multi-Region key. |
| <a name="output_multi_region_configuration"></a> [multi\_region\_configuration](#output\_multi\_region\_configuration) | Lists the primary and replica keys in same multi-Region key. |
| <a name="output_origin"></a> [origin](#output\_origin) | The source of the key material for the CMK. |
| <a name="output_policy"></a> [policy](#output\_policy) | The key policy JSON document. |
| <a name="output_replica_key_arns"></a> [replica\_key\_arns](#output\_replica\_key\_arns) | Map of replica key names to their ARNs. |
| <a name="output_replica_key_ids"></a> [replica\_key\_ids](#output\_replica\_key\_ids) | Map of replica key names to their IDs. |
| <a name="output_replica_key_states"></a> [replica\_key\_states](#output\_replica\_key\_states) | Map of replica key names to their states. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource. |

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for full details.

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this module.
