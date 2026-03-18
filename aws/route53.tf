# Get the hosted zone for the demo subdomain
data "aws_route53_zone" "demo" {
  name         = "demo.aakrutighatole.me"
  private_zone = false
}

# A record pointing demo.aakrutighatole.me to EC2 instance
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "demo.aakrutighatole.me"
  type    = "A"
  ttl     = 300
  records = [aws_instance.app.public_ip]
}