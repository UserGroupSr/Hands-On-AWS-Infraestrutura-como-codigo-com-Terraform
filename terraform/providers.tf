# Configuração do Terraform e do provider AWS
# Define a versão mínima do Terraform e o provider necessário para interagir com a AWS
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuração do provider AWS
# Define a região onde os recursos serão criados, utilizando a variável aws_region
provider "aws" {
  region = "us-east-1"
}
