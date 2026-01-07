# CleanDDD Skill

This skill collection provides expertise in Domain-Driven Design (DDD) modeling and CleanDDD-friendly .NET project scaffolding.

## Skills

| Skill | Description |
| --- | --- |
| [cleanddd-dotnet-init](skills/cleanddd-dotnet-init/SKILL.md) | 使用 `dotnet new` 基于 `NetCorePal.Template` 模板快速初始化 CleanDDD 项目 |
| [cleanddd-modeling](skills/cleanddd-modeling/SKILL.md) | 基于 CleanDDD 的软件系统分析建模技能 |
| [cleanddd-dotnet-coding](skills/cleanddd-dotnet-coding/SKILL.md) | 基于 CleanDDD 建模结果，使用 NetCorePal 框架范式编写代码（.NET 平台 csharp 语言） |

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

脚本会将仓库内 `skills/` 下的技能逐个同步到目标目录，如已有同名技能会先删除后再复制，确保版本一致。