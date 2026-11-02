module "rocketmq" {
  source = "terraform-volcenginecc-modules/rocketmq/volcenginecc"

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  instance = {
    name               = var.instance_name
    description        = "Private RocketMQ workload for orders and business events."
    version            = "4.8"
    zone_id            = var.zone_id
    compute_spec       = var.compute_spec
    storage_space      = var.storage_space
    file_reserved_time = 72
    charge_type        = "PostPaid"
    enable_ssl         = true
    tags = [
      {
        key   = "environment"
        value = "production"
      },
      {
        key   = "workload"
        value = "orders"
      }
    ]
  }

  allow_lists = {
    application = {
      name         = "application-clients"
      ip_addresses = var.allowed_ipv4_cidrs
      description  = "Application subnets allowed to connect."
    }
  }

  access_keys = {
    producer = {
      all_authority = "DENY"
      description   = "Order and business event producers."
      topic_permissions = [
        {
          topic_key  = "order_events"
          permission = "PUB"
        },
      ]
    }
    consumer = {
      all_authority = "DENY"
      description   = "Order event consumers."
      topic_permissions = [
        {
          topic_key  = "order_events"
          permission = "SUB"
        },
      ]
    }
  }

  topics = {
    order_events = {
      name         = "order_events"
      message_type = 0
      queue_number = 6
      description  = "Order lifecycle events and peak-shaving buffer."
    }
    business_events = {
      name         = "business_events"
      message_type = 0
      queue_number = 6
      description  = "Business events for downstream fulfillment."
    }
  }

  groups = {
    order_consumer = {
      group_id                = "GID_order_consumer"
      description             = "Order event consumers with retry and DLQ handling."
      consume_message_orderly = false
      retry_max_times         = 16
    }
    fulfillment_consumer = {
      group_id                = "GID_fulfillment_consumer"
      description             = "Fulfillment event consumers."
      consume_message_orderly = true
      retry_max_times         = 16
    }
  }
}
