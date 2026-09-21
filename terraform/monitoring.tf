# Canal centralisant les alertes de supervision
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = {
    Name        = "${var.project_name}-alerts"
    Environment = "production"
  }
}

# Envoi des alertes par e-mail
resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Métrique matérielle 1 : utilisation du processeur ECS
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name        = "${var.project_name}-ecs-cpu-high"
  alarm_description = "Alerte si le CPU moyen du backend depasse 80 pour cent"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend.name
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]
}

# Métrique matérielle 2 : utilisation de la mémoire ECS
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name        = "${var.project_name}-ecs-memory-high"
  alarm_description = "Alerte si la memoire moyenne du backend depasse 80 pour cent"

  namespace   = "AWS/ECS"
  metric_name = "MemoryUtilization"
  statistic   = "Average"

  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend.name
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]
}

# Métrique applicative 1 : erreurs générées par le backend
resource "aws_cloudwatch_metric_alarm" "backend_5xx" {
  alarm_name        = "${var.project_name}-backend-5xx"
  alarm_description = "Alerte si le backend genere au moins cinq erreurs HTTP 5xx"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"
  statistic   = "Sum"

  period              = 60
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    LoadBalancer = aws_lb.backend.arn_suffix
    TargetGroup  = aws_lb_target_group.backend.arn_suffix
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]
}

# Métrique applicative 2 : temps de réponse du chemin critique
resource "aws_cloudwatch_metric_alarm" "backend_response_time" {
  alarm_name        = "${var.project_name}-backend-response-time"
  alarm_description = "Alerte si le temps de reponse moyen depasse deux secondes"

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"
  statistic   = "Average"

  period              = 60
  evaluation_periods  = 3
  threshold           = 2
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    LoadBalancer = aws_lb.backend.arn_suffix
    TargetGroup  = aws_lb_target_group.backend.arn_suffix
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]
}


