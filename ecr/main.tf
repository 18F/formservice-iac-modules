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
# ECR Container Registry
####################################

resource "aws_ecr_repository" "formio-enterprise" {
  name                 = "formio/enterprise"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "formio-enterprise" {
  repository = aws_ecr_repository.formio-enterprise.name

  policy = var.ecr_policy
}

resource "aws_ecr_repository" "formio-pdf-server" {
  name                 = "formio/pdf-server"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "formio-pdf-server" {
  repository = aws_ecr_repository.formio-pdf-server.name

  policy = var.ecr_policy
}

resource "aws_ecr_repository" "formio-submission-server" {
  name                 = "formio/submission-server"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "formio-utils-redis" {
  name                 = "formio/redis"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "formio-utils-nginx" {
  name                 = "formio/nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "signreq" {
  name                 = "faas/signreq"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}