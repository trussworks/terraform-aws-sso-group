locals {
  /**
  Creates the cartesian product of accounts and aws managed policies
  accounts = ["XXXXXXXXXXXX", "YYYYYYYYYYYY"]
  policy_aws_managed = ["AdministratorAccess", "ReadOnlyAccess"]
  aws_managed_combinations_map = {
    "XXXXXXXXXXXX_AdministratorAccess" = ["XXXXXXXXXXXX", "AdministratorAccess"],
    "XXXXXXXXXXXX_ReadOnlyAccess" = ["XXXXXXXXXXXX", "ReadOnlyAccess"],
    "YYYYYYYYYYYY_AdministratorAccess" = ["YYYYYYYYYYYY", "AdministratorAccess"],
    "YYYYYYYYYYYY_ReadOnlyAccess" = ["YYYYYYYYYYYY", "ReadOnlyAccess"]
  }
  **/
  aws_managed_combinations_map = {
    for pair in setproduct(var.accounts, var.policy_aws_managed) : "${pair[0]}_${split("/", pair[1])[1]}" => pair
  }

  /**
  Creates the cartesian product of accounts and customer managed policies
  accounts = ["XXXXXXXXXXXX", "YYYYYYYYYYYY"]
  policy_customer_managed = {
    "PermissionSetName1" = {
      "name"        = "test"
      "description" = "a test policy"
      "path"        = "/"
    },
    "PermissionSetName2" = {
      "name"        = "differentTest"
      "description" = "a different test policy"
      "path"        = "/"
    }
  }
  customer_managed_combinations_map = {
    "XXXXXXXXXXXX_PermissionSetName1" = {
        account           = "XXXXXXXXXXXX"
        description       = "a test policy"
        name              = "test"
        path              = "/"
        permissionSetName = "PermissionSetName1"
    }
    "XXXXXXXXXXXX_PermissionSetName2" = {
        account           = "XXXXXXXXXXXX"
        description       = "a different test policy"
        name              = "differentTest"
        path              = "/"
        permissionSetName = "PermissionSetName2"
    }
    "YYYYYYYYYYYY_PermissionSetName1" = {
        account           = "YYYYYYYYYYYY"
        description       = "a test policy"
        name              = "test"
        path              = "/"
        permissionSetName = "PermissionSetName1"
    }
    "YYYYYYYYYYYY_PermissionSetName2" = {
        account           = "YYYYYYYYYYYY"
        description       = "a different test policy"
        name              = "differentTest"
        path              = "/"
        permissionSetName = "PermissionSetName2"
    }
  }
  **/
  customer_managed_combinations_map = merge(flatten([
    for key, value in var.policy_customer_managed : [
      for account in var.accounts : {
        "${account}_${key}" = merge(value, { "permissionSetName" = key, "account" = account })
      }
    ]
  ])...)
}

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

## Attach Identity Store Users to Group, if applicable
resource "aws_identitystore_group_membership" "this" {
  for_each = var.users

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = var.create_group ? aws_identitystore_group.this[0].group_id : data.aws_identitystore_group.this[0].group_id
  member_id         = each.value
}

# Permission sets
## AWS managed
resource "aws_ssoadmin_permission_set" "aws_managed" {
  for_each = toset(var.policy_aws_managed)

  name         = split("/", each.value)[1]
  description  = split("/", each.value)[1]
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "aws_managed" {
  for_each = toset(var.policy_aws_managed)

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = each.value
  permission_set_arn = aws_ssoadmin_permission_set.aws_managed[each.value].arn
}

resource "aws_ssoadmin_account_assignment" "aws_managed" {
  for_each = local.aws_managed_combinations_map

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.aws_managed[each.value[1]].arn

  principal_id   = var.create_group ? aws_identitystore_group.this[0].group_id : data.aws_identitystore_group.this[0].group_id
  principal_type = "GROUP"

  target_id   = each.value[0]
  target_type = "AWS_ACCOUNT"
}

## Customer Managed
resource "aws_ssoadmin_permission_set" "customer_managed" {
  for_each = var.policy_customer_managed

  name         = each.key
  description  = try(each.value.description, each.key)
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "customer_managed" {
  for_each = var.policy_customer_managed

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.customer_managed[each.key].arn
  customer_managed_policy_reference {
    name = each.value.name
    path = each.value.path
  }
}

resource "aws_ssoadmin_account_assignment" "customer_managed" {
  for_each = local.customer_managed_combinations_map

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.customer_managed[each.value.permissionSetName].arn

  principal_id   = var.create_group ? aws_identitystore_group.this[0].group_id : data.aws_identitystore_group.this[0].group_id
  principal_type = "GROUP"

  target_id   = each.value.account
  target_type = "AWS_ACCOUNT"
}
