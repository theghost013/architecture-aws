graph TD
    User((User))

    subgraph AWS_Cloud ["AWS Cloud (Environnement Lab)"]
        Dashboard["CloudWatch Dashboard\n(Advanced Monitoring)"]
        
        subgraph VPC_Default ["VPC par défaut (Data Source)"]
            ALB["Application Load Balancer\n(student-app-alb-p7)"]

            subgraph Subnets_Publics ["Subnets Publics (Multi-AZ)"]
                subgraph AZ_A ["us-east-1a"]
                    EC2_A["Instance EC2 A\n+ Agent CloudWatch"]
                end
                subgraph AZ_B ["us-east-1b"]
                    EC2_B["Instance EC2 B\n+ Agent CloudWatch"]
                end
            end

            subgraph ASG_Logic ["Auto Scaling Group"]
                LT["Launch Template\n(Ubuntu + Agent Config)"]
                IAM["LabInstanceProfile\n(Droits CloudWatch)"]
            end
        end
    end

    %% Flux de trafic
    User -- "HTTP : 80" --> ALB
    ALB -- "Dispatch" --> EC2_A
    ALB -- "Dispatch" --> EC2_B

    %% Flux de Monitoring (Phase 7)
    EC2_A & EC2_B -- "Métriques RAM / Disk" --> Dashboard
    ALB -- "RequestCount / Health" --> Dashboard
    
    %% Styles
    classDef vpc fill:#f0f8ff,stroke:#0077b6,stroke-width:3px,color:#000;
    classDef subnet fill:#ffffff,stroke:#00af91,stroke-width:2px,color:#000;
    classDef ec2 fill:#ffe8cc,stroke:#d97706,stroke-width:2px,color:#000,font-weight:bold;
    classDef monitoring fill:#fee2e2,stroke:#b91c1c,stroke-width:2px,color:#000,font-weight:bold;
    classDef lb fill:#e0e7ff,stroke:#4338ca,stroke-width:3px,color:#000,font-weight:bold;

    class VPC_Default vpc;
    class Subnets_Publics,AZ_A,AZ_B subnet;
    class EC2_A,EC2_B,LT ec2;
    class Dashboard monitoring;
    class ALB lb;