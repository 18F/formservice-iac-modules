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

#######################
# Transit Gateway Attachment
#######################
resource "aws_ec2_transit_gateway_vpc_attachment" "gateway-attach" {
  subnet_ids             = var.private_subnet_ids
  transit_gateway_id     = var.transit_gateway_id
  vpc_id                 = var.vpc_id
  appliance_mode_support = var.appliance_mode_support
}

resource "aws_route" "tgw-route-default" {
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.destination_cidr_block
  transit_gateway_id        = var.transit_gateway_id
}

resource "aws_route" "tgw-route-defined" {
   for_each = toset(concat(var.private_route_table_ids, var.inspection_route_table_ids, var.public_route_table_ids))
  
   route_table_id         = each.value
   destination_cidr_block = var.destination_cidr_block
   transit_gateway_id     = var.transit_gateway_id
}