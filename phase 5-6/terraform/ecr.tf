# Dépôt ECR pour stocker l'image Docker
resource "aws_ecr_repository" "app" {
  name                 = "student-app-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = "student-app-repo" }
}
