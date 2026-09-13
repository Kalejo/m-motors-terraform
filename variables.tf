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