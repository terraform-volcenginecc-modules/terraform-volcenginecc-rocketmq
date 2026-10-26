# Complete RocketMQ Example

## 1. Overview

Creates a private RocketMQ 4.8 workload for order and business events with normal Topics, AccessKey authorization, an IPv4 allow list, and consumer retries.

## 2. Usage

Provide existing network IDs, an available 4.8 zone and specification, and private application CIDRs. Run `terraform init`, `terraform plan`, and `terraform apply`.

## 3. Examples

The configuration demonstrates instance creation, normal Topics, Groups, allow lists, and per-Topic publish and subscribe permissions.

## 4. Requirements

Terraform >= 1.5.0 and volcenginecc >= 0.0.71 are required. Confirm the available RocketMQ 4.8 specification and quota before apply.

## 5. Providers

The caller configures `volcengine/volcenginecc`.

## 6. Resources

The published RocketMQ module manages the instance, normal Topics, Groups, allow list, and AccessKeys.

## 7. Inputs

`vpc_id`, `subnet_id`, `zone_id`, `compute_spec`, and `allowed_ipv4_cidrs` are required. `storage_space` defaults to 100 GiB.

## 8. Outputs

The example returns instance details, Topic names, and AccessKey IDs without secret keys. Instance details and AccessKey IDs are marked sensitive and redacted in standard CLI output.

## 9. Notes

The provider has no standalone DLQ or RocketMQ alarm resource. Configure CloudMonitor outside the module and verify a no-change second plan after real-cloud apply. Destroy with `terraform destroy -parallelism=1` because RocketMQ deletion is asynchronous and concurrent deletion can return `InvalidInstanceStatus`. The module rejects transactional and ordered Topics for 4.8, and rejects AccessKeys for 5.x, to prevent known service-side drift and apply failures.
