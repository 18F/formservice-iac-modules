resource "aws_networkfirewall_rule_group" "domain_filter" {
  capacity = 500
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
        rules_source_list {
        generated_rules_type = var.rule_type
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.filtered_domains
      }
    }
  }
}