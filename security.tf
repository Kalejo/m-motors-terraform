# Groupe de sécurité du Load Balancer public
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Autorise le trafic web vers le Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Autorisation HTTP depuis Internet
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP depuis Internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# Autorisation HTTPS depuis Internet
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS depuis Internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# Groupe de sécurité des tâches ECS Fargate
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg"
  description = "Autorise uniquement le trafic provenant du Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

# L'ALB peut contacter ECS sur le port 8000
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Trafic applicatif provenant de l ALB"

  from_port   = 8000
  to_port     = 8000
  ip_protocol = "tcp"
}

# L'ALB peut envoyer le trafic vers ECS
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "Trafic de l ALB vers ECS"

  from_port   = 8000
  to_port     = 8000
  ip_protocol = "tcp"
}

# ECS peut sortir vers Internet en passant par la NAT
resource "aws_vpc_security_group_egress_rule" "ecs_outbound" {
  security_group_id = aws_security_group.ecs.id
  description       = "Trafic sortant des conteneurs"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Groupe de sécurité de la base PostgreSQL
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Autorise PostgreSQL uniquement depuis ECS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# ECS peut joindre PostgreSQL sur le port 5432
resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "PostgreSQL depuis ECS"

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

# Groupe de sécurité du bastion Ansible
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Protege l acces SSH au bastion Ansible"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# SSH autorisé uniquement depuis l'adresse de l'administrateur
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  description       = "SSH depuis l adresse de l administrateur"

  cidr_ipv4   = var.admin_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# Sortie vers Internet pour les installations et mises à jour
resource "aws_vpc_security_group_egress_rule" "bastion_outbound" {
  security_group_id = aws_security_group.bastion.id
  description       = "Trafic sortant du bastion"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}