output "instance_id" {
  description = "Created RocketMQ instance ID."
  value       = module.rocketmq.instance.id
  sensitive   = true
}

output "topic_names" {
  description = "Created topic names."
  value       = { for key, topic in module.rocketmq.topics : key => topic.name }
}
