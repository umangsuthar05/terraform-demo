locals {
  ec2_cluster_cloudinit = templatefile("${path.module}/cloud-init.yml.tpl", {
    cluster = var.stack_name
  })
}

resource "aws_launch_template" "default" {
  name                   = var.stack_name
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name              = var.pem_key_name
  user_data             = base64encode(local.ec2_cluster_cloudinit)
  ebs_optimized         = true
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.asg_ec2_instance_profile.arn
  }  

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.ec2.id]  # Changed this line to reference the security group ID
    delete_on_termination = true
}

  dynamic "monitoring" {
    for_each = tobool(var.detailed_ec2_monitoring) ? [1] : [] 
    content {
      enabled = true 
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
        volume_size = var.volume_size
        volume_type = "gp3"
        delete_on_termination = true
        encrypted = true   
    }  
  }

    metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

    tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = var.stack_name
      Environment = var.environment
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = var.stack_name
      Environment = var.environment
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}