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

resource "aws_elastic_beanstalk_application_version" "initial" {
  name        = "${var.name_prefix}-app-${var.code_version_id}"
  application = "${var.name_prefix}-app"
  description = "Initial application version created by terraform"
  bucket      = var.code_bucket
  key         = var.code_version

  depends_on = [
    aws_elastic_beanstalk_application.app
  ]
}
