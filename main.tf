data "aws_caller_identity" "this" {}

data "aws_ssoadmin_instances" "this" {}

# Identity Store Group
resource "aws_identitystore_group" "this" {
  count = var.managed_ad ? 0 : 1

  display_name      = var.group_name
  description       = var.group_description
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

# Attach Identity Store Users to Group
resource "aws_identitystore_group_membership" "this" {
  count = var.managed_ad ? 0 : length(var.users)

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = var.managed_ad ? null : element(aws_identitystore_group.this[*].group_id, 0)
  member_id         = var.managed_ad ? null : var.users[count.index]
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

# Assign Accounts in which the Group can use its permission set
resource "aws_ssoadmin_account_assignment" "this" {
  count = var.managed_ad ? 0 : length(var.accounts)

  instance_arn       = var.managed_ad ? null : tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = var.managed_ad ? null : aws_ssoadmin_permission_set.this.arn
  principal_id       = var.managed_ad ? null : element(aws_identitystore_group.this[*].group_id, 0)
  principal_type     = var.managed_ad ? null : "GROUP"
  target_id          = var.managed_ad ? null : var.accounts[count.index]
  target_type        = var.managed_ad ? null : "AWS_ACCOUNT"
}
