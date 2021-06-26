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

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name             = var.name_prefix
  cidr             = var.vpc_cidr
  azs              = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2]
  ]
  public_subnets   = [
    cidrsubnet(var.vpc_cidr, 8, 1), # "10.20.0.0/16" becomes ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
    cidrsubnet(var.vpc_cidr, 8, 2),
    cidrsubnet(var.vpc_cidr, 8, 3)
  ]
  private_subnets   = [
    cidrsubnet(var.vpc_cidr, 8, 11),
    cidrsubnet(var.vpc_cidr, 8, 12),
    cidrsubnet(var.vpc_cidr, 8, 13)
  ]

  ###################################################
  # Cloudwatch log group and IAM role will be created
  ###################################################
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 600

  vpc_flow_log_tags = { Name = "${var.name_prefix}-vpc-flow-logs-cloudwatch" }

  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  # Default security group - ingress/egress rules cleared to deny all
  #manage_default_security_group  = true
  #default_security_group_ingress = []
  #default_security_group_egress  = []

  ###################
  # public subnets
  ###################
  public_acl_tags         = { Name = "${var.name_prefix}-public-acl" }
  public_subnet_tags      = { Name = "${var.name_prefix}-public" }
  public_route_table_tags = { Name = "${var.name_prefix}-public-rt" }
  ###################
  # private subnets
  ###################
  private_dedicated_network_acl = true
  private_acl_tags              = { Name = "${var.name_prefix}-private-acl" }
  private_subnet_tags           = { Name = "${var.name_prefix}-private" }
  private_route_table_tags      = { Name = "${var.name_prefix}-private-rt" }

  # dns
  enable_dns_support   = true
  enable_dns_hostnames = true

  # nat
  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  # tags = merge(local.tags, {
  #   Terraform   = "true"
  #   Name  = var.name_prefix
  #   Endpoint = "true"
  # })
}

##############################
# transit gateway
##############################

#resource "aws_ec2_transit_gateway" "tgw" {
#  auto_accept_shared_attachments = "enable"
#  tags = { Name = "${var.name_prefix}-TGW"}
#}

# ## Attachment
# resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
#   subnet_ids         = toset(module.vpc.public_subnets)
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#   vpc_id             = module.vpc.vpc_id
#   tags = { Name = "${var.name_prefix}-TGW-attachment"}
# }

# ## Routes
# resource "aws_route" "tgw-route-one" {
#   for_each = toset(concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids))
  
#   route_table_id         = each.value
#   destination_cidr_block = "10.0.0.0/8"
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
#   depends_on = [module.vpc, aws_ec2_transit_gateway_vpc_attachment.this]
# }

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

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
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.name_prefix}-sns-vpc-endpoint" }
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      #security_group_ids  = ["sg-987654321"]
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.name_prefix}-sqs-vpc-endpoint" }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.name_prefix}-ssm-vpc-endpoint" }

    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.name_prefix}-ssm-vpc-endpoint" }

    },
    lambda = {
      service             = "lambda"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.name_prefix}-lambda-vpc-endpoint" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${var.name_prefix}-ecr-api-vpc-endpoint" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${var.name_prefix}-ecr-dkr-vpc-endpoint" }
    },
    kms = {
      service             = "kms"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.name_prefix}-kms-vpc-endpoint" }
    }
  }

  tags = {
    Owner       = "faas-prod"
    Environment = "PROD"
  }
}

################################################################################
# Supporting Resources
################################################################################

# Data source used to avoid race condition
data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"

  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

      values = [data.aws_vpc_endpoint_service.dynamodb.id]
    }
  }
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

      values = [data.aws_vpc_endpoint_service.dynamodb.id]
    }
  }
}
