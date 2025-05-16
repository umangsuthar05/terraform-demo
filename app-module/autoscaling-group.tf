resource "aws_lb_target_group" "ec2_health_check" {
    name = substr("${var.stack_name}-ec2-hc", 0, 32)
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id

health_check {
  protocol = "HTTP"
  port = "80"
  path = "/index.html"
  interval = 120
  timeout = 60
  healthy_threshold = 2
  unhealthy_threshold = 2
  matcher = "200-399"
}

target_type = "instance"
    }

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = var.health_check_listener_arn
  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.ec2_health_check.arn
        weight = 100
      }

      stickiness {
        enabled = true
        duration = 600
      }
    }
  }

  condition {
    host_header {
      values = ["${var.stack_name}.healthcheck.e2m"]
    }
 }

lifecycle {
    create_before_destroy = true
}
}