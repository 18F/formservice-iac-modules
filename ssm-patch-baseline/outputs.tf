output "arn" {
  value       = aws_ssm_patch_baseline.this.arn
  description = "The ARN of the patch baseline."
}

output "id" {
  value       = aws_ssm_patch_baseline.this.id
  description = "The ID of the patch baseline."
}

output "tags_all" {
  value       = aws_ssm_patch_baseline.this.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}
