output "alb_dns_name" {
  value = module.alb.lb_dns_name
}

output "rds_endpoint" {
  value = module.db.cluster_endpoint
}

output "web_instance_ids" {
  description = "IDs of EC2 instances"
  value       = values(module.web_servers)[*].id
}