resource "aws_security_group" "ec2" {
  name        = "${var.stack_name}-ec2-sg"
  vpc_id      = var.vpc_id
  description = "EC2 - Inbound"

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${var.elb_security_group_id}"]
    description     = "From Public"
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["103.240.34.222/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["14.194.54.150/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["102.129.154.54/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name      = "EC2 - Inbound"
    ManagedBy = "Terraform"
  }
  lifecycle {
    create_before_destroy = false
  }
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}