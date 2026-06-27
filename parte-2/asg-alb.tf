# =============================================================================
# ASG + ALB — Workshop 3 AWS User Group São Roque
# Define o Application Load Balancer, Target Group, Listener e
# Auto Scaling Group para alta disponibilidade da aplicação web
# =============================================================================

# -----------------------------------------------------------------------------
# Data Source: Subnets Públicas
# Busca automaticamente as subnets públicas da VPC default, filtrando por
# vpc-id e pela propriedade map-public-ip-on-launch (subnets que atribuem IP
# público automaticamente às instâncias)
# -----------------------------------------------------------------------------
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# -----------------------------------------------------------------------------
# Application Load Balancer (ALB)
# Balanceador de carga internet-facing que distribui o tráfego HTTP entre as
# instâncias EC2 do Auto Scaling Group nas subnets públicas
# -----------------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-alb"
  })
}

# -----------------------------------------------------------------------------
# Target Group do ALB
# Grupo de destino que recebe as instâncias EC2 registradas pelo ASG
# Configurado com health check na raiz "/" para verificar a saúde das instâncias
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  # Health check — verifica se as instâncias estão respondendo corretamente
  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-tg"
  })
}

# -----------------------------------------------------------------------------
# Listener do ALB
# Escuta na porta 80 (HTTP) e encaminha o tráfego para o Target Group
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Ação padrão: encaminhar tráfego para o Target Group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-listener"
  })
}

# -----------------------------------------------------------------------------
# Auto Scaling Group (ASG)
# Gerencia automaticamente o número de instâncias EC2 com base nas
# capacidades desejada, mínima e máxima definidas via variáveis
# Distribui as instâncias pelas subnets públicas para alta disponibilidade
# -----------------------------------------------------------------------------
resource "aws_autoscaling_group" "main" {
  name                      = "${var.project_name}-asg"
  desired_capacity          = var.asg_desired
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  vpc_zone_identifier       = data.aws_subnets.public.ids
  health_check_grace_period = 120
  health_check_type         = "EC2"

  # Associação com o Target Group do ALB para registro automático das instâncias
  target_group_arns = [aws_lb_target_group.main.arn]

  # Launch Template que define a configuração das instâncias EC2
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  # Tags propagadas para as instâncias criadas pelo ASG
  tag {
    key                 = "Name"
    value               = "${var.project_name}-ec2"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "terraform"
    propagate_at_launch = true
  }
}
