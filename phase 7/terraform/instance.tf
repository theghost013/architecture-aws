# --- VARIABLES ---
variable "ami_id" {
  description = "AMI ID pour Ubuntu 22.04 LTS (us-east-1)"
  default     = "ami-0c7217cdde317cfec"
}

# --- 1. LE MODÈLE DE LANCEMENT (Launch Template) ---
resource "aws_launch_template" "web_lt" {
  name_prefix   = "student-app-lt-p7-"
  image_id      = var.ami_id
  instance_type = "t3.micro"
  key_name      = "vockey"

  # Utilisation du profil IAM du Lab (pour les droits CloudWatch)
  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
# ==========================================================
# 1. TON SCRIPT D'INSTALLATION (PHASE 2/3) 
# ==========================================================
# Colle tes commandes ici (apt install, npm, etc.)
apt-get update -y
# ... (tes commandes) ...


# ==========================================================
# 2. CONFIGURATION DE L'AGENT CLOUDWATCH (PHASE 7)
# ==========================================================
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Création du fichier de config pour RAM et DISQUE
cat <<EOT > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:ASG_NAME}"
    },
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["used_percent"], "resources": ["/"] }
    }
  }
}
EOT

# Lancer l'agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "StudentApp-P7-Instance"
    }
  }
}

# --- 2. LE GROUPE D'AUTO SCALING (ASG) ---
resource "aws_autoscaling_group" "app_asg" {
  name                = "student-app-asg-p7"
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2
  
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.web_tg.arn]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "StudentApp-ASG-P7"
    propagate_at_launch = true
  }
}