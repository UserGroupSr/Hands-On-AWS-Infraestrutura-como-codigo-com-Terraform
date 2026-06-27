# =============================================================================
# IAM — Role, Policy Attachment e Instance Profile para as instâncias EC2
# =============================================================================

# IAM Role que permite instâncias EC2 assumirem a role via sts:AssumeRole
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Anexa a policy gerenciada AmazonS3ReadOnlyAccess à role
# Permite que as instâncias EC2 leiam os arquivos do bucket S3
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Anexa a policy gerenciada AmazonSSMManagedInstanceCore à role
# Permite que o SSM Agent se registre e a instância seja gerenciada via Systems Manager
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile associado à role — vinculado ao Launch Template das instâncias EC2
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = var.common_tags
}
