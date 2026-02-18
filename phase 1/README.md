# Phase 1 — Déploiement d'une application monolithique sur AWS

## Contexte

L'objectif de cette phase était de déployer une application web Node.js (gestion d'étudiants) sur AWS de façon simple et fonctionnelle. Tout devait tourner sur une seule machine.

## Ce qui a été fait

### 1. Mise en place du réseau avec Terraform

La première étape a été de créer l'infrastructure réseau de base :

- Un **VPC** (`10.0.0.0/16`) pour isoler les ressources
- Un **subnet public** (`10.0.1.0/24`) dans lequel l'instance EC2 sera placée
- Une **Internet Gateway** pour permettre l'accès depuis internet
- Une **Route Table** associée au subnet public pour router le trafic vers l'IGW

### 2. Sécurisation avec un Security Group

Un Security Group a été configuré pour autoriser uniquement :
- Le port **80** (HTTP) — pour accéder à l'application
- Le port **22** (SSH) — pour administrer l'instance

Tout le reste est bloqué par défaut.

### 3. Création de l'instance EC2

Une instance **EC2 t3.micro** (Ubuntu 22.04) a été provisionnée dans le subnet public avec la clé SSH `vockey`.

### 4. Installation et démarrage de l'application via UserData

Au démarrage de l'instance, un script UserData (`UserdataScript-phase-2.sh`) s'exécute automatiquement pour :

1. Installer les dépendances système : `nodejs`, `npm`, `mysql-server`, `wget`, `unzip`
2. Télécharger le code source de l'application depuis S3
3. Installer les dépendances Node.js (`npm install`)
4. Créer la base de données MySQL locale :
   - Création de l'utilisateur `nodeapp` avec le mot de passe `student12`
   - Création de la base `STUDENTS` et de la table `students`
   - Configuration de MySQL pour écouter sur toutes les interfaces (`0.0.0.0`)
5. Démarrer l'application avec les variables d'environnement (`APP_DB_HOST`, `APP_DB_USER`, etc.)
6. Configurer `/etc/rc.local` pour que l'app redémarre automatiquement au reboot

## Résultat

L'application est accessible via l'IP publique de l'instance sur le port 80. La base de données MySQL tourne **sur la même machine** que l'application.

## Schéma de l'architecture

Voir [schema.md](./schema.md)

## Limites de cette architecture

- **Pas de séparation** entre l'application et la base de données : si l'instance tombe, tout est perdu
- **Pas de haute disponibilité** : une seule instance, un seul point de défaillance
- **Scalabilité impossible** : on ne peut pas scaler l'app sans déplacer la base de données
- **Sécurité limitée** : la base de données est exposée sur la même machine que l'app

→ Ces problèmes sont adressés en **Phase 2**.
