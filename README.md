# CleanDDD Skill

This skill collection provides expertise in Domain-Driven Design (DDD) modeling and CleanDDD-friendly .NET project scaffolding.

## Skills

| Skill | Description |
| --- | --- |
| [cleanddd-dotnet-init](skills/cleanddd-dotnet-init/SKILL.md) | 使用 `dotnet new` 基于 `NetCorePal.Template` 模板快速初始化 CleanDDD 项目 |
| [cleanddd-modeling](skills/cleanddd-modeling/SKILL.md) | 基于 CleanDDD 的软件系统分析建模技能 |
| [cleanddd-dotnet-coding](skills/cleanddd-dotnet-coding/SKILL.md) | 基于 CleanDDD 建模结果，使用 NetCorePal 框架范式编写代码（.NET 平台 csharp 语言） |

## 全局安装到当前用户目录

将仓库内的技能复制到当前用户的全局目录 `~/.claude/skills`，便于在不同项目间共享。

- macOS/Linux：
	```bash
	chmod +x scripts/install-skills.sh
	./scripts/install-skills.sh
	# 自定义目标目录
	./scripts/install-skills.sh --target /path/to/skills
	```
- Windows (PowerShell)：
	```powershell
	./scripts/install-skills.ps1
	# 自定义目标目录
	./scripts/install-skills.ps1 -Target "C:/path/to/skills"
	# 使用环境变量指定目标目录
	$env:SKILL_TARGET_DIR = "C:/path/to/skills"
	./scripts/install-skills.ps1
	```

脚本会将仓库内 `skills/` 下的技能逐个同步到目标目录，如已有同名技能会先删除后再复制，确保版本一致。