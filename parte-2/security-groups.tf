# =============================================================================
# Security Groups — Workshop 3 AWS User Group São Roque
# Define os grupos de segurança para o ALB e as instâncias EC2
# =============================================================================

# -----------------------------------------------------------------------------
# Data Source: VPC Default
# Busca automaticamente a VPC default da conta AWS, eliminando a necessidade
# de o participante fornecer o ID manualmente
# -----------------------------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

# -----------------------------------------------------------------------------
# Security Group do ALB (Application Load Balancer)
# Permite tráfego HTTP (porta 80) de qualquer origem na internet
# e permite todo tráfego de saída
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "alb-sg-workshop3"
  description = "Security Group do ALB - permite HTTP da internet"
  vpc_id      = data.aws_vpc.default.id

  # Regra de entrada: aceita HTTP (porta 80) de qualquer IP
  ingress {
    description = "HTTP da internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra de saída: permite todo tráfego de saída
  egress {
    description = "Permite todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "alb-sg"
  })
}

# -----------------------------------------------------------------------------
# Security Group das instâncias EC2
# Permite tráfego HTTP (porta 80) SOMENTE vindo do ALB (referência por SG)
# e permite todo tráfego de saída
# -----------------------------------------------------------------------------
resource "aws_security_group" "ec2" {
  name        = "ec2-sg-workshop3"
  description = "Security Group das EC2 - permite HTTP do ALB"
  vpc_id      = data.aws_vpc.default.id

  # Regra de entrada: aceita HTTP (porta 80) somente do Security Group do ALB
  # Isso demonstra o conceito de referência entre recursos no Terraform
  ingress {
    description     = "HTTP somente do ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Regra de saída: permite todo tráfego de saída
  egress {
    description = "Permite todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "ec2-sg"
  })
}
