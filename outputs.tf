# Outputs file
output "catapp_url" {
  value = "http://${aws_eip.hashicat.public_dns}"
}

output "vpc_id" {
  value = aws_vpc.hashicat.id
}

output "subnet_id" {
  value = aws_subnet.hashicat.id
}

output "security_groups" {
  value = aws_security_group.hashicat.id
}




