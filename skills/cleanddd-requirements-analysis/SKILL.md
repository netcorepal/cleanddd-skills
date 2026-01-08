---
name: cleanddd-requirements-analysis
description: 将业务需求拆解为 CleanDDD 建模输入的分析流程和输出格式
---

# CleanDDD 需求分析技能

面向 CleanDDD 建模前的需求澄清与拆解，产出可直接用于建模（聚合/命令/事件/查询/Endpoint）的结构化结果。

## 流程

1. 需求拆分：将需求拆分为可执行条目（查看/创建/修改/关闭等），保持粒度清晰。
2. 聚合映射：识别可承担条目的聚合，列出“聚合 → 需求条目”映射，确保职责内聚。
3. 跨聚合影响：分析操作触发的后续动作（DomainEvent）及订阅方，明确事件与处理器。
4. 产出工件：将条目映射为 Command、Query、Endpoint、DomainEvent、DomainEventHandler，并注明所属聚合。

## 输出格式（结构化 Markdown）

- 概览表：聚合 | 职责摘要 | 关键命令/查询数 | 主要事件
- 需求条目表：需求ID | 场景描述 | 所属聚合 | 操作类型(Command/Query) | 备注
- 聚合映射表：聚合 | 覆盖的需求条目 | 关键不变式
- 事件流表：DomainEvent | 触发操作/聚合 | 订阅方 | 处理动作 | 副作用/结果
- Endpoint/接口表：Endpoint | 方法 | Command/Query | 认证/鉴权 | 幂等/一致性说明
- 可选 Mermaid：节点命名与表格一致，便于校验

## 命名与确认

- 命名：聚合/事件/命令用 PascalCase；枚举值保持固定拼写。
- 默认值与可选值：在表格中明确，减少后续交互。
- 执行前确认：在输出末尾附“参数汇总 + 是否执行”提示，便于 Agent 在行动前向用户确认。
