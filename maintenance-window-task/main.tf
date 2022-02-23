data "aws_iam_role" "this" {
  name = "AWSServiceRoleForAmazonSSM"
}

resource "aws_ssm_maintenance_window_task" "this" {
  max_concurrency = var.max_concurrency
  max_errors      = var.max_errors
  priority        = var.priority
  task_arn        = var.task_arn
  task_type       = var.task_type
  window_id       = var.window_id

  targets {
    key    = var.target_type
    values = var.target_ids
  }

  task_invocation_parameters {
    run_command_parameters {
      service_role_arn     = data.aws_iam_role.this.arn
      timeout_seconds      = var.timeout_seconds
      cloudwatch_config {
        cloudwatch_output_enabled = var.cloudwatch_output_enabled
      }
      parameter {
        name   = "commands"
        values = var.commands
      }
    }
  }
}

resource "aws_iam_policy" "this" {
  name        = var.iam_policy_name
  policy      = var.iam_policy_document
  # only create this resource if the following variable is passed to the module
  count       = var.iam_policy_name == "" ? 0 : 1
}

resource "aws_iam_role_policy_attachment" "this" {
  role        = var.iam_role
  policy_arn  = aws_iam_policy.this[count.*].arn
  # only create this resource if the following variable is passed to the module
  count       = var.iam_role == "" ? 0 : 1
}
