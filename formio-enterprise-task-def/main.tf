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
# Set up data sources
####################################
data "aws_secretsmanager_secret" "task_secrets" {
  name = var.task_secrets
}

data "aws_caller_identity" "current" {}

####################################
# Set up Log Group
####################################
resource "aws_cloudwatch_log_group" "task_logs" {
  name = "${var.name_prefix}/formio/enterprise"
  retention_in_days = 180
}

####################################
# Formio ECS Task Policies
####################################
resource "aws_iam_policy" "secret_access" {
  name        = "${var.name_prefix}-secrets-access-policy"
  description = "Alow use of the ${var.name_prefix} Secrets Manager key"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "${data.aws_secretsmanager_secret.task_secrets.arn}",
        "${data.aws_secretsmanager_secret.task_secrets.kms_key_id}"
      ]
    }
  ]
}
EOF
}

####################################
# Formio ECS Task Roles
####################################
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.name_prefix}-ecs-fargate-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "base-execution-policy-attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "execution-secrets-permissions-attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.secret_access.arn
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name_prefix}-ecs-fargate-task-role"

  assume_role_policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Principal":{
            "Service":[
               "ecs-tasks.amazonaws.com"
            ]
         },
         "Action":"sts:AssumeRole",
         "Condition":{
            "ArnLike":{
               "aws:SourceArn":"aws-us-gov:ecs:*:${data.aws_caller_identity.current.account_id}:*"
            },
            "StringEquals":{
               "aws:SourceAccount":"aws-us-gov.ecs*.${data.aws_caller_identity.current.account_id}"
            }
         }
      }
   ]
}
EOF
}

####################################
# Formio ECS Task Definitions
####################################
resource "aws_ecs_task_definition" "enterprise" {
  family                   = "${var.name_prefix}-enterprise-server"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.enterprise_task_cpu
  memory                   = var.enterprise_task_memory
  container_definitions    = <<ENTERPRISE_TASK_DEFINITION
[
    {
      "name": "api-server",
      "image": "${var.enterprise_image}",
      "environment": [
        {
          "name": "PORT",
          "value": "3000"
        }
      ],
      "secrets": [{
        "name": "MONGO_CA",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:MONGO_CA::"
      },
      { "name": "MONGO",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:MONGO::"
      },
      { "name": "PDF_SERVER",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:PDF_SERVER::"
      },
      { "name": "SSL_KEY",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:SSL_KEY::"
      },
      { "name": "SSL_CERT",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:SSL_CERT::"
      },
      { "name": "NODE_TLS_REJECT_UNAUTHORIZED",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:NODE_TLS_REJECT_UNAUTHORIZED::"
      },
      { "name": "ADMIN_EMAIL",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:ADMIN_EMAIL::"
      },
      { "name": "ADMIN_PASS",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:ADMIN_PASS::"
      },
      { "name": "ADMIN_KEY",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:ADMIN_KEY::"
      },
      { "name": "DB_SECRET",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:DB_SECRET::"
      },
      { "name": "JWT_SECRET",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:JWT_SECRET::"
      },
      { "name": "PORTAL_ENABLED",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:PORTAL_ENABLED::"
      },
      { "name": "PORTAL_SECRET",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:PORTAL_SECRET::"
      },
      { "name": "SSO_TEAMS",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:SSO_TEAMS::"
      },
      { "name": "VPAT",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:VPAT::"
      },
      { "name": "DEBUG",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:DEBUG::"
      }],
      "portMappings": [
        {
            "containerPort": 3000,
            "hostPort": 3000
        }
      ],
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "mountPoints": [
        {
          "sourceVolume": "${var.enterprise_volume_name}",
          "containerPath": "${var.container_mount_path}"
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.task_logs.name}",
              "awslogs-region": "${var.aws_region}"
          }
      },
      "dockerSecurityOptions": [
        "no-new-privileges"
      ]
    }
]
ENTERPRISE_TASK_DEFINITION

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  ephemeral_storage {
    size_in_gib = var.enterprise_ephemeral_storage
  }

  volume {
    name = var.enterprise_volume_name

    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
      root_directory          =  "/"
      authorization_config {
        access_point_id = var.efs_access_point_id
      }
    }
  }
}

