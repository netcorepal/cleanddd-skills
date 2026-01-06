param(
    [string]$Target
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RepoRoot = Split-Path -Parent $ScriptDir
$SourceDir = Join-Path $RepoRoot ".claude/skills"
$TargetDir = if ([string]::IsNullOrWhiteSpace($Target)) {
    if ($env:SKILL_TARGET_DIR) { $env:SKILL_TARGET_DIR } else { Join-Path $HOME ".claude/skills" }
} else {
    $Target
}

if (-not (Test-Path -Path $SourceDir)) {
    throw "Source skills directory not found: $SourceDir"
}

if (-not (Test-Path -Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
    $dest = Join-Path $TargetDir $_.Name
    if (Test-Path -Path $dest) {
        Remove-Item -Path $dest -Recurse -Force
    }
    Copy-Item -Path $_.FullName -Destination $dest -Recurse
}

Write-Host "Installed skills to $TargetDir"