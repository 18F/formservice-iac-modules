resource "aws_ssm_maintenance_window_target" "this" {
  window_id     = var.window_id
  name          = var.name
  resource_type = var.resource_type

  targets {
    key    = var.key
    values = var.values
  }
}
