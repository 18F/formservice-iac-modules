resource "aws_networkfirewall_firewall" "firewall" {
  name                              = "${var.name_prefix}-egress-firewall"
  firewall_policy_arn               = var.firewall_policy_arn
  vpc_id                            = var.vpc_id
  firewall_policy_change_protection = var.firewall_policy_change_protection
  subnet_change_protection          = var.subnet_change_protection
  delete_protection                 = var.delete_protection

  dynamic "subnet_mapping" {
   for_each = var.subnet_mapping
   content {
     subnet_id = subnet_mapping.value.subnet_id
   }
  }  
}

