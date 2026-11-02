variable "vpc_id" {
  description = "Existing VPC ID."
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID in the VPC."
  type        = string
}

variable "zone_id" {
  description = "RocketMQ availability zone ID."
  type        = string
}

variable "instance_name" {
  description = "RocketMQ instance name."
  type        = string
  default     = "rocketmq-basic"
}

variable "compute_spec" {
  description = "Available RocketMQ compute specification for the selected zone."
  type        = string
}

variable "storage_space" {
  description = "Storage in GiB, in multiples of 100."
  type        = number
  default     = 100
}
