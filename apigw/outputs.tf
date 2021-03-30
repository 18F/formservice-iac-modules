# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/apigw outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "apigw" {
  value       = aws_apigatewayv2_api.apigw
  description = "API GW ID Cluster Identifier"
}

output "apigw-lg" {
  value       = aws_cloudwatch_log_group.apigw-lg
  description = "APIGW Log Group"
}