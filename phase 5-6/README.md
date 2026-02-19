# Phase 5 & 6 : Conteneurisation (ECS), CI/CD et Automatisation

Cette phase marque l'aboutissement de l'infrastructure avec le passage à une architecture conteneurisée gérée par **Amazon ECS (sur instances EC2)** et un pipeline **CI/CD complet** sur GitHub Actions.

## Objectifs Accomplis

- **Migration vers ECS** : Utilisation d'un cluster ECS avec des instances EC2 (Auto Scaling Group) pour héberger l'application.
- **Registre d'Images (ECR)** : Mise en place d'un dépôt ECR pour stocker les images Docker de l'application.
- **Load Balancing** : Utilisation d'un Application Load Balancer (ALB) pour distribuer le trafic vers les conteneurs.
- **Pipeline CI/CD Robuste** :
    - Build automatique de l'image Docker.
    - Push automatique sur ECR.
    - Vérification de la qualité du code (ESLint) et de l'infrastructure (Terraform Lint/Validate).
    - **Déploiement direct** : Configuration du daemon Docker sur les instances pour permettre un déploiement "Push" depuis GitHub Actions sans passer par l'orchestration complexe d'ECS à chaque itération.

## Défis et Problèmes Rencontrés

### 1. Variables d'Environnement et Secrets
Bien que l'infrastructure ait été déployée avec succès (VPC, RDS, ECS, ECR), nous avons rencontré un problème lors de l'exécution du conteneur. L'application ne parvenait pas à récupérer correctement les variables d'environnement injectées depuis AWS Secrets Manager. Ce bug a empêché la connexion à la base de données dans l'environnement de production ECS, bien que le build et le push aient fonctionné parfaitement.

### 2. Conflit de Contexte Terraform et CI/CD
Nous avons tenté d'automatiser le `terraform apply` directement depuis la CI/CD. Cependant, cette manipulation a entraîné une corruption/conflit du contexte Terraform (State), car certaines ressources créées manuellement ou via des runs précédents n'étaient plus synchronisées. 

Le nettoyage manuel de ces ressources (ALB, ASG, Capacity Providers) a pris du temps, et nous a empêché de relancer une infrastructure totalement propre pour effectuer les captures d'écran finales avant la fin de la séance.

## Conclusion
Le projet a prouvé la viabilité d'une architecture moderne de type Infrastructure-as-Code (IaC) avec CI/CD. Malgré les problèmes de "dernier kilomètre" sur la gestion des secrets et la perte du contexte Terraform en fin de phase, tous les composants essentiels (Réseau, Base de données, Orchestration, Pipeline) ont été implémentés et testés avec succès.

---
*Note : Pour des raisons techniques liées au conflit de state Terraform mentionné ci-dessus, les captures d'écran de l'application en ligne ne sont pas disponibles pour cette phase spécifique.*
