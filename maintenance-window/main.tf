resource "aws_ssm_maintenance_window" "this" {
  name     = var.name
  schedule = var.schedule
  duration = var.duration
  cutoff   = var.cutoff
}
