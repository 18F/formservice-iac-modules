data "aws_iam_role" "this" {
  name = "AWSServiceRoleForAmazonSSM"
}

resource "aws_ssm_maintenance_window_task" "this" {
  max_concurrency = var.task_max_concurrency
  max_errors      = var.task_max_errors
  priority        = var.task_priority
  task_arn        = var.task_task_arn
  task_type       = var.task_task_type
  window_id       = var.task_window_id

  targets {
    key    = var.target_type
    values = [var.target_ids]
  }

  task_invocation_parameters {
    run_command_parameters {
      service_role_arn     = aws_iam_role.this.arn
      timeout_seconds      = var.timeout_seconds

      cloudwatch_config {
        cloudwatch_output_enabled = var.cloudwatch_output_enabled
      }

      parameter {
        name   = "commands"
        values = [ var.commands ]
      }
    }
  }
}
