resource "volcenginecc_rocketmq_instance" "this" {
  version              = var.instance.version
  zone_id              = var.instance.zone_id
  compute_spec         = var.instance.compute_spec
  storage_space        = var.instance.storage_space
  vpc_id               = var.vpc_id
  subnet_id            = var.subnet_id
  file_reserved_time   = var.instance.file_reserved_time
  network_types        = "PrivateNetwork"
  instance_name        = var.instance.name
  instance_description = var.instance.description
  enable_ssl           = var.instance.enable_ssl
  eip_id               = var.instance.eip_id
  ip_version_type      = var.instance.ip_version_type
  project_name         = var.instance.project_name
  auto_scale_queue     = var.instance.auto_scale_queue
  tags                 = var.instance.tags
  ssl_mode             = var.instance.ssl_mode

  charge_detail = {
    charge_type = var.instance.charge_type
    period      = var.instance.period
    period_unit = var.instance.period_unit
    auto_renew  = var.instance.auto_renew
  }

  product_info = var.instance.send_receive_ratio == null ? null : {
    send_receive_ratio = var.instance.send_receive_ratio
  }

  lifecycle {
    precondition {
      condition = var.instance.version != "4.8" || alltrue([
        for topic in values(var.topics) : topic.message_type == 0
      ])
      error_message = "RocketMQ 4.8 currently supports only normal Topics (message_type = 0) in this module. The service reads transactional and ordered Topic types back as normal Topics, which causes perpetual replacement."
    }

    precondition {
      condition     = var.instance.version != "5.x" || length(var.access_keys) == 0
      error_message = "RocketMQ 5.x currently does not support AccessKey resources for this module. Remove access_keys or use a supported 4.8 instance."
    }
  }
}

resource "volcenginecc_rocketmq_allow_list" "this" {
  for_each = var.allow_lists

  allow_list_name = each.value.name
  allow_list      = join(",", each.value.ip_addresses)
  allow_list_desc = each.value.description
  allow_list_type = "IPv4"

  associated_instances = [{
    instance_id = volcenginecc_rocketmq_instance.this.instance_id
  }]
}

resource "volcenginecc_rocketmq_access_key" "this" {
  for_each = var.access_keys

  depends_on = [volcenginecc_rocketmq_topic.this]

  instance_id   = volcenginecc_rocketmq_instance.this.instance_id
  all_authority = each.value.all_authority
  description   = each.value.description

  topic_permissions = [
    for permission in each.value.topic_permissions : {
      topic_name = var.topics[permission.topic_key].name
      permission = permission.permission
    }
  ]
}

resource "volcenginecc_rocketmq_topic" "this" {
  for_each = var.topics

  instance_id  = volcenginecc_rocketmq_instance.this.instance_id
  topic_name   = each.value.name
  message_type = each.value.message_type
  queue_number = each.value.queue_number
  description  = each.value.description
}

resource "volcenginecc_rocketmq_group" "this" {
  for_each = var.groups

  instance_id             = volcenginecc_rocketmq_instance.this.instance_id
  group_id                = each.value.group_id
  group_type              = "TCP"
  description             = each.value.description
  consume_message_orderly = each.value.consume_message_orderly
  retry_max_times         = each.value.retry_max_times
}
