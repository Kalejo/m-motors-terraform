# ECF Administrateur système DevOps — M-Motors

Ce dépôt présente le projet que j’ai réalisé dans le cadre de mon ECF du Bachelor Administrateur système DevOps.

L’objectif est de proposer une infrastructure AWS (Amazon Web Services) automatisée avec Terraform, de conteneuriser un backend FastAPI et de mettre en place une chaîne CI/CD (intégration et déploiement continus) avec GitHub Actions.

## Architecture du projet

L’infrastructure est décrite avec Terraform selon le principe IaC (Infrastructure as Code, infrastructure gérée par du code).

Elle prévoit notamment :

* un réseau VPC (Virtual Private Cloud, réseau privé AWS) ;
* deux compartiments S3 (Simple Storage Service) pour le site statique et les documents privés ;
* un backend FastAPI exécuté avec ECS Fargate (Elastic Container Service) ;
* un registre ECR (Elastic Container Registry) pour stocker les images Docker ;
* une base PostgreSQL avec RDS (Relational Database Service) ;
* une instance EC2 (Elastic Compute Cloud) de développement ;
* un ALB (Application Load Balancer) pour répartir les requêtes ;
* une supervision avec CloudWatch, SNS (Simple Notification Service) et AWS Budgets.

![Architecture AWS du projet](docs/architecture/architecture-aws-m-motors.png)

## Activité 1 — Infrastructure et sécurisation

J’ai écrit les fichiers Terraform nécessaires pour automatiser la création de l’infrastructure AWS.

La configuration a été contrôlée avec :

```bash
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

Le plan actuel prévoit encore 74 ressources à créer. Les deux ressources ECR ont déjà été créées séparément pour publier l’image Docker du backend.

Pour éviter des frais AWS inutiles, je n’ai pas exécuté le déploiement complet de l’infrastructure.

Les mesures de sécurité sont présentées dans [la documentation de sécurisation](docs/securite.md).

Preuves :

* [plan Terraform](docs/preuves/activite-1/terraform-plan.png) ;
* [paramètres de sécurisation Terraform](docs/preuves/activite-1/securite-terraform.png).

## Activité 2 — Backend, Docker et CI/CD

J’ai développé une API simple avec FastAPI et ajouté des tests unitaires avec Pytest.

Le backend a ensuite été :

1. testé localement ;
2. intégré dans une image Docker ;
3. publié dans ECR avec le tag `v1` ;
4. ajouté à une pipeline GitHub Actions.

La pipeline exécute automatiquement les tests Python et la construction de l’image Docker. La publication dans ECR et le déploiement dans ECS sont présents, mais restent manuels pour éviter le lancement accidentel de ressources payantes.

Preuves :

* [test local de l’image Docker](docs/preuves/activite-2/docker-local-test.png) ;
* [image publiée dans ECR](docs/preuves/activite-2/ecr-image-v1.png) ;
* [pipeline GitHub Actions](docs/preuves/activite-2/github-actions-success.png).

## Activité 3 — Supervision et FinOps

J’ai défini plusieurs indicateurs de supervision :

* utilisation du processeur ECS ;
* utilisation de la mémoire ECS ;
* erreurs HTTP 5XX ;
* temps de réponse du backend ;
* coût mensuel global AWS ;
* coût mensuel de RDS.

Les alertes techniques sont décrites avec CloudWatch et SNS. Un budget réel de 1 dollar a également été créé dans AWS avec une alerte à partir de 0,01 dollar de dépense.

Les détails et les preuves sont disponibles dans le [dossier de l’activité 3](docs/preuves/activite-3/README.md).

## Organisation du dépôt

```text
.
├── .github/workflows/     # Pipeline GitHub Actions
├── backend/               # API FastAPI, tests et Dockerfile
├── terraform/             # Infrastructure AWS avec Terraform
├── docs/architecture/     # Schéma de l’architecture
└── docs/preuves/          # Captures classées par activité
```

## Vérifications principales

Exécution des tests Python :

```bash
source backend/.venv/bin/activate
python -m pytest backend/tests -v
```

Construction de l’image Docker :

```bash
docker build -t m-motors-backend:v1 ./backend
```

Validation de Terraform :

```bash
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

La commande `terraform apply` n’est volontairement pas utilisée pour le déploiement complet, afin de conserver la maîtrise des coûts AWS.

## Auteur

Alexandro Alvarez
Bachelor Administrateur système DevOps
