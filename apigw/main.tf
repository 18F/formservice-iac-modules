# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/apigw
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.7.0"
    }
  }
}

########################################
# API Gateway
########################################

# resource "aws_api_gateway_domain_name" "apigw" {
#   domain_name              = var.domain_name
#   regional_certificate_arn = var.regional_certificate_arn
#   security_policy          = var.security_policy
#   tags                     = var.tags

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }


resource "aws_apigatewayv2_api" "apigw" {
  name          = "${var.name_prefix}-http-apigw"
  protocol_type = "HTTP"
}

# resource "aws_api_gateway_rest_api" "apigw" {
#   name                     = "${var.name_prefix}-apigw"
#   #api_key_source           = var.api_key_source #tfsec:ignore:GEN003
#   # binary_media_types       = var.binary_media_types
#   # description              = coalesce(var.description, "${var.name} API Gateway. Terraform Managed.")
#   # minimum_compression_size = var.minimum_compression_size
#   tags                     = var.tags

#   endpoint_configuration {
#     types = var.types
#   }

#   depends_on = [
#     aws_api_gateway_rest_api.apigw
#   ]
# }

########################################
# Authorizer
########################################

# resource "aws_apigatewayv2_authorizer" "apigw" {
#   api_id           = aws_apigatewayv2_api.apigw.id
#   authorizer_type  = "JWT"
#   identity_sources = ["$request.header.Authorization"]
#   name             = "apigw-authorizer"

#   jwt_configuration {
#     audience = ["apigw"]
#     issuer   = "https://${aws_cognito_user_pool.apigw.endpoint}"
#   }
# }

resource "aws_apigatewayv2_integration" "apigw" {
  api_id           = aws_apigatewayv2_api.apigw.id
  integration_type = "HTTP_PROXY"

  integration_method = "ANY"
  integration_uri    = "http://awseb-AWSEB-XQIMNNJLJ863-1578229579.us-gov-west-1.elb.amazonaws.com/{greedy}"
}

resource "aws_apigatewayv2_route" "apigw" {
  api_id    = aws_apigatewayv2_api.apigw.id
  route_key = "ANY /{greedy+}"

  target = "integrations/${aws_apigatewayv2_integration.apigw.id}"
}

resource "aws_apigatewayv2_deployment" "apigw" {
  api_id      = aws_apigatewayv2_api.apigw.id
  description = "apigw deployment"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_apigatewayv2_integration.apigw),
      jsonencode(aws_apigatewayv2_route.apigw),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "apigw" {
  api_id = aws_apigatewayv2_api.apigw.id
  name   = "@default"
  auto_deploy = true
}

# resource "aws_api_gateway_authorizer" "apigw" {
#   count           = length(var.provider_arns) < 1 ? 0 : 1
#   name            = var.name
#   identity_source = var.identity_source
#   provider_arns   = var.provider_arns
#   rest_api_id     = aws_api_gateway_rest_api.apigw.id
#   type            = "COGNITO_USER_POOLS"
# }

########################################
# Logging
########################################

resource "aws_cloudwatch_log_group" "apigw-lg" {
  name_prefix       = "${var.name_prefix}-apigw-lg"
  retention_in_days = var.retention_in_days
  # tags              = var.tags
}

# ++++
# resource "aws_apigatewayv2_api" "api" {
#   name          = "formio-api-gateway"
#   protocol_type = "HTTP"
#   description = "FormIO API Gateway"
# }
# resource "aws_api_gateway_resource" "resource" {
#   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
#   parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
#   path_part   = "{proxy+}"
# }
# resource "aws_api_gateway_method" "method" {
#   rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
#   resource_id   = "${aws_api_gateway_resource.resource.id}"
#   http_method   = "ANY"
#   authorization = "NONE"
#   request_parameters = {
#     "method.request.path.proxy" = true
#   }
# }
# resource "aws_api_gateway_integration" "integration" {
#   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
#   resource_id = "${aws_api_gateway_resource.resource.id}"
#   http_method = "${aws_api_gateway_method.method.http_method}"
#   integration_http_method = "ANY"
#   type                    = "HTTP_PROXY"
#   uri                     = "http://your.domain.com/{proxy}"
 
#   request_parameters =  {
#     "integration.request.path.proxy" = "method.request.path.proxy"
#   }
# }
