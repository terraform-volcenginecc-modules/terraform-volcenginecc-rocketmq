# terraform-volcenginecc-rocketmq

用于私有网络 Volcengine RocketMQ 实例及消息对象的 Terraform 模块草案。

## 1. 概述

模块管理一个 RocketMQ 实例及其 Topic、消费者 Group、IPv4 白名单和 RocketMQ AccessKey。调用方管理 VPC、Subnet、安全组、Provider 配置和任意 CloudMonitor 告警规则。修改 VPC 或 Subnet 会替换实例；输入 map 的 key 是 Terraform 地址，必须保持稳定。

## 2. 用法

### 2.1 基础用法

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

## 3. 示例

`basic` 创建私网实例、普通订单事件 Topic 和一个消费者 Group。`complete` 描述订单与业务事件，覆盖普通 Topic、AccessKey 权限、IPv4 白名单和重试配置。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | >= 1.5.0 |
| volcenginecc | >= 0.0.71 |

## 5. Provider

| 名称 | 来源 |
|---|---|
| volcenginecc | volcengine/volcenginecc |

## 6. 资源

| 名称 | 类型 |
|---|---|
| RocketMQ 实例 | `volcenginecc_rocketmq_instance` |
| Topic | `volcenginecc_rocketmq_topic` |
| 消费者 Group | `volcenginecc_rocketmq_group` |
| IPv4 白名单 | `volcenginecc_rocketmq_allow_list` |
| AccessKey | `volcenginecc_rocketmq_access_key` |

## 7. 输入

| 名称 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `vpc_id` | `string` | 是 | 已有 VPC ID；对实例不可变。 |
| `subnet_id` | `string` | 是 | 已有 Subnet ID；对实例不可变。 |
| `instance` | object | 是 | 实例版本、可用区、规格、存储、保留时长、计费和可选配置。`PrePaid` 必须设置 `period`：按月（未设置 `period_unit` 时的默认值）为 1-9，按年为 1-3。 |
| `topics` | map(object) | 否 | 按稳定逻辑 key 管理 Topic。4.8 仅支持普通类型 `0`；其他类型须使用 5.x。 |
| `groups` | map(object) | 否 | 按稳定逻辑 key 管理消费者 Group。 |
| `allow_lists` | map(object) | 否 | 按稳定逻辑 key 管理 IPv4 白名单。每个地址必须是 IPv4 地址，或前缀为 `/0` 至 `/32` 的 IPv4 CIDR。 |
| `access_keys` | map(object) | 否 | 按稳定逻辑 key 管理 AccessKey 及其默认和按 Topic 的权限。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `instance` | 实例 ID、名称、状态和连接信息。 |
| `topics` | 按输入逻辑 key 返回 Topic。 |
| `groups` | 按输入逻辑 key 返回消费者 Group。 |
| `access_key_ids` | 仅返回 AccessKey ID，不输出 SecretKey。 |
| `allow_list_ids` | 按输入逻辑 key 返回白名单 ID。 |

## 9. 注意事项

- RocketMQ 5.x 及其 TPS 比例可能需要服务白名单资格；执行 apply 前请确认账户可用规格和可用区。
- 线上验证表明 4.8 会将事务和顺序 Topic 回读为普通 Topic，因此模块在 4.8 下拒绝非普通 Topic，避免二次 plan 持续替换。5.x 当前不支持 AccessKey，配置 `access_keys` 会在 plan 阶段失败。
- Provider 将 `allow_list_ids`、Topic 权限和若干可选字段定义为 Optional+Computed。模块显式提供其管理值，但必须通过真实云二次 `plan` 确认无漂移。
- RocketMQ 根据消费者 Group 的重试配置生成重试和死信行为；Provider 没有独立 DLQ 资源，因此模块不管理死信 Topic。
- Provider 没有 RocketMQ 专用告警资源。请使用输出的实例和 Group 标识，在模块外组合 CloudMonitor 告警。
- `instance` 和 `access_key_ids` 输出已标记为 sensitive，以避免端点和 AccessKey ID 出现在标准 CLI 输出中。Provider v0.0.71 会在 AccessKey 创建后仅返回一次 `secret_key`，但其 schema 尚未标记为 sensitive；本模块不会输出该字段。
- Terraform 的 sensitive 标记只会在 CLI 输出中脱敏，不会加密 State 或保存的 Plan 文件。请使用启用加密且遵循最小权限原则的远端 Backend，将 Plan 文件按敏感信息保管，且不要提交这两类文件。
- Provider 支持导入；将已有对象导入本模块时，需要匹配模块资源地址并提供完整配置。
- 当前状态：`draft`。静态检查不能替代真实云 create、二次无变更 plan、update、replacement、destroy 和删除后查询确认。
