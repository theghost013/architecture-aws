# --- LOAD BALANCER ---
resource "aws_lb" "web_alb" {
  name               = "student-app-alb-p7"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  
  # On utilise les sous-réseaux trouvés dynamiquement
  subnets            = data.aws_subnets.default.ids 
}

# --- 3. TARGET GROUP ---
resource "aws_lb_target_group" "web_tg" {
  name     = "student-app-tg-p7"
  port     = 80
  protocol = "HTTP"
  
  # On utilise l'ID du VPC par défaut
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

# --- 4. LISTENER ---
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}