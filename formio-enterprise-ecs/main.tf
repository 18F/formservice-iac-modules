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
         "Action":"sts:AssumeRole"
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
      "name": "enterprise-api-server",
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
      { "name": "LICENSE_KEY",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:LICENSE_KEY::"
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
      { "name": "PORTAL_SSO_LOGOUT",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:PORTAL_SSO_LOGOUT::"
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
              "awslogs-region": "${var.aws_region}",
              "awslogs-stream-prefix": "${var.log_stream_prefix}"
          }
      }
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

####################################
# Formio Enterprise ALB TG and Listener Rule Setup
####################################

resource "aws_lb_target_group" "formio" {
  name        = "${var.name_prefix}-formio-tg"
  port        = 3000
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "ip"

  load_balancing_algorithm_type = var.load_balancing_algo

  health_check {
    enabled = true
    protocol = "HTTPS"
    path = "${var.health_path}"
    port = 3000
    healthy_threshold = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout = var.health_timeout
    interval = var.health_interval
    matcher = "200"
  }
}

resource "aws_lb_listener_rule" "formio_listener" {
  listener_arn = var.formio_alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.formio.arn
  }

 condition {
    host_header {
      values = ["${var.host_header_value}.service.forms.gov"]
    }
  }
  depends_on = [ aws_lb_target_group.formio ]
}

####################################
# Formio Enterprise ECS Service Setup
####################################

resource "aws_ecs_service" "formio_enterprise" {
  name            = "${var.name_prefix}-formio-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.enterprise.arn
  desired_count   = var.service_desired_task_count
  launch_type     = "FARGATE"

  enable_execute_command            = var.enable_execute_command
  force_new_deployment              = var.force_new_deployment
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  load_balancer {
    target_group_arn = aws_lb_target_group.formio.arn
    container_name   = "enterprise-api-server"
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.service_private_subnets
    security_groups  = var.service_security_group
    assign_public_ip = false
  }

   lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "formio_target" {
  max_capacity       = var.service_autoscaling_max
  min_capacity       = var.service_autoscaling_min
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.formio_enterprise.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "formio_policy" {
  name               = "${var.name_prefix}-formio-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.formio_target.resource_id
  scalable_dimension = aws_appautoscaling_target.formio_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.formio_target.service_namespace

 target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = join("/", [var.alb_resource_label, regex("targetgroup/.+", aws_lb_target_group.formio.arn)])
    }

    target_value       = var.scaling_metric_target_value
    scale_in_cooldown  = var.scaling_metric_scale_in_cooldown
    scale_out_cooldown = var.scaling_metric_scale_out_cooldown
  }
}

