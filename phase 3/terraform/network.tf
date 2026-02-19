# 1. Le VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "StudentAppVPC"
  }
}

# 2. La passerelle Internet (IGW)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "StudentAppIGW"
  }
}

# 3. Sous-réseau Public A (web)
resource "aws_subnet" "web" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "StudentAppSubnet-A"
  }
}

# 4. Sous-réseau Public B (web_b) - Corrigé (anciennement private_2)
resource "aws_subnet" "web_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "StudentAppSubnet-B"
  }
}

# 5. Sous-réseau Privé (pour la base de données par exemple)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "PrivateSubnet1"
  }
}

# 6. Groupe de sous-réseaux pour la DB (si nécessaire)
resource "aws_db_subnet_group" "default" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.web_b.id]
}

# 7. Table de routage pour l'accès Internet
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name = "StudentAppRouteTable"
  }
}

# 8. Association du sous-réseau A à la table de routage
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.rt.id
}

# 9. Association du sous-réseau B à la table de routage (Essentiel pour le Load Balancer)
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.web_b.id
  route_table_id = aws_route_table.rt.id
}