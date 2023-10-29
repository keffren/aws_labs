# Retrieve SSL certificate from ACM
data "aws_acm_certificate" "ssl_certificate" {
  domain   = "*.mateodev.cloud"
  statuses = ["ISSUED"]
}

resource "aws_lb_target_group" "app_tg" {
    name     = "App-TG"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = aws_vpc.main_vpc.id

    health_check {
        path                = "/login"
        port                = 8080
        protocol            = "HTTP"
        healthy_threshold   = 3
    }

    tags = {
        Name = "Target Group App"
        Terraform = "true"
        Environment = "dev"
        LabNumber= "1"
    }
}

resource "aws_lb_target_group_attachment" "app_ec2_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app.id
  port             = 8080
}

resource "aws_lb" "main" {
  name               = "main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb.id]
  subnets            = ["${aws_subnet.main_subnet.id}", "${aws_subnet.failover_subnet.id}"]

  enable_deletion_protection = false

  tags = {
    Name = "Main ALB"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}

resource "aws_lb_listener" "alb_https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ssl_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = {
    Name = "HTTPS ALB Listener"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}

resource "aws_lb_listener" "alb_http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = {
    Name = "HTTP ALB Listener"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}