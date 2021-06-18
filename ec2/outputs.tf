# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-hosts outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "linux_bastion_arn" {
  value = module.ec2_linux.arn
}
output "linux_bastion_private_ip" {
  value = module.ec2_linux.private_ip
}
output "linux_bastion_public_ip" {
  value = module.ec2_linux.public_ip
}
output "linux_bastion_sg_id" {
  value = aws_security_group.linux_bastion.id
}
