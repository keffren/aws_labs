resource "aws_route53_zone" "private" {
    name = "handson1.in"

    vpc {
      vpc_id = aws_vpc.main_vpc.id
    }

    tags = {
        Name = "Private Zone"
        Terraform = "true"
        Environment = "dev"
        LabNumber= "1"
    }
}

#Create Record: Simple Routing Policy

# Manage DB requests
resource "aws_route53_record" "db_record" {
  zone_id = aws_route53_zone.private.id
  name    = "db01.handson1.in"
  type    = "A"
  ttl     = 300
  records = [ "10.0.1.100" ]

}

#Manage TomCat MemCache requests
resource "aws_route53_record" "tomcat_memcache" {
  zone_id = aws_route53_zone.private.id
  name    = "mc01.handson1.in"
  type    = "A"
  ttl     = 300
  records = [ "10.0.1.101" ]

}

#Manage RabbitMQ requests
resource "aws_route53_record" "rabbitmq" {
  zone_id = aws_route53_zone.private.id
  name    = "rmq01.handson1.in"
  type    = "A"
  ttl     = 300
  records = [ "10.0.1.102" ]

}