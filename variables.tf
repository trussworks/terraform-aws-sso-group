variable "accounts" {
  description = "List of accounts in which the permission set is to be provisioned"
  type        = list(string)
}

variable "create_group" {
  description = "Whether to create a new usergroup"
  type        = bool
  default     = false
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

variable "policy_aws_managed" {
  description = "List of ARNs of policies to attach to permission set"
  type        = list(string)
  default     = []
}

variable "policy_customer_managed" {
  description = "List of name, path, and description combinations for customer managed policies to attach"
  type        = list(map(string))
  default     = []
}

variable "users" {
  description = "List of users to add to group"
  type        = map(string)
  default     = {}
}
