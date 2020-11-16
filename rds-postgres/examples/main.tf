# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# example using module/rds-postgres
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
inputs = {
  ca_cert_identifier = "rds-ca-2017"
  name_prefix        = "${local.name_prefix}-agency01-microservice"

  engine            = "postgres"
  engine_version    = "9.5.22"
  instance_class    = "db.t2.xlarge"
  allocated_storage = 50 # in GBs

  database_name = "agency01microservice"
  db_username   = get_env("TF_VAR_db_username") # get from env variables TF_VAR_db_username
  db_password   = get_env("TF_VAR_db_password") # get from env variables TF_VAR_db_password
  db_port       = "5432"
  multi_az      = true

  database_subnet_ids             = dependency.vpc.outputs.database_subnet_ids

  # for security group
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnets_cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
  mgmt_subnet_cidr_blocks = ["10.20.1.214/32"]
}