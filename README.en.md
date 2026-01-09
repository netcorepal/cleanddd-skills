# CleanDDD Skills

中文版本: [README.md](README.md)

This skill collection provides expertise in Domain-Driven Design (DDD) modeling and CleanDDD-friendly .NET project scaffolding.

## Skills

| Skill | Description |
| --- | --- |
| [cleanddd-requirements-analysis](skills/cleanddd-requirements-analysis/SKILL.md) | Decompose business requirements into structured outputs for CleanDDD modeling |
| [cleanddd-dotnet-init](skills/cleanddd-dotnet-init/SKILL.md) | Quickly initialize CleanDDD projects with `dotnet new` using the `NetCorePal.Template` template (optional helper script) |
| [cleanddd-modeling](skills/cleanddd-modeling/SKILL.md) | CleanDDD-based software system analysis and domain modeling |
| [cleanddd-dotnet-coding](skills/cleanddd-dotnet-coding/SKILL.md) | Implement code following CleanDDD models and NetCorePal patterns (.NET / C#) |

## How to Use

1. Clone the repo

   ```bash
   git clone https://github.com/netcorepal/cleanddd-skills.git
   cd cleanddd-skills
   ```

2. Run the install script (sync skills to the current user's global directory)

   - Windows (PowerShell):

     ```powershell
     ./scripts/install-skills.ps1
     ```

   - macOS/Linux:

     ```bash
     chmod +x scripts/install-skills.sh
     ./scripts/install-skills.sh
     ```

3. Chat with your Agent (copy-pasteable prompts)

   - Create a CleanDDD project
   - Model a "Mall" domain with CleanDDD
   - Implement code skeletons based on the model

The install scripts copy each skill under `skills/` to the target directory. If a skill already exists, it is removed first to ensure versions stay consistent.
