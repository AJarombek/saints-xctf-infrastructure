output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.database_client_alb.dns_name
}

output "database_client_url" {
  description = "The URL for accessing the database client"
  value       = "https://db.saintsxctf.com"
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.database_client.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.database_client.name
}

