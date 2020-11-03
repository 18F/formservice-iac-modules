# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/agency-vpc
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.57.0"

  name             = var.appname_construct
  cidr             = var.vpc_cidr
  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

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
  public_acl_tags = { Name = "${var.appname_construct}-public-acl" }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    Name                     = "${var.appname_construct}-public"
  }
  public_route_table_tags = { Name = "${var.appname_construct}-public-rt" }
  ###################
  # private subnets
  ###################
  private_dedicated_network_acl = true
  private_acl_tags              = { Name = "${var.appname_construct}-private-acl" }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    Name                              = "${var.appname_construct}-private"
  }
  private_route_table_tags = { Name = "${var.appname_construct}-private-rt" }
  ###################
  # database subnets
  ###################
  database_dedicated_network_acl = true
  database_acl_tags              = { Name = "${var.appname_construct}-db-acl" }
  database_subnet_tags           = { Name = "${var.appname_construct}-db" }

  # dns
  enable_dns_support   = true
  enable_dns_hostnames = true

  # nat
  enable_nat_gateway = true
  single_nat_gateway = true

  # s3 endpoint
  enable_s3_endpoint = true

  # VPC Endpoint for ECR API
  enable_ecr_api_endpoint              = true
  ecr_api_endpoint_private_dns_enabled = true
  ecr_api_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  vpc_endpoint_tags = {
    Endpoint = "true"
  }

  tags = {
    Terraform   = "true"
    Name        = var.appname_construct
  }
}




