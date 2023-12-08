# Create Application Load Balancer
resource "aws_lb" "alb" {
    name               = "lab-04-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb.id]
    subnets            = [for subnet in aws_subnet.public : subnet.id]


    tags = {
        Name = "ALB"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}

# Create EC2 target group for ALB
resource "aws_lb_target_group" "alb" {
    name     = "alb-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.main_vpc.id
}

# Attach the EC2 instance to the target group
resource "aws_lb_target_group_attachment" "attach_ec2" {

    count = length(aws_instance.app)

    target_group_arn = aws_lb_target_group.alb.arn
    target_id        = aws_instance.app[count.index].id
    port             = 80
}

# Create the alb listener
## Retrieve SSL certificate from ACM
data "aws_acm_certificate" "ssl_certificate" {
  domain   = "alb.mateodev.cloud"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "alb" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "443"
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = data.aws_acm_certificate.ssl_certificate.arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.alb.arn
    }

    tags = {
        Name = "https-alb-listener"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}
