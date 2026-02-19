# ALB : point d'entrée public qui redirige le trafic vers ECS
resource "aws_lb" "app" {
  name               = "student-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.web.id, aws_subnet.web_b.id]
  tags               = { Name = "student-app-alb" }
}

# Target Group : liste des conteneurs qui reçoivent le trafic
resource "aws_lb_target_group" "app" {
  name        = "student-app-v3-tg" # Nouveau nom et lifecycle pour éviter ResourceInUse
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance" # Changement ici : de ip à instance

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = { Name = "student-app-tg" }

  lifecycle {
    create_before_destroy = true
  }
}

# Listener HTTP sur le port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}
