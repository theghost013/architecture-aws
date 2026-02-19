output "alb_url" {
  description = "URL de l'application via le Load Balancer"
  value       = "http://${aws_lb.app.dns_name}"
}

output "ecr_repository_url" {
  description = "URL du dépôt ECR pour pousser l'image"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nom du service ECS"
  value       = aws_ecs_service.app.name
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}
