resource "aws_security_group" "db_sg" {
  name   = "student-app-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "MySQL from Web App"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "student-app-db-sg" }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "Mydbsecret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password_val" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    user     = "admin"
    password = random_password.db_password.result
    host     = aws_db_instance.default.address
    db       = "studentsapp"
  })
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  db_name                = "studentsapp"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = random_password.db_password.result
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true

  tags = { Name = "StudentAppDB" }
}