# RocketMQ 完整示例

## 1. 概述

创建一个用于订单和业务事件的私网 RocketMQ 4.8 工作负载，包含普通消息 Topic、AccessKey 授权、IPv4 白名单和消费者重试。

## 2. 用法

提供已有网络 ID、可用的 4.8 可用区和规格，以及应用私网 CIDR。执行 `terraform init`、`terraform plan` 和 `terraform apply`。

## 3. 示例

配置展示实例创建、普通 Topic、Group、白名单和按 Topic 的发布/订阅权限管理。

## 4. 版本要求

需要 Terraform >= 1.5.0 和 volcenginecc >= 0.0.71。执行 apply 前必须确认 RocketMQ 4.8 的可用规格和配额。

## 5. Provider

调用方配置 `volcengine/volcenginecc`。

## 6. 资源

已发布的 RocketMQ 模块管理实例、普通 Topic、Group、白名单和 AccessKey。

## 7. 输入

必须提供 `vpc_id`、`subnet_id`、`zone_id`、`compute_spec` 和 `allowed_ipv4_cidrs`。`storage_space` 默认值为 100 GiB。

## 8. 输出

示例输出实例详情、Topic 名称和 AccessKey ID，不输出 SecretKey。

## 9. 注意事项

Provider 没有独立的 DLQ 或 RocketMQ 告警资源。请在模块外配置 CloudMonitor，并在真实云 apply 后确认第二次 plan 无变更。模块当前拒绝在 4.8 中配置事务或顺序 Topic，也拒绝在 5.x 中配置 AccessKey，避免已知服务端能力限制造成持续漂移或 apply 失败。
