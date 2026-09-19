# Activité 3 — Supervision et FinOps

## Stratégie de supervision

La supervision est définie avec Amazon CloudWatch, Amazon SNS et AWS Budgets.
Les ressources de supervision sont décrites dans les fichiers
`terraform/monitoring.tf` et `terraform/finops.tf`.

Pour limiter les coûts pendant l'ECF, j'ai validé le code Terraform sans
déployer tous les services payants. Seuls ECR et le budget d'alerte ont été
activés dans AWS. Les configurations Terraform ont été validées avec
`terraform validate`.



## Métriques et alertes

| Catégorie | Métrique | Service AWS | Seuil | Action |
|---|---|---|---|---|
| Infrastructure | Utilisation CPU du service ECS | CloudWatch `AWS/ECS` | Moyenne supérieure à 80 % pendant 10 minutes | Notification SNS par e-mail |
| Infrastructure | Utilisation mémoire du service ECS | CloudWatch `AWS/ECS` | Moyenne supérieure à 80 % pendant 10 minutes | Notification SNS par e-mail |
| Application | Erreurs HTTP 5XX du backend | CloudWatch `AWS/ApplicationELB` | Au moins 5 erreurs en 1 minute | Notification SNS par e-mail |
| Application | Temps de réponse du backend | CloudWatch `AWS/ApplicationELB` | Moyenne supérieure à 2 secondes pendant 3 minutes | Notification SNS par e-mail |
| FinOps | Coût mensuel global AWS | AWS Budgets | 80 % du budget réel et 100 % du budget prévisionnel | Notification par e-mail |
| FinOps | Coût mensuel du service RDS | AWS Budgets | 80 % du budget réel et 100 % du budget prévisionnel | Notification par e-mail |

## Contrôle réel des coûts

Un budget de sécurité nommé `ECF-Zero-Spend-Budget` est actif dans AWS :

- budget mensuel : 1 USD ;
- alerte dès que les dépenses réelles dépassent 0,01 USD ;
- montant utilisé lors du contrôle : 0,00 USD.

Cost Explorer a également été interrogé avec AWS CLI. Aucun coût significatif
lié à EC2, RDS, ECS/Fargate, NAT Gateway ou Application Load Balancer n'a été
constaté.

## Preuves

- `aws-budget-overview.png` : vue générale du budget AWS ;
- `aws-budget-alert.png` : seuil de notification du budget ;
- `aws-cost-explorer.png` : consultation des coûts avec AWS CLI.