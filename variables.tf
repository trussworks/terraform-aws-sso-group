variable "accounts" {
  description = "List of accounts in which the permission set is to be provisioned"
  type        = list(string)
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

variable "managed_ad" {
  description = "Boolean set to true if using AWS Managed Active Directory"
  type        = bool
  default     = false
}

variable "users" {
  description = "List of users to add to group"
  type        = map(string)
  default     = {}
}
