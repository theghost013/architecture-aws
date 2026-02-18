# Phase 2 — Découplage de l'application et de la base de données

## Contexte

La Phase 1 avait une limite majeure : l'application et la base de données tournaient sur la **même instance EC2**. En Phase 2, l'objectif était de séparer ces deux composants pour améliorer la résilience, la sécurité et la scalabilité.

## Ce qui a été fait

### 1. Refonte du réseau

Le réseau a été étendu pour accueillir une base de données isolée :

- Le **subnet public** (`10.0.1.0/24`) est conservé pour l'instance EC2 (Phase 1 et Phase 2)
- Deux **subnets privés** ont été ajoutés :
  - `10.0.2.0/24` en `us-east-1a`
  - `10.0.3.0/24` en `us-east-1b`
- Un **DB Subnet Group** regroupe ces deux subnets privés pour le RDS (AWS exige au minimum 2 AZ)

### 2. Création d'une base de données RDS managée

Au lieu d'un MySQL local, une instance **RDS MySQL 8.0** (`db.t3.micro`) a été provisionnée :

- Base de données : `studentsapp`
- Utilisateur : `admin` avec un mot de passe généré aléatoirement par Terraform (`random_password`)
- Placée dans les subnets privés — **non accessible depuis internet**
- Protégée par un Security Group dédié (`db-sg`) qui n'autorise le port 3306 **que depuis le SG de l'instance Phase 2**

### 3. Gestion sécurisée des credentials avec Secrets Manager

Pour ne pas stocker les credentials en clair dans le code ou les scripts :

- Les credentials de la base (`user`, `password`, `host`, `db`) sont stockés dans **AWS Secrets Manager** sous le nom `Mydbsecret`
- Le mot de passe est généré par Terraform et jamais écrit en clair dans les fichiers
- L'instance EC2 récupère ces credentials au démarrage via l'AWS CLI (`aws secretsmanager get-secret-value`)
- L'instance a le rôle IAM `LabInstanceProfile` qui lui donne les permissions nécessaires

### 4. Nouvelle instance EC2 pour la Phase 2

Une deuxième instance EC2 (`StudentApp-Phase-2`) a été créée avec un script UserData (`UserdataScript-phase-2.sh`) qui :

1. Installe les dépendances : `nodejs`, `npm`, `mysql-client`, `awscli`, `jq`
2. Télécharge et extrait le code source de l'application
3. Récupère les credentials depuis Secrets Manager
4. Configure les variables d'environnement (`APP_DB_HOST`, `APP_DB_USER`, `APP_DB_PASSWORD`, `APP_DB_NAME`)
5. Démarre l'application connectée au **RDS** (et non plus à un MySQL local)
6. Persiste les variables dans `/etc/rc.local` pour le redémarrage

### 5. Création de la table dans le RDS

La table `students` a été créée manuellement dans le RDS via SSH sur l'instance EC2 Phase 2 :

```sql
CREATE TABLE IF NOT EXISTS students (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  state VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(100) NOT NULL,
  PRIMARY KEY (id)
);
```

### 6. Problèmes rencontrés et solutions

| Problème | Cause | Solution |
|---|---|---|
| `secret_name` non interpolé dans UserData | Utilisation de `file()` au lieu de `templatefile()` | Passage à `templatefile()` avec les variables Terraform |
| `Table 'studentsapp.students' doesn't exist` | Le script créait la table dans MySQL local, pas dans le RDS | Création manuelle de la table dans le RDS via SSH |
| `ResourceExistsException` sur le secret | Le secret existait déjà dans AWS après un destroy partiel | Ajout de `recovery_window_in_days = 0` pour suppression immédiate |
| Security Group impossible à supprimer | Dépendances entre SG et instances encore actives | Attente de la destruction complète des instances avant le SG |

## Résultat

- L'application Phase 2 est accessible sur le port 80 via l'IP publique de l'instance
- La base de données est **isolée dans un subnet privé**, inaccessible depuis internet
- Les credentials ne sont **jamais en clair** dans le code — tout passe par Secrets Manager
- L'instance Phase 1 coexiste dans le même VPC (subnet public) pour comparaison

## Schéma de l'architecture

Voir [schema.md](./schema.md)
