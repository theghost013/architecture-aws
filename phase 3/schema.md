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

### Schéma d'Architecture (Mermaid)

```mermaid
graph TD
    User((User))

    subgraph AWS_Cloud ["AWS Cloud"]
        SecretsManager["Secrets Manager\n(Mydbsecret)"]
        CloudWatch["CloudWatch Alarms\n(CPU > 50%)"]

        subgraph VPC ["VPC (10.0.0.0/16)"]
            IGW[Internet Gateway]
            ALB["Application Load Balancer\n(Point d'entrée unique)"]

            subgraph Public_Subnets ["Public Subnets"]
                subgraph Pub_A ["Subnet Public A\nus-east-1a"]
                    ASG_A["ASG Instance\n(EC2 Phase 3)"]
                end
                subgraph Pub_B ["Subnet Public B\nus-east-1b"]
                    ASG_B["ASG Instance\n(EC2 Phase 3)"]
                end
            end

            subgraph ASG_Logic ["Auto Scaling Group"]
                LaunchTemplate["Launch Template\n(Ubuntu + UserData)"]
                ScalingPolicy["Target Tracking Policy\n(Target: 50%)"]
            end

            subgraph Private_Subnets ["Private Subnets (RDS)"]
                RDS[("RDS MySQL 8.0\nstudentsapp")]
                sg_db["SG RDS\nAllow: 3306 from ASG"]
            end
        end
    end

    %% Flux de trafic
    User -- "HTTP : 80" --> IGW
    IGW --> ALB
    ALB -- "Dispatch" --> ASG_A
    ALB -- "Dispatch" --> ASG_B

    %% Logique de Scaling
    ASG_A -.-> CloudWatch
    ASG_B -.-> CloudWatch
    CloudWatch -- "Trigger" --> ScalingPolicy
    ScalingPolicy -- "Scale Out/In" --> LaunchTemplate
    LaunchTemplate -- "Deploy" --> ASG_A
    LaunchTemplate -- "Deploy" --> ASG_B

    %% Connexions Data
    ASG_A -- "3306" --> sg_db
    ASG_B -- "3306" --> sg_db
    sg_db --> RDS
    ASG_A & ASG_B -- "IAM Role" --> SecretsManager

    %% Styles avec contraste élevé pour visibilité
    classDef vpc fill:#f0f8ff,stroke:#0077b6,stroke-width:3px,color:#000;
    classDef subnet fill:#ffffff,stroke:#00af91,stroke-width:2px,color:#000;
    classDef ec2 fill:#ffe8cc,stroke:#d97706,stroke-width:2px,color:#000,font-weight:bold;
    classDef rds fill:#f3e8ff,stroke:#7e22ce,stroke-width:2px,color:#000,font-weight:bold;
    classDef secrets fill:#dcfce7,stroke:#15803d,stroke-width:2px,color:#000;
    classDef monitoring fill:#fee2e2,stroke:#b91c1c,stroke-width:2px,color:#000,font-weight:bold;
    classDef lb fill:#e0e7ff,stroke:#4338ca,stroke-width:3px,color:#000,font-weight:bold;

    class VPC vpc;
    class Public_Subnets,Pub_A,Pub_B,Private_Subnets subnet;
    class ASG_A,ASG_B,LaunchTemplate ec2;
    class RDS rds;
    class SecretsManager secrets;
    class CloudWatch,ScalingPolicy monitoring;
    class ALB lb;