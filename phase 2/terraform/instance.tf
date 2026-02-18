resource "aws_security_group" "web" {
  name        = "student-app-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "student-app-web-sg" }
}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# ─── Phase 1 : instance avec MySQL local ───────────────────────────────────────

resource "aws_instance" "web_phase1" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.web.id
  key_name               = "vockey"
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = file("${path.module}/../../phase 1/UserdataScript-phase-2.sh")

  tags = { Name = "StudentApp-phase-1" }
}

# ─── Phase 2 : instance connectée au RDS ───────────────────────────────────────

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.web.id
  key_name               = "vockey"
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = base64encode(templatefile("${path.module}/../UserdataScript-phase-2.sh", {
    rds_endpoint = aws_db_instance.default.address
    secret_name  = aws_secretsmanager_secret.db_password.name
  }))

  tags = { Name = "StudentApp-phase-2" }
}