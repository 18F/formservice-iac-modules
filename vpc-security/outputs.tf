# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/vpc security outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# VPC
output "endpointSGList" {
  description = "List of the VPC endpoint SG's"
  value       = tolist(aws_security_group.endpoint-sg.id)
}