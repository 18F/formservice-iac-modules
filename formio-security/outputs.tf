# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/formio-security outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* output "documentdb_sg_id" {
  value = aws_security_group.documentdb_sg.id
} */

output "s3_bucket_key_arn" {
  value = aws_kms_key.s3_bucket_key.arn
}

output "documentdb_key_arn" {
  value = aws_kms_key.documentDB_key.arn
}

output "s3_bucket_key_id" {
  value = aws_kms_key.s3_bucket_key.key_id
}

output "s3_kms_key_policy_arn" {
  value = aws_iam_policy.s3_key_user.arn
}

output "formio_alb_sg" {
  value = aws_security_group.formio_alb_sg.id
}

output "formio_ecs_sg" {
  value = aws_security_group.formio_ecs_sg.id
}

output "formio_ecs__pdf_sg" {
  value = aws_security_group.formio_ecs_pdf_sg.id
}