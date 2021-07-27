# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/tgw-routes outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "tgw_attachment_id" {
  description = "TGW Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.gateway-attach.id
}

