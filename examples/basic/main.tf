module "rocketmq" {
  source = "terraform-volcenginecc-modules/rocketmq/volcenginecc"

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  instance = {
    name               = var.instance_name
    version            = "4.8"
    zone_id            = var.zone_id
    compute_spec       = var.compute_spec
    storage_space      = var.storage_space
    file_reserved_time = 72
    charge_type        = "PostPaid"
    tags = [
      {
        key   = "environment"
        value = "development"
      }
    ]
  }

  topics = {
    orders = {
      name         = "orders"
      message_type = 0
      queue_number = 6
      description  = "Order event messages."
    }
  }

  groups = {
    order_consumer = {
      group_id        = "GID_order_consumer"
      description     = "Order event consumers."
      retry_max_times = 16
    }
  }
}
