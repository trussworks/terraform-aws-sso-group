# Outputs placeholder
output "group_id" {
  description = "the ID of the identity store group"
  value       = aws_identitystore_group.this.group_id
}

output "permission_set_arn" {
  description = "the ARN of the permission set"
  value       = aws_ssoadmin_permission_set.this.arn
}
