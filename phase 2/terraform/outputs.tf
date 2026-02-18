output "public_ip" {
  value = aws_instance.web.public_ip
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  value = "ssh -i vockey.pem ubuntu@${aws_instance.web.public_ip}"
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}
