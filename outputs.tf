output "instance" {
  description = "Created RocketMQ instance identifiers and connection information. Sensitive to avoid exposing endpoints in CLI output; state remains unencrypted unless the configured backend encrypts it."
  value = {
    id              = volcenginecc_rocketmq_instance.this.instance_id
    name            = volcenginecc_rocketmq_instance.this.instance_name
    status          = volcenginecc_rocketmq_instance.this.instance_status
    connection_info = volcenginecc_rocketmq_instance.this.connection_info
  }
  sensitive = true
}

output "topics" {
  description = "Topics keyed by the input logical keys."
  value = {
    for key, topic in volcenginecc_rocketmq_topic.this : key => {
      id           = topic.id
      name         = topic.topic_name
      message_type = topic.message_type
    }
  }
}

output "groups" {
  description = "Consumer groups keyed by the input logical keys."
  value = {
    for key, group in volcenginecc_rocketmq_group.this : key => {
      id       = group.id
      group_id = group.group_id
    }
  }
}

output "access_key_ids" {
  description = "RocketMQ AccessKey IDs keyed by the input logical keys. Sensitive to avoid exposing identifiers in CLI output; secret keys are not output."
  value       = { for key, access_key in volcenginecc_rocketmq_access_key.this : key => access_key.access_key }
  sensitive   = true
}

output "allow_list_ids" {
  description = "RocketMQ allow list IDs keyed by the input logical keys."
  value       = { for key, allow_list in volcenginecc_rocketmq_allow_list.this : key => allow_list.allow_list_id }
}
