# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-hosts outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "linux_mgmt_arn" {
  value = module.ec2_linux.arn
}
output "linux_mgmt_private_ip" {
  value = module.ec2_linux.private_ip
}
output "linux_mgmt_public_ip" {
  value = module.ec2_linux.public_ip
}
output "linux_mgmt_sg_id" {
  value = aws_security_group.terraform_linux_sg.id
}
