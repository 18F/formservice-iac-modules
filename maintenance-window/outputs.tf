output "id" {
  value = aws_ssm_maintenance_window.this.id
}

output "tags_all" {
  aws_ssm_maintenance_window.this.tags_all
}
