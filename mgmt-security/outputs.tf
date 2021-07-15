# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/mgmt-security outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "prod_ec2_key_name" {
  value = aws_key_pair.prodkey.key_name
}

output "prod_ec2_key_arn" {
  value = aws_key_pair.prodkey.arn
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