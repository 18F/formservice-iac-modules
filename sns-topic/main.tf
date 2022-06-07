terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

####################################
# Formio SNS Topic Definition
####################################

resource "aws_sns_topic" "formio_alerts" {
  name            = "${var.name_prefix}"
  display_name    = "${var.display_name}"
  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:Receive",
        "SNS:AddPermission",
        "SNS:Subscribe"
      ],
      "Resource": "arn:aws-us-gov:sns:${var.region}:${var.account_num}:${var.name_prefix}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${var.account_num}"
        }
      }
    },
    {
      "Sid": "__console_pub_0",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws-us-gov:sns:${var.region}:${var.account_num}:${var.name_prefix}",
      "Condition": {
        "ArnLike": {
          "AWS:SourceArn": [
            "arn:aws-us-gov:cloudwatch:${var.region}:${var.dev_account_num}:alarm:*",
            "arn:aws-us-gov:cloudwatch:${var.region}:${var.test_account_num}:alarm:*"
          ]
        }
      }
    },
    {
      "Sid": "__console_sub_0",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws-us-gov:iam::${var.dev_account_num}:root",
          "arn:aws-us-gov:iam::${var.account_num}:root",
          "arn:aws-us-gov:iam::${var.test_account_num}:root"
        ]
      },
      "Action": [
        "SNS:Subscribe",
        "SNS:Receive"
      ],
      "Resource": "arn:aws-us-gov:sns:${var.region}:${var.account_num}:${var.name_prefix}"
    }
  ]
}
EOF
}


  
