# Répertoire des utilisateurs de l'application M-Motors
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-users"

  # L'adresse e-mail sert d'identifiant
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  # Règles de sécurité des mots de passe
  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # L'utilisateur peut récupérer son compte par e-mail vérifié
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Inscription autonome autorisée
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  # Authentification multifacteur disponible
  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  # Cognito envoie les messages de vérification
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Protection contre la suppression accidentelle
  deletion_protection = "ACTIVE"

  tags = {
    Name        = "${var.project_name}-users"
    Environment = "production"
  }
}



# Client Cognito utilisé par le frontend web
resource "aws_cognito_user_pool_client" "frontend" {
  name         = "${var.project_name}-frontend-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Une application web publique ne doit pas contenir de secret client
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

