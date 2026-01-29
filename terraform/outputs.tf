output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "github_runner_public_ip" {
  description = "Public IP address of GitHub runner server"
  value       = aws_instance.github_runner.public_ip
}

output "github_runner_private_ip" {
  description = "Private IP address of GitHub runner server"
  value       = aws_instance.github_runner.private_ip
}

output "nexus_sonar_public_ip" {
  description = "Public IP address of Nexus/SonarQube server"
  value       = aws_instance.nexus_sonar.public_ip
}

output "nexus_sonar_private_ip" {
  description = "Private IP address of Nexus/SonarQube server"
  value       = aws_instance.nexus_sonar.private_ip
}

output "monitoring_public_ip" {
  description = "Public IP address of monitoring server"
  value       = aws_instance.monitoring.public_ip
}

output "monitoring_private_ip" {
  description = "Private IP address of monitoring server"
  value       = aws_instance.monitoring.private_ip
}

output "nexus_url" {
  description = "Nexus Repository URL"
  value       = "http://${aws_instance.nexus_sonar.public_ip}:8081"
}

output "nexus_docker_registry" {
  description = "Nexus Docker Registry URL"
  value       = "${aws_instance.nexus_sonar.public_ip}:8081/repository/docker-hosted/"
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_instance.nexus_sonar.public_ip}:9000"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_instance.monitoring.public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${aws_instance.monitoring.public_ip}:3000"
}

output "ssh_connection_commands" {
  description = "SSH commands to connect to servers"
  value = {
    github_runner = "ssh -i ~/.ssh/devops-pipeline ubuntu@${aws_instance.github_runner.public_ip}"
    nexus_sonar   = "ssh -i ~/.ssh/devops-pipeline ubuntu@${aws_instance.nexus_sonar.public_ip}"
    monitoring    = "ssh -i ~/.ssh/devops-pipeline ubuntu@${aws_instance.monitoring.public_ip}"
  }
}