output "instance" {
  description = "Created RocketMQ instance details."
  value       = module.rocketmq.instance
}

output "topic_names" {
  description = "Created topics for normal order and business event messaging."
  value       = { for key, topic in module.rocketmq.topics : key => topic.name }
}

output "access_key_ids" {
  description = "Created AccessKey IDs. Secret keys are not output."
  value       = module.rocketmq.access_key_ids
}
