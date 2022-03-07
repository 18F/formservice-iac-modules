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
# Formio ALB Definition
####################################

resource "aws_lb" "formio_lb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = tolist( [var.allowed_security_group_id] )
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

resource "aws_lb_target_group" "main" {
  name     = "${var.name_prefix}-main-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  load_balancing_algorithm_type = var.load_balancing_algo

  health_check {
    enabled = true
    protocol = "HTTPS"
    path = "${var.health_path}"
    port = 443
    healthy_threshold = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout = var.health_timeout
    interval = var.health_interval
    matcher = "200"
  }


  depends_on = [ aws_lb.formio_lb ]
}

resource "aws_lb_target_group" "pdf_server" {
  count    = var.hub ? 1 : 0
  name     = "${var.name_prefix}-pdf-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    protocol = "HTTPS"
    path = "${var.health_path}"
    port = 443
    healthy_threshold = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout = var.health_timeout
    interval = var.health_interval
    matcher = "200"
  }

  depends_on = [ aws_lb.formio_lb ]
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
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  depends_on = [ aws_lb.formio_lb, aws_lb_target_group.main ]
}

resource "aws_lb_listener_rule" "pdf_server" {
  count        = var.hub ? 1 : 0
  listener_arn = aws_lb_listener.main.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pdf_server[0].arn
  }

  condition {
    path_pattern {
      values = ["/pdf/*"]
    }
  }

  depends_on = [ aws_lb.formio_lb, aws_lb_target_group.pdf_server ]
}

