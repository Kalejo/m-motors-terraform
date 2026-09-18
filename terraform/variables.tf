variable "aws_region" {
  description = "Région AWS utilisée pour les ressources M-Motors"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom utilisé pour identifier le projet"
  type        = string
  default     = "m-motors"
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "production"
}

variable "admin_cidr" {
  description = "Adresse IP publique autorisee a se connecter en SSH"
  type        = string
}

variable "backend_image_tag" {
  description = "Tag de l'image Docker du backend dans ECR"
  type        = string
  default     = "v1"
}


variable "ec2_key_name" {
  description = "Nom de la paire de cles AWS utilisee pour la connexion SSH"
  type        = string
}


variable "alert_email" {
  description = "Adresse e-mail recevant les alertes CloudWatch"
  type        = string
}


# Ajouter les deux limites budgétaires

variable "monthly_budget_limit" {
  description = "Budget mensuel maximal pour l'ensemble du compte AWS en USD"
  type        = number
}

variable "rds_budget_limit" {
  description = "Budget mensuel maximal pour Amazon RDS en USD"
  type        = number
}


