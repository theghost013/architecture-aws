provider "aws" {
  region = "us-east-1"
}
resource "aws_ecr_repository" "app" {
  name                 = "container_registry-final"
  image_tag_mutability = "IMMUTABLE"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
