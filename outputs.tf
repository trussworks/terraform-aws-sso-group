# Outputs placeholder

output "permission_set_arn" {
  description = "the ARN of the permission set"
  value       = aws_ssoadmin_permission_set.this.arn
}
