# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/elastic-beanstalk
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



resource "aws_elastic_beanstalk_application" "app" {
  name        = "${var.name_prefix}-app"
  description = "${var.name_prefix} Elastic Beanstalk Stack"
  tags = {
    name = "${var.name_prefix}-app"
  }
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "${var.name_prefix}-formio-app-version"
  application = "${var.name_prefix}-formio-app"
  description = "Initial application version created by terraform"
  bucket      = var.code_bucket
  key         = var.code_version
}

# resource "aws_s3_bucket" "default" {
#   bucket = var.code_bucket
# }

# resource "aws_s3_bucket_object" "default" {
#   bucket = aws_s3_bucket.default.id
#   key    = "beanstalk/multicontainer-gov.zip"
#   source = "multicontainer-gov.zip"
# }

# resource "aws_elastic_beanstalk_environment" "env" {
#   name                = "${var.name_prefix}-env"
#   application         = aws_elastic_beanstalk_application.app.name
#   solution_stack_name = "64bit Amazon Linux 2018.03 v2.26.2 running Multi-container Docker 19.03.13-ce (Generic)"

#   tags = {
#     name = "${var.name_prefix}-env"
#   }

#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "VPCId"
#     value     = var.vpc_id
#   }

#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "ELBSubnets"
#     value     = var.loadbalancer_subnets
#   }

#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "Subnets"
#     value     = var.application_subnets
#   }

#   setting {
#     namespace = "aws:elbv2:loadbalancer"
#     name      = "SecurityGroups"
#     value     = var.allowed_security_groups
#   }

#   setting {
#     namespace = "aws:elasticbeanstalk:environment"
#     name      = "LoadBalancerType"
#     value     = "application"
#   }

#   setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name      = "InstanceType"
#     value     = var.instance_type
#   }

#   setting {
#     namespace = "aws:autoscaling:asg"
#     name      = "MinSize"
#     value     = var.autoscale_min
#   }

#   setting {
#     namespace = "aws:autoscaling:asg"
#     name      = "MaxSize"
#     value     = var.autoscale_max
#   }

#   setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name      = "IamInstanceProfile"
#     value     = var.beanstalk_ec2_role
#   }

#   setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name      = "EC2KeyName"
#     value     = var.key_name
#   }

#   /* setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name      = "SSHSourceRestriction"
#     value     = "tcp,22,22,10.20.1.214/32"
#   } */

#   setting {
#     namespace = "aws:elbv2:listener:443"
#     name      = "SSLCertificateArns"
#     value     = var.ssl_cert
#   }

#   setting {
#     namespace = "aws:elbv2:listener:443"
#     name      = "ListenerEnabled"
#     value     = "true"
#   }

#   /* setting {
#     namespace = "aws:elbv2:listener:443"
#     name      = "ListenerEnabled"
#     value     = "true"
#   } */

#   setting {
#     namespace = "aws:elbv2:listener:443"
#     name      = "Protocol"
#     value     = "HTTPS"
#   }

#   setting {
#     namespace = "aws:elasticbeanstalk:healthreporting:system"
#     name      = "SystemType"
#     value     = "enhanced"
#   }

  ##################
  # env vars
  ##################

  /* setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ADMIN_EMAIL"
    value     = var.ADMIN_EMAIL
  }

    setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ADMIN_PASS"
    value     = var.ADMIN_PASS
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_SECRET"
    value     = var.DB_SECRET
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "JWT_SECRET"
    value     = var.JWT_SECRET
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "LICENSE_KEY"
    value     = var.LICENSE_KEY
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MONGO"
    value     = var.MONGO
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORTAL_ENABLED"
    value     = var.PORTAL_ENABLED
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "VPAT"
    value     = var.VPAT
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FORMIO_S3_BUCKET"
    value     = var.FORMIO_S3_BUCKET
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FORMIO_S3_REGION"
    value     = var.FORMIO_S3_REGION
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FORMIO_S3_KEY"
    value     = var.FORMIO_S3_KEY
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FORMIO_S3_SECRET"
    value     = var.FORMIO_S3_SECRET
  } */

  # setting {
  #   namespace = "aws:elasticbeanstalk:environment"
  #   name      = "XXXXXXX"
  #   value     = var.XXXXXXX
  # }
#}
