# Variáveis do projeto Workshop 3 — AWS User Group São Roque
# Cada variável possui description, type e default (quando aplicável)

# Região AWS onde todos os recursos serão provisionados
variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

# Nome do projeto utilizado como prefixo para tags e identificação de recursos
variable "project_name" {
  description = "Nome do projeto usado como prefixo para tags e nomes de recursos"
  type        = string
  default     = "workshop-ugsr"
}

# Ambiente de execução para categorização via tags
variable "environment" {
  description = "Ambiente de execução (workshop, dev, prod)"
  type        = string
  default     = "workshop"
}

# Nome único do bucket S3 — cada participante define o seu via terraform.tfvars
variable "bucket_name" {
  description = "Nome único do bucket S3 para o site (cada participante define o seu)"
  type        = string
  default = "s3_usergroup"
}

# Tipo da instância EC2 utilizada no Launch Template
variable "instance_type" {
  description = "Tipo da instância EC2 para o Launch Template"
  type        = string
  default     = "t2.micro"
}

# Capacidade desejada do Auto Scaling Group
variable "asg_desired" {
  description = "Capacidade desejada do Auto Scaling Group"
  type        = number
  default     = 2
}

# Capacidade mínima do Auto Scaling Group
variable "asg_min" {
  description = "Capacidade mínima do Auto Scaling Group"
  type        = number
  default     = 2
}

# Capacidade máxima do Auto Scaling Group
variable "asg_max" {
  description = "Capacidade máxima do Auto Scaling Group"
  type        = number
  default     = 2
}

# Caminho relativo para os arquivos do site que serão enviados ao bucket S3
variable "site_files_path" {
  description = "Caminho relativo para os arquivos do site a serem enviados ao S3"
  type        = string
  default     = "../aplicacao"
}



# Tags comuns aplicadas a todos os recursos do projeto
# Garantem consistência na identificação e rastreabilidade dos recursos na AWS
variable "common_tags" {
  description = "Mapa de tags comuns aplicadas a todos os recursos do projeto"
  type        = map(string)
  default = {
    Project     = "workshop-ugsr"
    Environment = "workshop"
    ManagedBy   = "terraform"
  }
}
