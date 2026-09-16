# Limites du nombre de conteneurs FastAPI
resource "aws_appautoscaling_target" "ecs_backend" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend.name}"

  min_capacity = 2
  max_capacity = 4
}

# Adaptation du nombre de conteneurs selon la charge CPU
resource "aws_appautoscaling_policy" "ecs_backend_cpu" {
  name               = "${var.project_name}-backend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs_backend.service_namespace
  scalable_dimension = aws_appautoscaling_target.ecs_backend.scalable_dimension
  resource_id        = aws_appautoscaling_target.ecs_backend.resource_id

  target_tracking_scaling_policy_configuration {
    target_value = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_out_cooldown = 60
    scale_in_cooldown  = 300
  }
}

