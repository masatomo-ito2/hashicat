# Outputs file
output "catapp_url" {
  value = "http://${aws_eip.hashicat.public_dns}"
}

output "key_pem" {
  value = tls_private_key.hashicat.private_key_pem
  sensitive = true
}
