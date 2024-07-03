variable "accounts" {
  description = "List of accounts in which the permission set is to be provisioned"
  type        = list(string)
}

variable "create_group" {
  description = "Whether to create a new usergroup. Defaults to true so that updates don't cause issues"
  type        = bool
  default     = true
}

variable "group_description" {
  description = "Description of the user group"
  type        = string
  default     = "N/A"
}

variable "group_name" {
  description = "The display name of the group being created"
  type        = string
}

variable "permission_set_description" {
  description = "Description of the permission set"
  type        = string
  default     = "N/A"
}

variable "permission_set_name" {
  description = "Name of the permission set"
  type        = string
}

variable "policy_aws_managed" {
  description = "List of ARNs of policies to attach to permission set"
  type        = list(string)
  default     = []
}

variable "policy_customer_managed_name" {
  description = "Name of the policy to attach to permission set"
  type        = string
  default     = ""
}

variable "policy_customer_managed_path" {
  description = "Path of the policy to attach to permission set"
  type        = string
  default     = "/"
}

variable "policy_inline" {
  description = "Inline policy in JSON format to attach to permission set"
  type        = string
  default     = ""
}

variable "users" {
  description = "List of users to add to group"
  type        = map(string)
  default     = {}
}

variable "session_duration" {
  description = "The user session duration in ISO-8601 format"
  type        = string
  default     = "PT1H"
}
