# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/tgw-routes
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

## TGW Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = toset(var.public_subnet_ids)
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id
  tags = { Name = "${var.name_prefix}-TGW-attachment"}
}

## TGW Routes
resource "aws_route" "this" {
  for_each = toset(concat(
    var.public_route_table_ids,
    var.private_route_table_ids,
    var.database_route_table_ids
  ))
  
  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.tgw_id
}