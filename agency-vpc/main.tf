# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/agency-vpc
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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.57.0"

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
  database_subnets   = [
    cidrsubnet(var.vpc_cidr, 8, 21),
    cidrsubnet(var.vpc_cidr, 8, 22),
    cidrsubnet(var.vpc_cidr, 8, 23)
  ]

  ###################################################
  # Cloudwatch log group and IAM role will be created
  ###################################################
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 600

  vpc_flow_log_tags = {
    Name = "vpc-flow-logs-cloudwatch-logs-default"
  }

  ###################
  # public subnets
  ###################
  public_acl_tags = { Name = "${var.name_prefix}-public-acl" }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    Name                     = "${var.name_prefix}-public"
  }
  public_route_table_tags = { Name = "${var.name_prefix}-public-rt" }
  ###################
  # private subnets
  ###################
  private_dedicated_network_acl = true
  private_acl_tags              = { Name = "${var.name_prefix}-private-acl" }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    Name                              = "${var.name_prefix}-private"
  }
  private_route_table_tags = { Name = "${var.name_prefix}-private-rt" }
  ###################
  # database subnets
  ###################
  database_dedicated_network_acl = true
  database_acl_tags              = { Name = "${var.name_prefix}-db-acl" }
  database_subnet_tags           = { Name = "${var.name_prefix}-db" }

  # dns
  enable_dns_support   = true
  enable_dns_hostnames = true

  # nat
  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  # s3 endpoint
  # enable_s3_endpoint = true

  # VPC Endpoint for ECR API
  # enable_ecr_api_endpoint              = true
  # ecr_api_endpoint_private_dns_enabled = true
  # ecr_api_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # enable_ecr_dkr_endpoint              = true
  # ecr_dkr_endpoint_private_dns_enabled = true
  # ecr_dkr_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  vpc_endpoint_tags = {
    Endpoint = "true"
  }

  tags = {
    Terraform   = "true"
    Name        = var.name_prefix
  }
}

##############################
# transit gateway
##############################

resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments = "enable"
  tags = { Name = "${var.name_prefix}-TGW"}
}


