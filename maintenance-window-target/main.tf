resource "aws_ssm_maintenance_window_target" "this" {
  window_id     = var.target_window_id
  name          = var.target_name
  resource_type = var.target_resource_type

  targets {
    key    = var.target_key
    values = [var.target_values]
  }
}
