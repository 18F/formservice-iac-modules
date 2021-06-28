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

##############################
# transit gateway
##############################

resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments = "enable"
  tags = { Name = "${var.name_prefix}-TGW"}
}

## Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
   subnet_ids         = toset(module.vpc.public_subnets)
   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
   vpc_id             = module.vpc.vpc_id
   tags = { Name = "${var.name_prefix}-TGW-attachment"}
}

## Routes
resource "aws_route" "tgw-route-one" {
   for_each = toset(concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids))
  
   route_table_id         = each.value
   destination_cidr_block = "10.0.0.0/8"
   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
   depends_on = [module.vpc, aws_ec2_transit_gateway_vpc_attachment.this]
}