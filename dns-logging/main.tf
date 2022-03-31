terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.5.0"
    }
  }
}

##############################################################################
data "aws_vpcs" "account_vpcs" {
}

data "aws_vpc" "vpc_info" {
  count = length(data.aws_vpcs.account_vpcs.ids)
  id    = tolist(data.aws_vpcs.account_vpcs.ids)[count.index]
}

##############################################################################
resource "aws_cloudwatch_log_group" "dns_logs" {
  name = "/aws/route53/resolver"

  retention_in_days = var.log_retention_days
  kms_key_id = var.kms_key_id

}

resource "aws_route53_resolver_query_log_config" "query_log_config" {
  name            = "${var.name_prefix}"
  destination_arn = aws_cloudwatch_log_group.dns_logs.arn

  tags = {
    Name = "${var.name_prefix}"
  }
}


resource "aws_route53_resolver_query_log_config_association" "vpc_association" {
  count = length(data.aws_vpcs.account_vpcs.ids)
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.query_log_config.id
  resource_id                  = data.aws_vpc.vpc_info[count.index].id
}

  
