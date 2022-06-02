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

############
# Security Groups for FormIO ALB and ECS
############

resource "aws_security_group" "formio_alb_sg" {
  name        = "${var.name_prefix}-ecs-alb-sg"
  description = "Allow Connections to the Load Balancer"
  vpc_id      = var.vpc_id

 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = tolist([ var.formio_alb_allowed_cidr_blocks ])
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = tolist([ var.formio_alb_allowed_cidr_blocks ])
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ecs-alb-sg"
    Environment = "${var.name_prefix}"
  }
}

####################################
# Formio ALB Definition
####################################

resource "aws_lb" "formio_lb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = tolist( [ aws_security_group.formio_alb_sg.id ] )
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.access_logs_bucket_name
    prefix  = "${var.name_prefix}-alb"
    enabled = var.enable_access_logs
  }

  tags = {
    Environment = "${var.name_prefix}"
  }
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_lb.formio_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [ aws_lb.formio_lb ]
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.formio_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "fixed-response"

    fixed_response {
      content_type     = "text/plain"
      message_body     = "Placeholder"
      status_code      = "200"

    }
    
  }

  depends_on = [ aws_lb.formio_lb ]
}



