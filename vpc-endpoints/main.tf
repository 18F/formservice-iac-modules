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
      tags                = { Name = "${var.name_prefix}-ecr-api-vpc-endpoint" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ecr-dkr-vpc-endpoint" }
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ecs-vpc-endpoint" }
    },
    ecs_agent = {
      service             = "ecs-agent"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ecs-agent-vpc-endpoint" }
    },
    ecs_telemetry = {
      service             = "ecs-telemetry"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ecs-telemetry-vpc-endpoint" }
    },
    elasticbeanstalk = {
      service             = "elasticbeanstalk"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-elasticbeanstalk-vpc-endpoint" }
    },
    elasticbeanstalk_health = {
      service             = "elasticbeanstalk-health"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-elasticbeanstalk-health-vpc-endpoint" }
    },
    elasticLoadbalancing = {
      service             = "elasticloadbalancing"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-elasticloadbalancing-vpc-endpoint" }
    },
    config = {
      service             = "config"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-config-vpc-endpoint" }
    },
    autoscaling = {
      service             = "autoscaling"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-autoscaling-vpc-endpoint" }
    },
    autoscaling_plans = {
      service             = "autoscaling-plans"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-autoscaling-plans-vpc-endpoint" }
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ec2-vpc-endpoint" }
    },
    ec2_messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ec2messages-vpc-endpoint" }
    },
    ebs = {
      service             = "ebs"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-ebs-vpc-endpoint" }
    },
    cloudtrail = {
      service             = "cloudtrail"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-cloudtrail-vpc-endpoint" }
    },
    application_autoscaling = {
      service             = "application-autoscaling"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-application-autoscaling-vpc-endpoint" }
    },
     access_analyzer = {
      service             = "access-analyzer"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-access-analyzer-vpc-endpoint" }
    },
     email_smtp = {
      service             = "email-smtp"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = { Name = "${var.name_prefix}-email-smtp-vpc-endpoint" }
    }
  }

  tags = {
    Owner       = "${var.name_prefix}"
    Environment = "${var.environment}"
  }
}