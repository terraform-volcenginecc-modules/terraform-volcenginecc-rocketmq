variable "vpc_id" {
  description = "Existing VPC ID."
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID in the VPC."
  type        = string
}

variable "zone_id" {
  description = "RocketMQ 4.8 availability zone ID."
  type        = string
}

variable "instance_name" {
  description = "RocketMQ instance name."
  type        = string
  default     = "rocketmq-complete"
}

variable "compute_spec" {
  description = "Available RocketMQ 4.8 compute specification for the selected zone."
  type        = string
}

variable "storage_space" {
  description = "Storage in GiB, in multiples of 100."
  type        = number
  default     = 100
}

variable "allowed_ipv4_cidrs" {
  description = "Private IPv4 addresses or CIDRs allowed to access the instance."
  type        = set(string)
}
