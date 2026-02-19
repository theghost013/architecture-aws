# Phase 3 — Haute Disponibilité et Scalabilité Automatique

## Contexte
Après avoir découplé l'application de la base de données en Phase 2, l'infrastructure restait vulnérable à une instance unique. L'objectif de cette Phase 3 était de rendre l'application **élastique** et **résiliente** en utilisant un groupe d'Auto Scaling (ASG) piloté par les métriques de performance.

## Ce qui a été fait

### 1. Configuration de l'Auto Scaling Group (ASG)
L'instance isolée a été remplacée par un groupe dynamique capable de s'auto-gérer :
- **Launch Template** : Définit la configuration standard des instances (AMI Ubuntu 22.04, type `t3.micro`, Rôle IAM `LabInstanceProfile`).
- **Multi-AZ** : Déploiement réparti sur plusieurs zones de disponibilité (`us-east-1a`, `us-east-1b`) pour assurer la continuité de service en cas de panne de data center.
- **Capacité** : Configuration d'un minimum de 1 instance et d'un maximum de 3 instances simultanées.

### 2. Politique de Scaling (Target Tracking)
Mise en place d'une politique de type "Suivi de cible" pour automatiser la gestion des ressources :
- **Métrique** : `CPUUtilization` (Utilisation moyenne du processeur).
- **Valeur cible** : Fixée à **50%**.
- **Action** : Ajout automatique d'instances si la charge moyenne du groupe dépasse le seuil pour maintenir la performance.

### 3. Monitoring CloudWatch
Le système s'appuie sur deux alarmes générées dynamiquement par la politique :
- **AlarmHigh** : Déclenchée si `CPU > 50%` pendant 3 points de données (3 minutes). Elle ordonne le "Scale-out" (ajout).
- **AlarmLow** : Déclenchée si `CPU < 9%` pendant 15 minutes. Elle ordonne le "Scale-in" (retrait) pour optimiser les coûts.

## 🧪 Protocole de Test de Charge (Stress Test)
Pour valider la configuration et le déclenchement des alarmes, nous avons provoqué une montée en charge artificielle sur l'instance active.

### Installation de l'outil
L'utilitaire `stress` a été installé sur l'instance Ubuntu via le terminal :
```bash
sudo apt update && sudo apt install stress -y

### Simulation de charge lourde
Exécution d'une commande saturant 100% des processeurs disponibles :

```bash
stress --cpu $(nproc) --timeout 900s

### Observation et Validation
- **CloudWatch** : La courbe `CPUUtilization` a franchi la ligne rouge des 50% (seuil critique).
- **État d'Alarme** : L'alarme `AlarmHigh` est passée en état `In Alarm` après le délai de validation.
- **Réaction ASG** : Une nouvelle instance a été provisionnée automatiquement dans la console EC2 (état `Pending` puis `Running`).

### 🛠️ Problèmes rencontrés et solutions

| Problème | Cause | Solution |
| :--- | :--- | :--- |
| **Command not found** | Tentative d'utilisation de commandes Amazon Linux (`yum`) sur un OS Ubuntu. | Utilisation du gestionnaire de paquets `apt` propre à Ubuntu. |
| **Pas de nouvelle instance** | La charge CPU était trop faible ou trop courte pour valider les 3 points de données. | Utilisation de la commande `stress` et abaissement temporaire du seuil cible à 20% pour le test. |
| **Délai de réaction** | CloudWatch nécessite plusieurs minutes de données consécutives pour éviter les faux positifs. | Observation patiente pendant 5 minutes pour confirmer le déclenchement de l'ASG. |