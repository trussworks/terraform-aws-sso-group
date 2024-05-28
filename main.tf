data "aws_caller_identity" "this" {}

data "aws_ssoadmin_instances" "this" {}

# Identity Store Group
data "aws_identitystore_group" "this" {
  count = var.create_group ? 0 : 1

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.group_name
    }
  }
}

resource "aws_identitystore_group" "this" {
  count = var.create_group ? 1 : 0

  display_name      = var.group_name
  description       = var.group_description
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

# Permission set
resource "aws_ssoadmin_permission_set" "this" {
  name         = var.permission_set_name
  description  = var.permission_set_description
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

# AWS-managed policy attachments
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = toset(var.policy_aws_managed)

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = each.key
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}

# Customer-managed policy attachments
resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  count = var.policy_customer_managed_name != "" ? 1 : 0

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  customer_managed_policy_reference {
    name = var.policy_customer_managed_name
    path = var.policy_customer_managed_path
  }
}

# Inline policy attachments
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  count = var.policy_inline != "" ? 1 : 0

  inline_policy      = var.policy_inline
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}

# Attach Identity Store Users to Group
resource "aws_identitystore_group_membership" "this" {
  for_each = var.users

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = var.create_group ? aws_identitystore_group.this[0].group_id : data.aws_identitystore_group.this[0].group_id
  member_id         = each.value
}

# Assign Accounts in which the Group can use its permission set
resource "aws_ssoadmin_account_assignment" "this" {
  for_each = toset(var.accounts)

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.this.arn

  principal_id   = var.create_group ? aws_identitystore_group.this[0].group_id : data.aws_identitystore_group.this[0].group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}
