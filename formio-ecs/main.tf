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

####################################
# Formio ECS Cluster Definition
####################################
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "${var.name_prefix}-cluster-logs"
  retention_in_days = 180
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights
  }
  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_logs.name
      }
    }

  tags = {
    Environment = "${var.name_prefix}"
  }

  }

  resource "aws_ecs_cluster_capacity_providers" "fargate_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 6
    weight            = 100
    capacity_provider = "FARGATE"
  }
}



  
