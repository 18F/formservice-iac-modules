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
  name = "${var.name_prefix}/formio/pdf"
  retention_in_days = 180
}

####################################
# Set up Task Security Group
####################################
resource "aws_security_group" "formio_ecs_pdf_sg" {
  name        = "${var.name_prefix}-ecs-pdf-sg"
  description = "Allow Connections from the Load Balancer and from API tasks"
  vpc_id      = var.vpc_id

 ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "TCP"
    security_groups = [ var.formio_alb_sg_id ]
  }

  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "TCP"
    cidr_blocks     = var.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ecs-pdf-sg"
    Environment = "${var.name_prefix}"
  }
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
resource "aws_ecs_task_definition" "pdf" {
  family                   = "${var.name_prefix}-server"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.pdf_task_cpu
  memory                   = var.pdf_task_memory
  container_definitions    = <<PDF_TASK_DEFINITION
[
    {
      "name": "pdf-server",
      "image": "${var.pdf_image}",
      "environment": [
        {
          "name": "PORT",
          "value": "4005"
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
      { "name": "SSL_KEY",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:SSL_KEY::"
      },
      { "name": "SSL_CERT",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:SSL_CERT::"
      },
      { "name": "NODE_TLS_REJECT_UNAUTHORIZED",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:NODE_TLS_REJECT_UNAUTHORIZED::"
      },
      { "name": "DB_SECRET",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:DB_SECRET::"
      },
      { "name": "FORMIO_S3_KEY",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:FORMIO_S3_KEY::"
      },
      { "name": "FORMIO_S3_SECRET",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:FORMIO_S3_SECRET::"
      },
      { "name": "FORMIO_S3_BUCKET",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:FORMIO_S3_BUCKET::"
      },
      { "name": "DEBUG",
        "valueFrom": "${data.aws_secretsmanager_secret.task_secrets.arn}:DEBUG::"
      }],
      "portMappings": [
        {
            "containerPort": 4005,
            "hostPort": 4005
        }
      ],
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "mountPoints": [
        {
          "sourceVolume": "${var.pdf_volume_name}",
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
PDF_TASK_DEFINITION

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  ephemeral_storage {
    size_in_gib = var.pdf_ephemeral_storage
  }

  volume {
    name = var.pdf_volume_name

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
  name        = "${var.name_prefix}-tg"
  port        = 4005
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "ip"

  load_balancing_algorithm_type = var.load_balancing_algo

  health_check {
    enabled = true
    protocol = "HTTPS"
    path = "${var.health_path}"
    port = 4005
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

resource "aws_ecs_service" "formio_pdf" {
  name            = "${var.name_prefix}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.pdf.arn
  desired_count   = var.service_desired_task_count
  launch_type     = "FARGATE"

  enable_execute_command            = var.enable_execute_command
  force_new_deployment              = var.force_new_deployment
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  load_balancer {
    target_group_arn = aws_lb_target_group.formio.arn
    container_name   = "pdf-server"
    container_port   = 4005
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
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.formio_pdf.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "formio_policy" {
  name               = "${var.name_prefix}-scaling-policy"
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

