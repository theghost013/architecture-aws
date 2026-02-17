# Hardcoded AMI ID for Ubuntu 22.04 LTS in us-east-1
variable "ami_id" {
  default = "ami-0c7217cdde317cfec"
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  
  # Use the new subnet
  subnet_id     = aws_subnet.web.id

  vpc_security_group_ids = [aws_security_group.web.id]
  
  # Use the existing "vockey" key pair
  key_name = "vockey"

  user_data = file("${path.module}/../UserdataScript-phase-2.sh")

  tags = {
    Name = "StudentApp-phase-1"
  }
}
