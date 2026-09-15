# Groupe de sous-réseaux privés utilisé par PostgreSQL
resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id
  ]

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = "production"
  }
}

# Base de données PostgreSQL administrée par Amazon RDS
resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "mmotors"
  username = "mmotors_admin"
  port     = 5432

  # AWS crée et conserve le mot de passe dans Secrets Manager
  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  # Haute disponibilité dans deux zones
  multi_az            = true
  publicly_accessible = false

  # Sauvegardes automatiques
  backup_retention_period  = 7
  backup_window            = "02:00-03:00"
  copy_tags_to_snapshot    = true
  delete_automated_backups = false

  # Maintenance planifiée
  maintenance_window         = "sun:03:00-sun:04:00"
  auto_minor_version_upgrade = true
  apply_immediately          = false

  # Protection contre une suppression accidentelle
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-postgres-final-snapshot"

  tags = {
    Name        = "${var.project_name}-postgres"
    Environment = "production"
    Sensitivity = "private"
  }
}

