resource "aws_ssm_patch_baseline" "this" {
  name                                  = var.name
  description                           = var.description
  operating_system                      = var.operating_system
  approved_patches_compliance_level     = var.approved_patches_compliance_level
  approved_patches                      = var.approved_patches
  rejected_patches                      = var.rejected_patches
  global_filter                         = var.global_filter
  rejected_patches_action               = var.rejected_patches_action
  approved_patches_enable_non_security  = var.approved_patches_enable_non_security
  tags                                  = var.tags

  approval_rule {
    approve_after_days  = var.approve_after_days
    approve_until_date  = var.approve_until_date
    patch_filter        = var.patch_filter
    compliance_level    = var.compliance_level
    enable_non_security = var.enable_non_security
  }

  source {
    name = var.source
    configuration = var.configuration
    products = var.products
  }
}
