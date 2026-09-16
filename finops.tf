# Indicateur FinOps 1 : coût mensuel global du compte AWS
resource "aws_budgets_budget" "monthly_total" {
  name         = "${var.project_name}-monthly-total"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_limit)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Alerte lorsque 80 % du budget réel est consommé
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Alerte si AWS prévoit un dépassement du budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }

  tags = {
    Name        = "${var.project_name}-monthly-total"
    Environment = "production"
  }
}

# Indicateur FinOps 2 : coût mensuel de PostgreSQL RDS
resource "aws_budgets_budget" "monthly_rds" {
  name         = "${var.project_name}-monthly-rds"
  budget_type  = "COST"
  limit_amount = tostring(var.rds_budget_limit)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name = "Service"

    values = [
      "Amazon Relational Database Service"
    ]
  }

  # Alerte lorsque 80 % du budget RDS est consommé
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Alerte si AWS prévoit un dépassement du budget RDS
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }

  tags = {
    Name        = "${var.project_name}-monthly-rds"
    Environment = "production"
  }
}


