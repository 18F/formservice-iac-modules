resource "aws_networkfirewall_rule_group" "drop_all" {
  capacity = var.capacity
  name     = var.rule_name
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = var.home_networks
        }
      }
    }
    rules_source {
      rules_string = file("suricata_drop_rules_file")
    }
  }
}