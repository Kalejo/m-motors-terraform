# Registre contenant l'image Docker du backend FastAPI
resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "IMMUTABLE"

  # Analyse automatique des vulnérabilités à chaque push
  image_scanning_configuration {
    scan_on_push = true
  }

  # Chiffrement des images stockées
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-backend-ecr"
    Environment = "production"
  }
}

# Suppression des images sans étiquette après 7 jours
resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Supprimer les images sans etiquette apres 7 jours"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

