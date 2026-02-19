# ─── IAM Instance Profile ───────────────────────────────────────────────────
# Nécessaire pour que les instances EC2 puissent s'enregistrer auprès d'ECS.
# On utilise le LabRole existant comme d'habitude.
resource "aws_iam_instance_profile" "ecs_node" {
  name = "ecs-node-profile"
  role = "LabRole"
}

# ─── Data : AMI optimisée pour ECS ──────────────────────────────────────────
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

# ─── Launch Template ────────────────────────────────────────────────────────
resource "aws_launch_template" "ecs_nodes" {
  name_prefix   = "ecs-node-"
  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value).image_id
  instance_type = "t3.medium" # Un peu plus costaud que t2.micro pour ECS

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_node.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  # Script pour dire à l'instance de rejoindre notre cluster
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "ecs-node" }
  }
}

# ─── Auto Scaling Group ─────────────────────────────────────────────────────
resource "aws_autoscaling_group" "ecs_nodes" {
  name                = "ecs-asg"
  vpc_zone_identifier = [aws_subnet.web.id, aws_subnet.web_b.id]
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.ecs_nodes.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

# ─── Capacity Provider ──────────────────────────────────────────────────────
resource "aws_ecs_capacity_provider" "ecs_ec2" {
  name = "student-app-cp" # Correction : ne doit pas commencer par ecs/aws/fargate

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_nodes.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_ec2.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_ec2.name
  }
}
