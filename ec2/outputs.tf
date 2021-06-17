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

output "windows_bastion_arn" {
  value = module.ec2_windows.arn
}
output "windows_bastion_private_ip" {
  value = module.ec2_windows.private_ip
}
output "windows_bastion_public_ip" {
  value = module.ec2_windows.public_ip
}
output "windows_bastion_sg_id" {
  value = aws_security_group.win_bastion.id
}
