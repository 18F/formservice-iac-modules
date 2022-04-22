################################################
# Setup Log Groups
################################################
resource "aws_cloudwatch_log_group" "firewall_flow" {
  name = "${var.name_prefix}-firewall-flow"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "firewall_alerts" {
  name = "${var.name_prefix}-firewall-alert"
  retention_in_days = var.log_retention_days
}

################################################
# Setup Firewall
################################################
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

################################################
# Attach Logging
################################################
resource "aws_networkfirewall_logging_configuration" "firewall_flow" {
  firewall_arn = aws_networkfirewall_firewall.firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_flow.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}

resource "aws_networkfirewall_logging_configuration" "firewall_alerts" {
  firewall_arn = aws_networkfirewall_firewall.firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alerts.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}