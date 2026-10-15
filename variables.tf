variable "vpc_id" {
  description = "Existing VPC ID for the RocketMQ instance. The module does not manage the VPC."
  type        = string
  nullable    = false
}

variable "subnet_id" {
  description = "Existing subnet ID for the RocketMQ instance. Changing it replaces the instance."
  type        = string
  nullable    = false
}

variable "instance" {
  description = "RocketMQ instance configuration. VPC and subnet are separate immutable inputs."
  type = object({
    name               = string
    description        = optional(string, null)
    version            = string
    zone_id            = string
    compute_spec       = string
    storage_space      = number
    file_reserved_time = number
    charge_type        = string
    period             = optional(number, null)
    period_unit        = optional(string, null)
    auto_renew         = optional(bool, null)
    enable_ssl         = optional(bool, true)
    eip_id             = optional(string, null)
    ip_version_type    = optional(string, "IPv4")
    project_name       = optional(string, null)
    auto_scale_queue   = optional(bool, null)
    send_receive_ratio = optional(number, null)
    ssl_mode           = optional(string, null)
    tags               = optional(set(object({ key = string, value = string })), [])
  })
  nullable = false

  validation {
    condition     = contains(["4.8", "5.x"], var.instance.version)
    error_message = "instance.version must be 4.8 or 5.x."
  }

  validation {
    condition     = var.instance.storage_space >= 100 && var.instance.storage_space % 100 == 0
    error_message = "instance.storage_space must be a positive multiple of 100 GiB."
  }

  validation {
    condition     = var.instance.file_reserved_time >= 1 && var.instance.file_reserved_time <= 72
    error_message = "instance.file_reserved_time must be between 1 and 72 hours."
  }

  validation {
    condition     = contains(["PostPaid", "PrePaid"], var.instance.charge_type)
    error_message = "instance.charge_type must be PostPaid or PrePaid."
  }

  validation {
    condition     = var.instance.send_receive_ratio == null ? true : (var.instance.version == "5.x" && var.instance.send_receive_ratio >= 0 && var.instance.send_receive_ratio <= 100)
    error_message = "instance.send_receive_ratio is supported only for 5.x and must be from 0 to 100."
  }

  validation {
    condition     = var.instance.eip_id != null || var.instance.ssl_mode == null
    error_message = "instance.ssl_mode requires instance.eip_id."
  }

  validation {
    condition     = var.instance.ssl_mode == null ? true : contains(["enforcing", "permissive"], var.instance.ssl_mode)
    error_message = "instance.ssl_mode must be enforcing or permissive."
  }
}

variable "topics" {
  description = "Topics keyed by stable logical names. Changing a key destroys and recreates that Terraform address."
  type = map(object({
    name         = string
    message_type = number
    queue_number = number
    description  = optional(string, null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for topic in values(var.topics) :
      contains([0, 1, 2, 3, 4], topic.message_type) && topic.queue_number >= 1 &&
      (topic.message_type != 3 || topic.queue_number == 1)
    ])
    error_message = "Topic message_type must be 0-4, queue_number must be positive, and globally ordered topics (3) require one queue."
  }
}

variable "groups" {
  description = "Consumer groups keyed by stable logical names."
  type = map(object({
    group_id                = string
    description             = optional(string, null)
    consume_message_orderly = optional(bool, null)
    retry_max_times         = optional(number, null)
  }))
  default = {}

  validation {
    condition     = alltrue([for group in values(var.groups) : can(regex("^[A-Za-z0-9_-]{7,120}$", group.group_id)) && (group.retry_max_times == null ? true : group.retry_max_times >= 0)])
    error_message = "Each group_id must be 7-120 letters, numbers, underscores, or hyphens; retry_max_times cannot be negative."
  }
}

variable "allow_lists" {
  description = "IPv4 allow lists keyed by stable logical names. An empty map keeps no managed allow list."
  type = map(object({
    name         = string
    ip_addresses = set(string)
    description  = optional(string, null)
  }))
  default = {}

  validation {
    condition     = alltrue([for allow_list in values(var.allow_lists) : length(allow_list.ip_addresses) > 0])
    error_message = "Every allow list must contain at least one IPv4 address or CIDR."
  }
}

variable "access_keys" {
  description = "RocketMQ AccessKeys keyed by stable logical names. secret_key is intentionally not output."
  type = map(object({
    all_authority = string
    description   = optional(string, null)
    topic_permissions = optional(set(object({
      topic_key  = string
      permission = string
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for access_key in values(var.access_keys) :
      contains(["ALL", "PUB", "SUB", "DENY"], access_key.all_authority) &&
      alltrue([for permission in access_key.topic_permissions : contains(["ALL", "PUB", "SUB", "DENY"], permission.permission)])
    ])
    error_message = "AccessKey authorities and topic permissions must be ALL, PUB, SUB, or DENY."
  }
}
