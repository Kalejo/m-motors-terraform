# Adresse publique du frontend distribué par CloudFront
output "cloudfront_domain_name" {
  description = "Nom de domaine CloudFront du frontend"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

# Adresse publique du Load Balancer du backend
output "alb_dns_name" {
  description = "Nom DNS du Load Balancer du backend"
  value       = aws_lb.backend.dns_name
}

# Adresse du dépôt contenant l'image Docker
output "ecr_repository_url" {
  description = "URL du dépôt ECR du backend"
  value       = aws_ecr_repository.backend.repository_url
}

# Informations nécessaires au frontend pour utiliser Cognito
output "cognito_user_pool_id" {
  description = "Identifiant du User Pool Cognito"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_frontend_client_id" {
  description = "Identifiant du client Cognito du frontend"
  value       = aws_cognito_user_pool_client.frontend.id
}

# Informations des stockages et de la base de données
output "documents_bucket_name" {
  description = "Nom du bucket privé contenant les dossiers clients"
  value       = aws_s3_bucket.documents.id
}

output "postgres_address" {
  description = "Adresse privée de PostgreSQL"
  value       = aws_db_instance.postgres.address
}

