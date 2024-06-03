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
  description = "Map containing the desired permission set names as keys to objects containing the name, path of the policy along with a description of the permission set"
  type = map(object({
    name        = string
    description = string
    path        = string
  }))
  default = {}
}

variable "users" {
  description = "List of users to add to group"
  type        = map(string)
  default     = {}
}
