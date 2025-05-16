resource "aws_security_group" "elb" {
  vpc_id      = data.terraform_remote_state.global.outputs.vpc_id
  description = "ELB - Public"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "From Public"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "From Public"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name      = "ASG - Inbound"
    ManagedBy = "Terraform"
  }
}

output "elb_security_group_id" {
  value = aws_security_group.elb.id
}