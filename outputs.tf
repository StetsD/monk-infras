output "monk_public_ip" {
  value = aws_instance.monk_instance.public_ip
}

output "monk_public_dns" {
  value = aws_instance.monk_instance.public_dns
}