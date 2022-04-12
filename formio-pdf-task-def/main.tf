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
        "valueFrom": "${var.enterprise_server_secrets}:MONGO_CA::"
      },
      { "name": "MONGO",
        "valueFrom": "${var.enterprise_server_secrets}:MONGO::"
      },
      { "name": "PDF_SERVER",
        "valueFrom": "${var.enterprise_server_secrets}:PDF_SERVER::"
      },
      { "name": "SSL_KEY",
        "valueFrom": "${var.enterprise_server_secrets}:SSL_KEY::"
      },
      { "name": "SSL_CERT",
        "valueFrom": "${var.enterprise_server_secrets}:SSL_CERT::"
      },
      { "name": "NODE_TLS_REJECT_UNAUTHORIZED",
        "valueFrom": "${var.enterprise_server_secrets}:NODE_TLS_REJECT_UNAUTHORIZED::"
      },
      { "name": "ADMIN_EMAIL",
        "valueFrom": "${var.enterprise_server_secrets}:ADMIN_EMAIL::"
      },
      { "name": "ADMIN_PASS",
        "valueFrom": "${var.enterprise_server_secrets}:ADMIN_PASS::"
      },
      { "name": "ADMIN_KEY",
        "valueFrom": "${var.enterprise_server_secrets}:ADMIN_KEY::"
      },
      { "name": "DB_SECRET",
        "valueFrom": "${var.enterprise_server_secrets}:DB_SECRET::"
      },
      { "name": "JWT_SECRET",
        "valueFrom": "${var.enterprise_server_secrets}:JWT_SECRET::"
      },
      { "name": "PORTAL_ENABLED",
        "valueFrom": "${var.enterprise_server_secrets}:PORTAL_ENABLED::"
      },
      { "name": "PORTAL_SECRET",
        "valueFrom": "${var.enterprise_server_secrets}:PORTAL_SECRET::"
      },
      { "name": "SSO_TEAMS",
        "valueFrom": "${var.enterprise_server_secrets}:SSO_TEAMS::"
      },
      { "name": "VPAT",
        "valueFrom": "${var.enterprise_server_secrets}:VPAT::"
      },
      { "name": "DEBUG",
        "valueFrom": "${var.enterprise_server_secrets}:DEBUG::"
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
          "sourceVolume": "enterprise-storage",
          "containerPath": "/src/certs"
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "/formio/enterprise",
              "awslogs-region": "us-gov-west-1",
              "awslogs-stream-prefix": "formio-hub"
          }
      },
      "dockerSecurityOptions": [
        "no-new-privileges"
      ]
    }
]
ENTERPRISE_TASK_DEFINITION

  execution_role_arn = var.enterprise_execution_role_arn
  task_role_arn = var.enterprise_task_role_arn

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

