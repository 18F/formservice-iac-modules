output "baseline_id" {
  value       = aws_ssm_patch_group.this.baseline_id
  description = "The ID of the patch baseline to register the patch group with."
}

output "id" {
  value       = aws_ssm_patch_group.this.id
  description = "The name of the patch group and ID of the patch baseline separated by a comma (,)."
}

output "patch_group" {
  value       = aws_ssm_patch_group.this.patch_group
  description = "The name of the patch group that should be registered with the patch baseline."
}
