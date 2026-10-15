# RocketMQ 示例线上验证报告

## 结论

| 验证项 | 结果 | 证据 | 结论 |
| --- | --- | --- | --- |
| basic 生命周期 | 通过 | `plan`、`apply`、二次 `plan` 均成功；二次 plan 输出 `No changes`；`destroy` 成功 | RocketMQ 4.8 基础实例、普通 Topic 和 Group 可稳定管理 |
| basic 实例配置 | 通过 | 版本 `4.8`、规格 `rocketmq.n1.x2.micro`、存储 `300 GiB`、保留 `72 h`；实例状态 `Running` | 版本、规格和消息保留配置正确 |
| complete 创建 | 通过 | 4.8 实例、2 个普通 Topic、2 个 Group、白名单和 2 个 ACL 用户共 8 个资源创建成功 | Topic、Group、ACL 和白名单均已实际创建 |
| 连接信息 | 通过 | 4.8 返回 TCP 私网端点，端口 `9876`；公网端点为空 | 输出字段正确，符合未配置 EIP 的预期，且未输出任何 SecretKey |
| ACL 权限 | 通过 | 发布用户对订单 Topic 为 `PUB`，订阅用户对订单 Topic 为 `SUB`，默认权限为 `DENY` | 用户及 Topic 级发布/订阅权限创建成功 |
| 白名单 | 通过 | IPv4 白名单 `10.0.0.0/8` 创建成功并关联验证实例 | 白名单创建和关联正确 |
| complete 二次 plan | 通过 | 二次 `terraform plan -detailed-exitcode` 输出 `No changes` | 实际云状态与配置一致 |
| destroy 清理 | 通过 | 串行 destroy 清理 8 个对象；`terraform state list` 无输出 | 临时资源已彻底删除 |

## 验证环境

| 项目 | 值 |
| --- | --- |
| 验证日期 | 2026-10-15 |
| Terraform | `1.5.7` |
| Provider | Registry 线上 `volcengine/volcenginecc v0.0.71` |
| 区域 / 可用区 | `cn-beijing` / `cn-beijing-a` |
| 网络 | 使用已存在的 VPC 和 Subnet；ID 未写入报告 |
| 凭据 | 用户提供的 AK/SK 仅通过进程环境变量原样传入，未解码、未写入文件、未输出 |

## 验证对象

| 示例 | 对象 | 配置 |
| --- | --- | --- |
| basic | RocketMQ 实例 | 4.8、`rocketmq.n1.x2.micro`、300 GiB、72 小时保留、私网 |
| basic | Topic / Group | 普通 Topic；Group 重试次数 16 |
| complete | RocketMQ 实例 | 4.8、`rocketmq.n1.x2.micro`、300 GiB、72 小时保留、SSL 启用、私网 |
| complete | Topic | 两个普通 Topic（`message_type=0`） |
| complete | Group | 两个消费者 Group，均配置重试次数 16 |
| complete | 访问控制 | 发布用户 `PUB`、订阅用户 `SUB`，默认 `DENY` |
| complete | 网络访问 | IPv4 白名单 `10.0.0.0/8`；TCP 私网端点 |

## 已执行验证

1. 使用 Terraform `1.5.7` 和 Registry 线上 Provider `v0.0.71` 依次执行 `init`、`plan`、`apply`、二次 `plan`、`destroy`。
2. basic 的实例、Topic 和 Group 均回读为 `Running`；连接信息为私网 TCP 端点，公网端点为空。
3. complete 的实例回读为 `Running`；两个普通 Topic、两个 Group、白名单和两名 ACL 用户创建完成；发布、订阅权限均由服务端回读确认。
4. complete 返回私网 TCP 端点，端口为 `9876`，公网端点为空；报告未记录 AccessKey SecretKey。
5. complete 使用 `-parallelism=1` 清理 Topic、Group、ACL 和实例，删除后 Terraform state 为空。

## Complete 生命周期执行记录

```text
terraform init
terraform plan
结果: Plan: 8 to add, 0 to change, 0 to destroy

terraform apply
结果: Apply complete! Resources: 8 added, 0 changed, 0 destroyed
实例: Running；私网 TCP 端点端口 9876；公网端点为空

terraform plan -detailed-exitcode
结果: No changes

terraform destroy -parallelism=1
结果: Destroy complete! Resources: 8 destroyed

terraform state list
结果: 无输出
```

## 2026-10-15 新版 Complete 成功参数

以下参数用于本次已通过 `plan -> apply -> 二次 plan No changes -> destroy` 的线上验证。网络标识、运行期资源标识、连接地址和凭据均未写入报告。

```hcl
instance = {
  name               = "tf-validate-complete-v2-20261015"
  description        = "Ephemeral complete lifecycle validation."
  version            = "4.8"
  zone_id            = "cn-beijing-a"
  compute_spec       = "rocketmq.n1.x2.micro"
  storage_space      = 300
  file_reserved_time = 72
  charge_type        = "PostPaid"
  enable_ssl         = true
  tags = [
    {
      key   = "validation"
      value = "rocketmq-complete-v2"
    },
  ]
}

topics = {
  order_events = {
    name         = "tf_validate_v2_order_events"
    message_type = 0
    queue_number = 6
    description  = "Order lifecycle events."
  }
  business_events = {
    name         = "tf_validate_v2_business_events"
    message_type = 0
    queue_number = 6
    description  = "Business events."
  }
}

groups = {
  order_consumer = {
    group_id                = "GID_tf_validate_v2_orders"
    consume_message_orderly = false
    retry_max_times         = 16
  }
  fulfillment_consumer = {
    group_id                = "GID_tf_validate_v2_fulfillment"
    consume_message_orderly = true
    retry_max_times         = 16
  }
}

allow_lists = {
  application = {
    name         = "tf-validate-v2-application"
    ip_addresses = ["10.0.0.0/8"]
  }
}

access_keys = {
  producer = {
    all_authority = "DENY"
    topic_permissions = [
      {
        topic_key  = "order_events"
        permission = "PUB"
      },
    ]
  }
  consumer = {
    all_authority = "DENY"
    topic_permissions = [
      {
        topic_key  = "order_events"
        permission = "SUB"
      },
    ]
  }
}
```
