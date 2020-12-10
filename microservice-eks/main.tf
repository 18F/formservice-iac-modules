# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/microservice-eks
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

resource "aws_ecr_repository" "default" {
  name                 = "${var.name_prefix}/microservice"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

####################################
# EKS Cluster
####################################

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = var.ssh_ingress_cidr_blocks
  }
  tags = { Name = "${var.name_prefix}-worker_group_mgmt"}
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = var.ssh_ingress_cidr_blocks
  }
  tags = { Name = "${var.name_prefix}-all_worker_mgmt"}
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version       = "13.2.1"
  cluster_name    = var.cluster_name
  cluster_version = "1.17"

  vpc_id = var.vpc_id
  subnets         = var.private_subnet_ids
  
  cluster_create_timeout = "1h"
  cluster_endpoint_private_access = true 

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.large"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 3
      key_name                      = var.key_pair
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts

  write_kubeconfig   = true
  config_output_path = "./"
}

####################################
# kubernetes deployment
####################################

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "terraform-example"
    labels = {
      test = "MyExampleApp"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "MyExampleApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = "terraform-example"
  }
  spec {
    selector = {
      test = "MyExampleApp"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}