output "id" {
  value       = aws_ssm_patch_group.this.id
  description = "The name of the patch group and ID of the patch baseline separated by a comma (,)."
}
