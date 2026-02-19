output "website_url" {
  description = "URL pour accéder à l'application via le Load Balancer"
  value       = "http://${aws_lb.web_alb.dns_name}"
}

output "alb_dns_name" {
  description = "Le nom DNS du Load Balancer"
  value       = aws_lb.web_alb.dns_name
}
