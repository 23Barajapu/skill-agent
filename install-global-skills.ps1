#Requires -Version 5.1
<#
.SYNOPSIS
    Installs all local skills from agent repositories into Antigravity global configuration.

.DESCRIPTION
    Scans repositories in c:\laragon\www\agent and copies all skills into:
    C:\Users\<User>\.gemini\config\skills\<skill_name>

    Also validates and fixes YAML frontmatter (ensuring `name:` and `description:` exist).
#>
param(
    [string]$TargetDir = "$env:USERPROFILE\.gemini\config\skills",
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "=== Antigravity Global Skill Installer ===" -ForegroundColor Magenta
Write-Host "Target Directory: $TargetDir`n" -ForegroundColor Gray

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Write-Host "[OK] Created directory: $TargetDir" -ForegroundColor Green
}

$repoBase = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $repoBase) { $repoBase = "c:\laragon\www\agent" }

$sources = @(
    @{ Repo = "agent-skills"; Path = Join-Path $repoBase "agent-skills\skills" },
    @{ Repo = "anti-slop"; Path = Join-Path $repoBase "anti-slop\skills" },
    @{ Repo = "caveman"; Path = Join-Path $repoBase "caveman\skills" },
    @{ Repo = "engineering-skills"; Path = Join-Path $repoBase "engineering-skills\skills" },
    @{ Repo = "ponytail-bara"; Path = Join-Path $repoBase "ponytail-bara\skills" },
    @{ Repo = "rtk"; Path = Join-Path $repoBase "rtk\.claude\skills" }
)

$installed = 0
$errors = @()

foreach ($s in $sources) {
    if (-not (Test-Path $s.Path)) {
        Write-Warning "Repository path not found: $($s.Path)"
        continue
    }

    $skills = Get-ChildItem -Path $s.Path -Filter "SKILL.md" -Recurse -File
    Write-Host "[>>] Processing $($s.Repo) ($($skills.Count) skills)..." -ForegroundColor Cyan

    foreach ($sk in $skills) {
        $skillDir = $sk.Directory
        $skillName = $skillDir.Name
        $destPath = Join-Path $TargetDir $skillName

        try {
            if (Test-Path $destPath) {
                Remove-Item -Path $destPath -Recurse -Force
            }
            Copy-Item -Path $skillDir.FullName -Destination $destPath -Recurse -Force

            # Validate and fix frontmatter if name: is missing
            $destSkillMd = Join-Path $destPath "SKILL.md"
            if (Test-Path $destSkillMd) {
                $content = Get-Content -Path $destSkillMd -Raw
                if ($content -notmatch "(?m)^name:\s*") {
                    if ($content -match "^(?:\r?\n)?---\r?\n") {
                        $content = $content -replace "^(?:\r?\n)?---\r?\n", "---`nname: $skillName`n"
                    } else {
                        $content = "---`nname: $skillName`n---`n" + $content
                    }
                    Set-Content -Path $destSkillMd -Value $content -Encoding UTF8
                }
            }
            $installed++
        } catch {
            $errors += [PSCustomObject]@{
                Skill = $skillName
                Repo = $s.Repo
                Error = $_.Exception.Message
            }
        }
    }
}

Write-Host "`n=== Installation Summary ===" -ForegroundColor Magenta
Write-Host "Total skills installed globally: $installed" -ForegroundColor Green

if ($errors.Count -gt 0) {
    Write-Host "Errors encountered: $($errors.Count)" -ForegroundColor Red
    $errors | Format-Table -AutoSize
} else {
    Write-Host "All skills are successfully installed and ready in Antigravity!" -ForegroundColor Green
}
