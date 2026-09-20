# Sécurisation de l'infrastructure AWS M-Motors

## Objectif

L'infrastructure applique une séparation des réseaux, une restriction des flux entre les services, le chiffrement des données et le principe du moindre privilège.

| Élément | Mesure de sécurité | Mise en œuvre Terraform | Preuve |
|---|---|---|---|
| Réseau | Séparation entre les ressources publiques, applicatives et les bases de données | Sous-réseaux publics, sous-réseaux privés ECS et sous-réseaux privés RDS | `network.tf` |
| Base de données | Aucun accès direct depuis Internet | RDS est placé dans les sous-réseaux privés avec `publicly_accessible = false` | `database.tf` |
| ALB | Seuls les flux web HTTP et HTTPS provenant d'Internet sont acceptés | Ports 80 et 443 autorisés dans le groupe de sécurité ALB | `security.tf` |
| ECS Fargate | Le backend n'est pas directement accessible depuis Internet | Le port 8000 accepte uniquement le trafic provenant du groupe de sécurité ALB | `security.tf` |
| PostgreSQL | La base accepte uniquement les connexions du backend | Le port 5432 est autorisé uniquement depuis le groupe de sécurité ECS | `security.tf` |
| Accès SSH | L'administration de la machine EC2 est limitée | Le port 22 est autorisé uniquement depuis l'adresse définie par `admin_cidr` | `security.tf` |
| Bucket documents | Les documents d'achat et de location ne sont pas publics | Blocage complet des accès publics S3 | `storage.tf` |
| Chiffrement S3 | Les fichiers stockés sont chiffrés | Chiffrement côté serveur AES-256 sur les deux buckets | `storage.tf` |
| Versionnement S3 | Les anciennes versions des fichiers sont conservées | Versionnement activé sur les deux buckets | `storage.tf` |
| RDS | Les données PostgreSQL sont chiffrées | `storage_encrypted = true` | `database.tf` |
| Secret PostgreSQL | Le mot de passe n'est pas écrit dans le code Terraform | Mot de passe créé dans AWS Secrets Manager et transmis à ECS comme secret | `database.tf`, `ecs.tf` et `iam.tf` |
| IAM | L'application applique le principe du moindre privilège | ECS peut seulement lister le bucket documents et lire ses objets | `iam.tf` |
| Sauvegardes RDS | Les données disposent de sauvegardes automatiques | Conservation pendant 7 jours et snapshot final obligatoire | `database.tf` |
| Suppression RDS | Protection contre une suppression accidentelle | `deletion_protection = true` | `database.tf` |
| CloudFront | Les visiteurs sont redirigés vers HTTPS | `viewer_protocol_policy = "redirect-to-https"` | `cdn.tf` |
| Supervision | Les événements et erreurs peuvent déclencher des alertes | CloudWatch, Container Insights et notifications SNS | `monitoring.tf` |

## Limite de la démonstration

L'infrastructure complète n'a pas été déployée avec `terraform apply` afin d'éviter la création de ressources AWS facturables.

La cohérence de l'infrastructure a été contrôlée avec :

- `terraform fmt -check` ;
- `terraform validate` ;
- `terraform plan`.

Le plan Terraform prévoit encore 74 ressources à créer, sans modification ni suppression. Les deux ressources ECR (Elastic Container Registry, registre d’images Docker AWS) ont déjà été créées séparément pour publier l’image du backend.

