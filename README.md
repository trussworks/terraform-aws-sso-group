# Terraform AWS SSO Group

This module provisions AWS IAM Identity Center (formerly AWS Single Sign-On) resources.

The main functionality of this module is to dynamically provision permission set and account combinations and attach them to an existing user group.

## V2 Upgrade

- **BREAKING CHANGE**: The default behavior for group creation has changed to not creating the user group
- **BREAKING CHANGE**: The module no longer supports the use of in-line policy attachments for permission sets.
- **BREAKING CHANGE**: Customer supplied policies should now be supplied by a single list of maps containing name, path, and optionally description
- Where version 1 used to provision a single permission set and attach all policies to it, version 2 creates a permission set per policy supplied. The intent is to allow for less verbose terraform when creating multiple permission sets to be attached to a single group.

## Prerequisites

- In order to use AWS IAM Identity Center, your account must be managed by AWS Organizations.
- At the time of this writing (2023-11-09), you must manually click the Enable button in the AWS IAM Identity Center web console to create an instance in your account

## Usage

```hcl
module "engineer_permissions" {
  source  = "trussworks/sso-group/aws"
  version = "~> 2.0"

  accounts = var.accounts

  group_name = "group-name"

  policy_aws_managed = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  policy_customer_managed = [
    {
      "name"        = "EngineerPolicy1"
      "description" = "Engineer Policy Allowing access to XYZ"
      "path"        = "/"
    },
    {
      "name"        = "EngineerPolicy2"
      "description" = "Engineer Policy Allowing access to ABC"
      "path"        = "/"
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.6 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) | resource |
| [aws_identitystore_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource |
| [aws_ssoadmin_account_assignment.aws_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_account_assignment.customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_customer_managed_policy_attachment.customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.aws_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.aws_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set.customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| accounts | List of accounts in which the permission set is to be provisioned | `list(string)` | n/a | yes |
| create\_group | Whether to create a new usergroup | `bool` | `false` | no |
| group\_description | Description of the user group | `string` | `"N/A"` | no |
| group\_name | The display name of the group being created | `string` | n/a | yes |
| policy\_aws\_managed | List of ARNs of policies to attach to permission set | `list(string)` | `[]` | no |
| policy\_customer\_managed | List of name, path, and description combinations for customer managed policies to attach | `list(map(string))` | `[]` | no |
| policy\_inline | Inline policy in JSON format to attach to permission set | `string` | `""` | no |
| users | List of users to add to group | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit tfenv terraform-docs
tfenv install
pre-commit install --install-hooks
```
