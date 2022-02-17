resource "aws_ssm_maintenance_window" "this" {
  name     = var.maintenance_window_name
  schedule = var.maintenance_window_schedule
  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
}
