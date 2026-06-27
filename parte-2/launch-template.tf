# =============================================================================
# Launch Template — Workshop 3 AWS User Group São Roque
# Define o data source para AMI Amazon Linux 2023 e o Launch Template
# utilizado pelo Auto Scaling Group para lançar instâncias EC2
# =============================================================================

# -----------------------------------------------------------------------------
# Data Source: AMI Amazon Linux 2023
# Busca automaticamente a AMI mais recente do Amazon Linux 2023 na região
# configurada, eliminando a necessidade de fornecer um ID de AMI manualmente
# -----------------------------------------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  # Filtro pelo nome da AMI — padrão Amazon Linux 2023 para arquitetura x86_64
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  # Filtro pelo tipo de virtualização — HVM (Hardware Virtual Machine)
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Filtro pela arquitetura — x86_64 (compatível com t2.micro)
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# -----------------------------------------------------------------------------
# Launch Template para as instâncias EC2 do Auto Scaling Group
# Configura: AMI, tipo de instância, perfil IAM, security group e user data
# O user data utiliza templatefile() para injetar o nome do bucket S3
# -----------------------------------------------------------------------------
resource "aws_launch_template" "main" {
  name_prefix = "${var.project_name}-lt-"

  # AMI obtida dinamicamente via data source — sempre a mais recente do AL2023
  image_id = data.aws_ami.amazon_linux_2023.id

  # Tipo da instância EC2 — definido via variável para flexibilidade
  instance_type = var.instance_type

  # Perfil IAM que permite às instâncias acessar o bucket S3
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  # Security Group das instâncias EC2 — aceita tráfego do ALB e SSH
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # User Data — script de inicialização que baixa os arquivos do site do S3
  # Utiliza templatefile() para injetar o nome do bucket como variável
  # replace() remove \r (CRLF do Windows) para evitar erros de sintaxe no Linux
  user_data = base64encode(replace(templatefile("${path.module}/templates/userdata.sh", {
    bucket_name = aws_s3_bucket.site.id
  }), "\r\n", "\n"))

  # Tags aplicadas ao Launch Template e às instâncias lançadas
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-launch-template"
  })

  # Tags propagadas para as instâncias EC2 criadas pelo ASG
  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name = "${var.project_name}-ec2"
    })
  }
}
