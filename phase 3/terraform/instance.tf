# Hardcoded AMI ID pour Ubuntu 22.04 LTS (us-east-1)
variable "ami_id" {
  default = "ami-0c7217cdde317cfec"
}

# 1. Le modèle de lancement (Launch Template)
resource "aws_launch_template" "web_lt" {
  name_prefix   = "student-app-lt-"
  image_id      = var.ami_id
  instance_type = "t3.micro"
  key_name      = "vockey"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  # ATTENTION : Vérifie bien que ton fichier .sh est dans le même dossier
  user_data = filebase64("${path.module}/../UserdataScript-phase-2.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "StudentApp-ASG-Instance"
    }
  }
}

# 2. Le groupe d'Auto Scaling (ASG)
resource "aws_autoscaling_group" "web_asg" {
  name                = "student-app-asg"
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2
  
  vpc_zone_identifier = [aws_subnet.web.id, aws_subnet.web_b.id]
  target_group_arns   = [aws_lb_target_group.web_tg.arn]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
}