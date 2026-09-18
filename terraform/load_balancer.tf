# Load Balancer public placé dans les deux zones de disponibilité
resource "aws_lb" "backend" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  drop_invalid_header_fields = true

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = "production"
  }
}

# Groupe contenant les tâches ECS Fargate
resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-backend-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project_name}-backend-tg"
    Environment = "production"
  }
}

# Point d'entrée HTTP du Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}


# Service maintenant les tâches FastAPI en fonctionnement
resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn

  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = 2

  # Retour automatique à la version précédente si le déploiement échoue
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  # Les conteneurs restent dans les sous-réseaux privés
  network_configuration {
    subnets = [
      aws_subnet.private_app_a.id,
      aws_subnet.private_app_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  # Enregistrement des conteneurs auprès du Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "${var.project_name}-backend"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.http
  ]

  tags = {
    Name        = "${var.project_name}-backend-service"
    Environment = "production"
  }
}

