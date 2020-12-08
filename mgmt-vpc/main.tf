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

  ###################################################
  # Cloudwatch log group and IAM role will be created
  ###################################################
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 600

  vpc_flow_log_tags = { Name = "${var.name_prefix}-vpc-flow-logs-cloudwatch" }

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








