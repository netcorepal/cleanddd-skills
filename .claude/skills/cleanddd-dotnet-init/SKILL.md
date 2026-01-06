---
name: cleanddd-dotnet-init
description: CleanDDD dotnet 项目工程创建技能，负责全新的符合CleanDDD模式的项目构建
---

# cleanddd dotnet init

根据后端技术栈要求，创建CleanDDD dotnet工程

## 输入要求

- dotnet sdk 版本, 默认 net10.0
- 数据库类型, 默认： MySQL
- 消息队列基础设施类型，默认：RabbitMQ
- 是否使用 Aspire ，默认: true

## 最佳实践


安装模板

``` shell
dotnet new install NetCorePal.Template
```

```shell
# 查看所有可用的参数和选项
dotnet new netcorepal-web --help

# 查看所有已安装的模板
dotnet new list
```


#### 可用参数

| 参数 | 短参数 | 说明 | 可选值 | 默认值 |
|------|--------|------|--------|--------|
| `--Framework` | `-F` | 目标 .NET 框架版本 | `net8.0`, `net9.0`, `net10.0` | `net10.0` |
| `--Database` | `-D` | 数据库提供程序 | `MySql`, `SqlServer`, `PostgreSQL`, `Sqlite`, `GaussDB`, `DMDB`, `MongoDB` | `MySql` |
| `--MessageQueue` | `-M` | 消息队列提供程序 | `RabbitMQ`, `Kafka`, `AzureServiceBus`, `AmazonSQS`, `NATS`, `RedisStreams`, `Pulsar` | `RabbitMQ` |
| `--UseAspire` | `-U` | 启用 Aspire Dashboard 支持 | `true`, `false` | `false` |
