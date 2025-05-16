resource "aws_lb" "ecs_alb" {
    name                             = local.shared_cluster_name
    internal                         = false
    load_balancer_type               = "application"
    security_groups                  = [aws_security_group.elb.id]
    subnets                          = data.terraform_remote_state.global.outputs.subnet_id
    enable_cross_zone_load_balancing = true
    enable_deletion_protection       = true
    idle_timeout = 4000

    lifecycle {
        create_before_destroy = true
    }
}

output "elb_endpoint" {
  value = aws_lb.ecs_alb.dns_name
}
    
output "shared_lb_arn" {
  value = aws_lb.ecs_alb.arn
}    

resource "aws_lb_listener" "alb_listener_80" {
  load_balancer_arn = aws_lb.ecs_alb.arn

  port     = 80
  protocol = "HTTP"
  default_action {
    type             = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "health_check" {

  load_balancer_arn = aws_lb.ecs_alb.arn
  port = 8888
  protocol = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "you are not authorized to access this page "
      status_code  = "200"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "health_check_listener_arn" {
  value = aws_lb_listener.health_check.arn
  
}

resource "aws_lb_listener" "ecs_alb_listener_443" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port     = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:761275507839:certificate/57e8e467-d39f-43dd-8f71-54871edd13e0"
  default_action {
    type  =  "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "you are not authorized to access this page "
      status_code  = "403"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "aws_lb_listener" {
  value = aws_lb_listener.ecs_alb_listener_443.arn
}

resource "aws_lb_listener_certificate" "demo_cert" {
  listener_arn    = aws_lb_listener.ecs_alb_listener_443.arn
  certificate_arn = "arn:aws:acm:us-east-1:761275507839:certificate/57e8e467-d39f-43dd-8f71-54871edd13e0"
}

resource "aws_lb_target_group" "ecs-default" {
    name = "ecs-default"
    target_type = "instance"
    port = 443
    protocol = "HTTPS"
    vpc_id = data.terraform_remote_state.global.outputs.vpc_id

    load_balancing_algorithm_type = "least_outstanding_requests"

 stickiness {
  enabled = true
  type = "lb_cookie"        
 } 


health_check {
    healthy_threshold   = 2
    interval            = 61
    protocol            = "HTTP"
    unhealthy_threshold = 2
    path                = "/"
    port                = "traffic-port"
    timeout             = 60
    matcher             = "200-399"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "default" {
  name     = "default"
  port     = 443
  protocol = "TCP"
  vpc_id   = data.terraform_remote_state.global.outputs.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}   


resource "aws_lb_target_group" "demo" {
  name        = "demo"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.global.outputs.vpc_id

  load_balancing_algorithm_type = "least_outstanding_requests"

    stickiness {
    enabled = true
    type    = "lb_cookie"
  }

    health_check {
    healthy_threshold   = 2
    interval            = 61
    protocol            = "HTTP"
    unhealthy_threshold = 2
    path                = "/"
    port                = "traffic-port"
    timeout             = 60
    matcher             = "200-399"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "demo" {
  listener_arn = aws_lb_listener.ecs_alb_listener_443.arn
  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.demo.arn
        weight = 100
      }
      target_group {
        arn    = aws_lb_target_group.ecs-default.arn
        weight = 0
      }
      stickiness {
        enabled  = true
        duration = 600
      }
    }
  }
  condition {
    host_header {
      values = ["demo.com", "*.demo.com"]
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "lb_arn_suffix" {
  value = aws_lb.ecs_alb.arn_suffix
}