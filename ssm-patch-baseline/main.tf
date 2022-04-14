resource "aws_ssm_patch_baseline" "production" {
  name             = var.name
  operating_system = var.operating_system
}
