# RocketMQ 基础示例

## 1. 概述

创建一个私网 RocketMQ 4.8 实例、一个订单事件普通 Topic 和一个消费者 Group。

## 2. 用法

提供已有的 `vpc_id`、`subnet_id`、可用的 `zone_id` 和有效的 `compute_spec`，然后执行 `terraform init`、`terraform plan` 和 `terraform apply`。

## 3. 示例

这是实例创建、Topic 和 Group 的最小场景。

## 4. 版本要求

需要 Terraform >= 1.5.0 和 volcenginecc >= 0.0.71。

## 5. Provider

调用方配置 `volcengine/volcenginecc`。

## 6. 资源

已发布的 RocketMQ 模块管理实例、Topic 和 Group。

## 7. 输入

必须提供 `vpc_id`、`subnet_id`、`zone_id` 和 `compute_spec`。`storage_space` 默认值为 100 GiB。

## 8. 输出

示例输出实例 ID 和 Topic 名称。

## 9. 注意事项

VPC 和 Subnet 仍由调用方管理。真实云 apply 后，第二次 `terraform plan` 必须显示无变更。
