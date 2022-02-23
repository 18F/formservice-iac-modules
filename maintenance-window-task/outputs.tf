output "arn" {
  value       = aws_iam_policy.this.arn
  description = "The ARN assigned by AWS to this policy."
}

output "description" {
  value       = aws_iam_policy.this.description
  description = "The description of the policy."
}

output "id" {
  value       = aws_ssm_maintenance_window_task.this.id
  description = "The ID of the maintenance window task."
}

output "name" {
  value       = aws_iam_policy.this.name
  description = "The name of the policy."
}

output "path" {
  value       = aws_iam_policy.this.path
  description = "The path of the policy in IAM."
}

output "policy" {
  value       = aws_iam_policy.this.policy
  description = "The policy document."
}

output "policy_id" {
  value       = aws_iam_policy.this.policy_id
  description = "The policy's ID."
}

output "tags_all" {
  value       = aws_iam_policy.this.tags_all
  description = "A map of tags assigned to the resource."
}
