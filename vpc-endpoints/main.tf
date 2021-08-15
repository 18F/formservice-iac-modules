# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-vpc
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.7.0"
    }
  }
} 


module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = var.vpc_id
  security_group_ids = var.endpointSGList

  endpoints = {
    s3 = {
      # interface endpoint
      service             = "s3"
      tags                = { Name = "${var.name_prefix}-s3-vpc-endpoint" }
    },
    #dynamodb = {
      # gateway endpoint
    #  service         = "dynamodb"
    #  route_table_ids = [ "rtb-05f5b51d08a2d4b9c", "rtb-030b6d714908a02d9" ]
    #  tags            = { Name = "${var.name_prefix}-dynamodb-vpc-endpoint" }
    #},
    sns = {
      service             = "sns"
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-sns-vpc-endpoint" }
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-sqs-vpc-endpoint" }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ssm-vpc-endpoint" }

    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ssm-vpc-endpoint" }

    },
    lambda = {
      service             = "lambda"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-lambda-vpc-endpoint" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${var.name_prefix}-ecr-api-vpc-endpoint" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${var.name_prefix}-ecr-dkr-vpc-endpoint" }
    },
    kms = {
      service             = "kms"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-kms-vpc-endpoint" }
    }
  }

  tags = {
    Owner       = "${var.name_prefix}"
    Environment = "${var.environment}"
  }
}