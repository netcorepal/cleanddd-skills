# CleanDDD Skill

English version: [README.en.md](README.en.md)

本技能集提供领域驱动设计（DDD）建模与适配 CleanDDD 的 .NET 项目脚手架方面的专业知识。

## Skills

| Skill | Description |
| --- | --- |
| [cleanddd-requirements-analysis](skills/cleanddd-requirements-analysis/SKILL.md) | 将业务需求拆解为 CleanDDD 建模输入的分析流程和结构化输出 |
| [cleanddd-dotnet-init](skills/cleanddd-dotnet-init/SKILL.md) | 使用 `dotnet new` 基于 `NetCorePal.Template` 模板快速初始化 CleanDDD 项目 |
| [cleanddd-modeling](skills/cleanddd-modeling/SKILL.md) | 基于 CleanDDD 的软件系统分析建模技能 |
| [cleanddd-dotnet-coding](skills/cleanddd-dotnet-coding/SKILL.md) | 基于 CleanDDD 建模结果，使用 NetCorePal 框架范式编写代码（.NET 平台 csharp 语言） |
| [cleanddd-coach](skills/cleanddd-coach/SKILL.md) | 交互式 CleanDDD 教练：微课 + 测验 + 检查清单，帮助掌握核心原则并串联到需求分析/建模/编码 |

## 使用步骤

1. 克隆代码到本地

	 ```bash
	 git clone https://github.com/netcorepal/cleanddd-skills.git
	 cd cleanddd-skills
	 ```

2. 运行安装脚本（将技能同步到当前用户全局目录）

	 - Windows (PowerShell)：

		 ```powershell
		 ./scripts/install-skills.ps1
		 ```

	 - macOS/Linux：

		 ```bash
		 chmod +x scripts/install-skills.sh
		 ./scripts/install-skills.sh
		 ```

3. 与 Agent 聊天，按顺序使用：

	 - 需求拆解：调用 cleanddd-requirements-analysis，生成结构化需求与事件流。
	 - 领域建模：调用 cleanddd-modeling，基于上一步输出生成聚合/命令/查询/事件/Endpoint 设计。
	 - 项目初始化：调用 cleanddd-dotnet-init，用模板创建项目骨架。
	 - 代码实现：调用 cleanddd-dotnet-coding，基于模型生成代码骨架或具体实现。

也可以直接发送给 Agent 的示例提示词：

	 - “请先用 cleanddd-requirements-analysis 拆解 XXX 需求，给出表格化输出，然后用 cleanddd-modeling 生成模型设计。”
	 - “使用 cleanddd-dotnet-init 创建一个包含 RabbitMQ 和 MySql 的 CleanDDD 项目。”
	 - “基于上述模型，实现代码骨架。”

脚本会将仓库内 `skills/` 下的技能逐个同步到目标目录，如已有同名技能会先删除后再复制，确保版本一致。