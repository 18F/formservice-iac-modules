# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-security outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "ec2_key_name" {
  value = aws_key_pair.prodkey.key_name
}

output "ec2_key_arn" {
  value = aws_key_pair.prodkey.arn
}

output "beanstalk_ec2_role_arn" {
  value = aws_iam_instance_profile.aws-elasticbeanstalk-ec2-role.arn
}

output "beanstalk_ec2_role_name" {
  value = aws_iam_role.beanstalk_ec2_role.name
}

/* output "documentdb_sg_id" {
  value = aws_security_group.documentdb_sg.id
}

output "s3_bucket_key_arn" {
  value = aws_kms_key.s3_bucket_key.arn
}

output "s3_bucket_key_id" {
  value = aws_kms_key.s3_bucket_key.key_id
} */
