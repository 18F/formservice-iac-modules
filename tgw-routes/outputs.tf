# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/tgw-routes outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "tgw_attachment_id" {
  description = "TGW Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "aws_route_ids" {
  description = "Route Table identifier and destination"
  value = [ for a in aws_route.this: a.id ]
}
