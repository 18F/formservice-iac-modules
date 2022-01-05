
// maintenance window
resource "aws_ssm_maintenance_window" "this" {
  name     = var.maintenance_window_name
  schedule = var.maintenance_window_schedule
  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
}

// maintenance window target for hub-formio and runtime-submission ecs instances
resource "aws_ssm_maintenance_window_target" "this" {
  window_id     = aws_ssm_maintenance_window.this.id
  name          = "ecs-instances"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Name"
    values = ["faas-${var.env}-runtime-submission-env","faas-${var.env}-hub-formio-env"]
  }
}

// maintenance window tasks

// update ecs agent
resource "aws_ssm_maintenance_window_task" "update-ecs-agent" {
  max_concurrency = 1
  max_errors      = 1
  priority        = 1
  task_arn        = "AWS-RunShellScript"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.this.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.this.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      service_role_arn     = "arn:aws-us-gov:iam::${var.account_num}:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
      timeout_seconds      = 600

      cloudwatch_config {
        cloudwatch_output_enabled = true
      }

      parameter {
        name   = "commands"
        values = [ "if [[ \"$(sudo yum update -y ecs-init)\" == *\"download\"* ]] ; then sudo service docker restart && sudo start ecs ; fi" ]
      }
    }
  }
}

// 4.2.4 Ensure permissions on all logfiles are configured
resource "aws_ssm_maintenance_window_task" "logfile-permissions" {
  max_concurrency = 1
  max_errors      = 1
  priority        = 1
  task_arn        = "AWS-RunShellScript"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.this.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.this.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      service_role_arn     = "arn:aws-us-gov:iam::${var.account_num}:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
      timeout_seconds      = 600

      cloudwatch_config {
        cloudwatch_output_enabled = true
      }

      parameter {
        name   = "commands"
        values = [ "sudo find /var/log -type f -exec chmod g-wx,o-rwx {} +" ]
      }
    }
  }
}
