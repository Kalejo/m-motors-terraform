# Politique de confiance permettant aux tâches ECS d'utiliser les rôles IAM
data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Rôle utilisé par AWS pour démarrer les conteneurs
resource "aws_iam_role" "ecs_execution" {
  name               = "${var.project_name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name = "${var.project_name}-ecs-execution-role"
  }
}

# Autorisations pour télécharger l'image ECR et envoyer les logs
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Rôle utilisé directement par l'application FastAPI
resource "aws_iam_role" "ecs_task" {
  name               = "${var.project_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name = "${var.project_name}-ecs-task-role"
  }
}

# Cette politique est utilisée par l'application FastAPI.
# Elle autorise uniquement :
# - la consultation de la liste des fichiers du bucket documents ;
# - la lecture des fichiers stockés dans ce bucket.
#
# Elle n'accorde aucune autorisation d'écriture ou de suppression.
# Elle ne donne aucun accès au bucket frontend.
# Cette politique répond à la question 5 de l'activité type 2 de l'ECF.
data "aws_iam_policy_document" "ecs_documents_read" {
  # Autorise la consultation du contenu du bucket
  statement {
    sid     = "ListDocumentsBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]

    resources = [
      aws_s3_bucket.documents.arn
    ]
  }

  # Autorise la lecture des fichiers
  statement {
    sid     = "ReadDocuments"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.documents.arn}/*"
    ]
  }
}

# Association de la politique S3 au rôle de l'application
resource "aws_iam_role_policy" "ecs_documents_read" {
  name   = "${var.project_name}-ecs-documents-read"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_documents_read.json
}

