




resource "aws_networkfirewall_firewall_policy" "faas_policy" {
  name = "${var.name_prefix}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_engine_options {
      rule_order = "DEFAULT_ACTION_ORDER"
    }
    dynamic stateful_rule_group_reference {
      for_each = var.policy_list
      content {
        resource_arn = stateless_rule_group_reference.value.rule_arn
      }
    }
  }
}