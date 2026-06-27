# =============================================================================
# Outputs — Workshop 3 AWS User Group São Roque
# Valores exibidos após terraform apply para facilitar a validação e o uso
# dos recursos provisionados
# =============================================================================

# DNS público do ALB — copie e cole no browser para acessar a aplicação
output "alb_dns_name" {
  description = "DNS público do Application Load Balancer — acesse no browser"
  value       = aws_lb.main.dns_name
}

# Nome do bucket S3 criado para armazenar os arquivos do site
output "bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.site.id
}

# Nome do Instance Profile usado pelas instâncias EC2
output "instance_profile_name" {
  description = "Nome do Instance Profile para referência"
  value       = aws_iam_instance_profile.ec2.name
}
