# ─── Security Groups ──────────────────────────────────────────────────────────

# SG pour l'ALB : accepte le trafic HTTP depuis Internet
resource "aws_security_group" "alb" {
  name        = "student-app-alb-sg"
  description = "Allow HTTP from Internet to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "student-app-alb-sg" }
}

# Security group pour les conteneurs ECS : accepte uniquement le trafic venant de l'ALB
resource "aws_security_group" "web" {
  name        = "student-app-web-ecs-sg"
  description = "Allow traffic from ALB to ECS containers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port   = 2375
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Ouvert pour le lab, à restreindre en prod
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "student-app-web-sg" }
}

# ─── ECS Cluster ──────────────────────────────────────────────────────────────

resource "aws_ecs_cluster" "main" {
  name = "student-app-cluster"
  tags = { Name = "student-app-cluster" }
}

# ─── IAM Role (LabRole fourni par AWS Academy) ────────────────────────────────
# AWS Academy ne permet pas de créer des rôles IAM.
# On utilise le rôle LabRole qui existe déjà et a toutes les permissions nécessaires.
data "aws_iam_role" "ecs_task_execution" {
  name = "LabRole"
}

variable "container_image_tag" {
  description = "Tag of the docker image to deploy"
  type        = string
  default     = "latest"
}

# ─── ECS Task Definition ──────────────────────────────────────────────────────
# Décrit le conteneur : quelle image, combien de ressources, quelles variables

resource "aws_ecs_task_definition" "app" {
  family                   = "student-app"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"] # Changement ici
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn            = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name  = "student-app"
    image = "${aws_ecr_repository.app.repository_url}:${var.container_image_tag}"
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000 # Ajout du hostPort pour le mode bridge
      protocol      = "tcp"
    }]
    environment = [
      { name = "APP_PORT", value = "3000" }
    ]
    secrets = [
      {
        name      = "APP_DB_HOST"
        valueFrom = "${aws_secretsmanager_secret.db_password.arn}:host::"
      },
      {
        name      = "APP_DB_USER"
        valueFrom = "${aws_secretsmanager_secret.db_password.arn}:user::"
      },
      {
        name      = "APP_DB_PASSWORD"
        valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::"
      },
      {
        name      = "APP_DB_NAME"
        valueFrom = "${aws_secretsmanager_secret.db_password.arn}:db::"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/student-app"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# Logs CloudWatch pour voir les logs du conteneur
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/student-app"
  retention_in_days = 7
}

# ─── ECS Service ──────────────────────────────────────────────────────────────
# Lance 1 conteneur en permanence sur EC2

resource "aws_ecs_service" "app" {
  name            = "student-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "EC2" # Changement ici : de FARGATE à EC2

  # Pas de network_configuration en mode bridge (le conteneur utilise le réseau de l'hôte)

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "student-app"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]
}
