output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "web_server_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_server_public_dns" {
  value = aws_instance.web.public_dns
}

output "web_server_id" {
  value = aws_instance.web.id
}
output "Grafana_URL" {
  value = "http://${aws_instance.web.public_ip}:3000"
}

output "Prometheus_URL" {
  value = "http://${aws_instance.web.public_ip}:9090"
}
