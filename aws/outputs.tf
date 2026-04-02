output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "lb_sg_id" { value = aws_security_group.lb_sg.id }
output "app_sg_id" { value = aws_security_group.app_sg.id }
output "db_sg_id" { value = aws_security_group.db_sg.id }

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}

output "rds_db_name" {
  value = aws_db_instance.postgres.db_name
}

output "rds_username" {
  value = aws_db_instance.postgres.username
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app.bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.user_verification.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.email_tracking.name
}