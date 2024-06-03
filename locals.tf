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
