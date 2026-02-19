# StudentApp Infrastructure - Phase 7 : Optimisation et Monitoring

Ce projet présente le déploiement automatisé d'une infrastructure AWS hautement disponible (HA) et scalable, incluant un monitoring avancé de la performance système (RAM/Disque). L'objectif est de ne plus dépendre uniquement des mesures externes d'AWS, mais de surveiller l'état interne des instances via un tableau de bord centralisé.

## Architecture de l'Infrastructure

L'infrastructure est entièrement gérée via Terraform et comprend :
* Auto Scaling Group (ASG) : Déploiement dynamique d'instances Ubuntu 22.04 sur plusieurs zones de disponibilité.
* Application Load Balancer (ALB) : Distribution intelligente du trafic et vérification de la santé (Health Checks) des instances.
* Sécurité (IAM et SG) : Utilisation du LabInstanceProfile pour l'envoi sécurisé des métriques vers CloudWatch sans clés statiques.
* Monitoring Avancé : Dashboard CloudWatch personnalisé affichant 5 indicateurs clés.

## Analyse du Dashboard (Validation Phase 7)

Le tableau de bord StudentApp-Advanced-Monitoring est structuré en 5 widgets stratégiques :

1. CPU (%) - Moyenne Groupe : Mesure la charge globale du cluster ASG.
2. RAM (%) - Métrique Agent : Remontée via l'agent installé en UserData. Indispensable pour détecter les saturations de mémoire.
3. Disque (%) - Occupation : Surveille l'espace restant sur la partition racine (/).
4. Trafic (Requêtes totales ALB) : Compte le nombre de requêtes HTTP traitées par le Load Balancer.
5. Santé (Instances opérationnelles) : Affiche le nombre d'instances considérées comme opérationnelles par le Target Group.

## Choix Techniques et Optimisations

* Adaptation Lab : L'infrastructure utilise des blocs "data" pour importer dynamiquement le VPC et les sous-réseaux par défaut du Lab AWS Academy, évitant ainsi les erreurs d'autorisation (403).
* Agent CloudWatch : L'agent est déployé automatiquement lors du boot. Il collecte des métriques "Inside-Guest" qui ne sont pas disponibles par défaut sur AWS sans agent (RAM et Disk).
* Haute Disponibilité : Les instances sont réparties sur les zones us-east-1a et us-east-1b pour garantir la continuité de service en cas de panne de zone.

## Installation et Déploiement

### Pré-requis
* Terraform installé.
* Accès à un environnement AWS (Lab AWS Academy / Vocareum).

### Étapes
1. Initialisation : 
   ```bash
   terraform init

  1. Apply : 
   ```bash
   terraform apply -auto-approve

### Étapes
   Comment vérifier les résultats : 
   Accéder à l'URL de l'ALB fournie dans les outputs de Terraform pour tester la réponse de l'application.

Consulter le Dashboard dans la console AWS : CloudWatch > Dashboards > StudentApp-Advanced-Monitoring.

Utiliser des outils de stress test sur les instances pour observer la variation des courbes en temps réel sur le dashboard.