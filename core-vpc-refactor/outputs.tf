# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-vpc outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnets
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}
output "public_subnets_cidr_blocks" {
  description = "List of cidr blocks for public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr blocks for private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}


# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# VPC endpoints
#output "vpc_endpoint_s3_id" {
#  description = "The ID of VPC endpoint for S3"
#  value       = module.vpc.vpc_endpoint_s3_id
#}
##############
# Network ACLs
##############
# output "default_network_acl_id" {
#   description = "The ID of the default network ACL"
#   value       = module.vpc.default_network_acl_id
# }

# output "public_network_acl_id" {
#   description = "ID of the public network ACL"
#   value       = module.vpc.public_network_acl_id
# }
# output "public_network_acl_arn" {
#   description = "ARN of the public network ACL"
#   value       = module.vpc.public_network_acl_arn
# }

# output "private_network_acl_id" {
#   description = "ID of the private network ACL"
#   value       = module.vpc.private_network_acl_id
# }
# output "private_network_acl_arn" {
#   description = "ARN of the private network ACL"
#   value       = module.vpc.private_network_acl_arn
# }


output "default_security_group_id" {
  value = data.aws_security_group.default.id
}

## Route Table IDS
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = module.vpc.database_route_table_ids
}

output "default_route_table_id" {
  description = "ID of default route table"
  value       = module.vpc.default_route_table_id
}

## Transit Gateway
/* output "tgw_id" {
  description = "EC2 Transit Gateway identifier"
  value       = aws_ec2_transit_gateway.tgw.id
}

output "tgw_propagation_default_route_table_id" {
  description = "Identifier of the default propagation route table"
  value       = aws_ec2_transit_gateway.tgw.propagation_default_route_table_id
} */

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

# VPC endpoints
# output "vpc_endpoint_ssm_id" {
#   description = "The ID of VPC endpoint for SSM"
#   value       = module.vpc_endpoints.endpoints["ssm"].id
# }

# output "vpc_endpoint_ssm_network_interface_ids" {
#   description = "One or more network interfaces for the VPC Endpoint for SSM."
#   value       = module.vpc_endpoints.endpoints["ssm"].network_interface_ids
# }

# output "vpc_endpoint_ssm_dns_entry" {
#   description = "The DNS entries for the VPC Endpoint for SSM."
#   value       = module.vpc_endpoints.endpoints["ssm"].dns_entry
# }

