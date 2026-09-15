# Autorise EventBridge Scheduler à utiliser un rôle IAM
data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

# Rôle utilisé par EventBridge Scheduler
resource "aws_iam_role" "scheduler" {
  name               = "${var.project_name}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json

  tags = {
    Name = "${var.project_name}-scheduler-role"
  }
}

# Autorisations limitées au démarrage et à l'arrêt de l'instance de développement
data "aws_iam_policy_document" "scheduler_ec2" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]

    resources = [
      aws_instance.development.arn
    ]
  }
}

# Association des autorisations au rôle Scheduler
resource "aws_iam_role_policy" "scheduler_ec2" {
  name   = "${var.project_name}-scheduler-ec2"
  role   = aws_iam_role.scheduler.id
  policy = data.aws_iam_policy_document.scheduler_ec2.json
}

# Démarrage du lundi au vendredi à 08h00
resource "aws_scheduler_schedule" "start_development" {
  name        = "${var.project_name}-start-development"
  description = "Demarre la machine de developpement en semaine"

  schedule_expression          = "cron(0 8 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Paris"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      InstanceIds = [
        aws_instance.development.id
      ]
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 2
    }
  }

  depends_on = [
    aws_iam_role_policy.scheduler_ec2
  ]
}

# Arrêt du lundi au vendredi à 20h00
resource "aws_scheduler_schedule" "stop_development" {
  name        = "${var.project_name}-stop-development"
  description = "Arrete la machine de developpement le soir"

  schedule_expression          = "cron(0 20 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Paris"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      InstanceIds = [
        aws_instance.development.id
      ]
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 2
    }
  }

  depends_on = [
    aws_iam_role_policy.scheduler_ec2
  ]
}

