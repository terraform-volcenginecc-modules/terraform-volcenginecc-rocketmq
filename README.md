# terraform-volcenginecc-rocketmq

Draft Terraform module for a private Volcengine RocketMQ instance and its messaging objects.

## 1. Overview

The module owns one RocketMQ instance, its Topics, consumer Groups, IPv4 allow lists, and RocketMQ AccessKeys. Callers own the VPC, subnet, security groups, provider configuration, and any CloudMonitor alert rules. VPC and subnet changes replace the instance; input map keys are Terraform addresses and must remain stable.

## 2. Usage

### 2.1 Basic Usage

```hcl
module "rocketmq" {
  source  = "terraform-volcenginecc-modules/rocketmq/volcenginecc"
  version = "~> 1.0"

  vpc_id    = "vpc-xxx"
  subnet_id = "subnet-xxx"
  instance = {
    name               = "orders"
    version            = "4.8"
    zone_id            = "cn-beijing-a"
    compute_spec       = "rocketmq.x2.2k"
    storage_space      = 100
    file_reserved_time = 72
    charge_type        = "PostPaid"
  }
}
```

## 3. Examples

`basic` creates a private instance, a normal order-event Topic, and one consumer Group. `complete` models order and business events with normal Topics, AccessKey permissions, an IPv4 allow list, and retry configuration.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | >= 1.5.0 |
| volcenginecc | >= 0.0.71 |

## 5. Providers

| Name | Source |
|---|---|
| volcenginecc | volcengine/volcenginecc |

## 6. Resources

| Name | Type |
|---|---|
| RocketMQ instance | `volcenginecc_rocketmq_instance` |
| Topic | `volcenginecc_rocketmq_topic` |
| consumer Group | `volcenginecc_rocketmq_group` |
| IPv4 allow list | `volcenginecc_rocketmq_allow_list` |
| AccessKey | `volcenginecc_rocketmq_access_key` |

## 7. Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `vpc_id` | `string` | yes | Existing VPC ID; immutable for the instance. |
| `subnet_id` | `string` | yes | Existing subnet ID; immutable for the instance. |
| `instance` | object | yes | Instance version, zone, specification, storage, retention, billing, and optional settings. |
| `topics` | map(object) | no | Topics keyed by stable logical keys. Version 4.8 supports normal type `0` only; other types require 5.x. |
| `groups` | map(object) | no | Consumer Groups keyed by stable logical keys. |
| `allow_lists` | map(object) | no | IPv4 allow lists keyed by stable logical keys. |
| `access_keys` | map(object) | no | AccessKeys keyed by stable logical keys with default and per-Topic permissions. |

## 8. Outputs

| Name | Description |
|---|---|
| `instance` | Instance ID, name, status, and connection information. |
| `topics` | Topics keyed by input logical keys. |
| `groups` | Consumer Groups keyed by input logical keys. |
| `access_key_ids` | AccessKey IDs only; secret keys are never output. |
| `allow_list_ids` | Allow-list IDs keyed by input logical keys. |

## 9. Notes

- RocketMQ 5.x and its TPS ratio may require service entitlement. Verify available specifications and zones before apply.
- Real-cloud validation found that 4.8 reads transactional and ordered Topics back as normal Topics. The module rejects non-normal Topics for 4.8 to prevent perpetual replacements; 5.x currently rejects AccessKey resources, so `access_keys` is rejected at plan time for 5.x.
- The provider exposes `allow_list_ids`, topic policies, and several optional values as Optional+Computed. The module supplies managed values explicitly, but a real-cloud second `plan` must confirm no drift.
- RocketMQ creates retry and dead-letter behavior from consumer Group retry configuration; the provider has no standalone DLQ resource, so DLQ topics are not managed here.
- The provider has no RocketMQ-specific alert resource. Compose CloudMonitor alarms outside this module with the output instance and Group identifiers.
- Import is supported by the provider, but importing pre-existing objects into this module requires matching the module's resource addresses and complete configuration.
- Status: `draft`. Static checks do not replace real-cloud create, second no-change plan, update, replacement, destroy, and post-delete read-back verification.
