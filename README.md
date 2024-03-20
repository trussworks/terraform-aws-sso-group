# Terraform AWS SSO Group

This module provisions AWS IAM Identity Center (formerly AWS Single Sign-On) resources:

- An Identity Store group and group memberships for each user that is specified (the module does not provision users for you)
- A Permission Set with options for inline, AWS-managed, and customer-managed policy attachments to attach to the group
- Account assignments provisioning the permission set in each specified account

## Prerequisites

- In order to use AWS IAM Identity Center, your account must be managed by AWS Organizations.
- At the time of this writing (2023-11-09), you must manually click the Enable button in the AWS IAM Identity Center web console to create an instance in your account

## Usage

```hcl
data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "this" {}

variable "another_account_id" {
  description = "ID of another account within the organization"
  type        = string
  default     = "000000000000"
}

variable "users" {
  description = "users"
  type        = map(map(string))
  default = {
    "John Doe" = {
      username = "jdoe"
      email    = "jdoe@example.com"
    },
    "John Smith" = {
      username = "jsmith"
      email    = "jsmith@example.com"
    },
    "Joe Bloggs" = {
      username = "jbloggs"
      email    = "jbloggs@example.com"
    }
  }
}

resource "aws_identitystore_user" "user" {
  for_each = var.users

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  display_name = each.key
  user_name    = each.value["username"]

  name {
    given_name  = split(" ", each.key)[0]
    family_name = split(" ", each.key)[1]
  }

  emails {
    primary = true
    value   = each.value["email"]
  }
}

module "sso_group" {
  source = "trussworks/sso-group/aws"
  version = "~> 1.0"

  group_name          = "group-name"
  permission_set_name = "permission-set-name"

  accounts = [
    data.aws_caller_identity_current.account_id,
    var.another_account_id
  ]

  users = [
    for user in aws_identitystore_user.user : user.user_name => user.user_id
  ]

  policy_aws_managed = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
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
| [aws_ssoadmin_account_assignment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_customer_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| accounts | List of accounts in which the permission set is to be provisioned | `list(string)` | n/a | yes |
| group\_description | Description of the user group | `string` | `"N/A"` | no |
| group\_name | The display name of the group being created | `string` | n/a | yes |
| managed\_ad | Boolean set to true if using AWS Managed Active Directory | `bool` | `false` | no |
| permission\_set\_description | Description of the permission set | `string` | `"N/A"` | no |
| permission\_set\_name | Name of the permission set | `string` | n/a | yes |
| policy\_aws\_managed | List of ARNs of policies to attach to permission set | `list(string)` | `[]` | no |
| policy\_customer\_managed\_name | Name of the policy to attach to permission set | `string` | `""` | no |
| policy\_customer\_managed\_path | Path of the policy to attach to permission set | `string` | `"/"` | no |
| policy\_inline | Inline policy in JSON format to attach to permission set | `string` | `""` | no |
| users | List of users to add to group | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| permission\_set\_arn | the ARN of the permission set |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit tfenv terraform-docs
tfenv install
pre-commit install --install-hooks
```
