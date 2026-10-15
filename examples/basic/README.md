# Basic RocketMQ Example

## 1. Overview

Creates a private RocketMQ 4.8 instance, a normal Topic for order events, and one consumer Group.

## 2. Usage

Provide existing `vpc_id`, `subnet_id`, an available `zone_id`, and a valid `compute_spec`, then run `terraform init`, `terraform plan`, and `terraform apply`.

## 3. Examples

This is the minimal instance creation, Topic, and Group scenario.

## 4. Requirements

Terraform >= 1.5.0 and volcenginecc >= 0.0.71 are required.

## 5. Providers

The caller configures `volcengine/volcenginecc`.

## 6. Resources

The published RocketMQ module manages the instance, Topic, and Group.

## 7. Inputs

`vpc_id`, `subnet_id`, `zone_id`, and `compute_spec` are required. `storage_space` defaults to 100 GiB.

## 8. Outputs

The example returns the instance ID and Topic names.

## 9. Notes

VPC and subnet remain caller-owned. A second real-cloud `terraform plan` after apply must report no changes.
