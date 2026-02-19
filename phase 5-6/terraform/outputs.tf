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

# Récupération de l'IP publique du noeud ECS (EC2)
data "aws_instances" "ecs_nodes" {
  instance_tags = {
    "AmazonECSManaged" = "true"
  }
  instance_state_names = ["running"]

  depends_on = [aws_autoscaling_group.ecs_nodes]
}

output "ecs_node_public_ip" {
  description = "IP publique du premier noeud ECS pour accès Docker distant"
  value       = data.aws_instances.ecs_nodes.public_ips[0]
}
