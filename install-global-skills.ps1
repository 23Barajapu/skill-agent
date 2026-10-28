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

# Auto-detect seluruh repository lokal yang memiliki folder skill
$sources = @()
Get-ChildItem -Path $repoBase -Directory | Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'mcp-bahasa-indonesia' -and $_.Name -ne 'skills' } | ForEach-Object {
    $dir = $_
    $candidates = @(
        (Join-Path $dir.FullName "skills"),
        (Join-Path $dir.FullName ".agents\skills"),
        (Join-Path $dir.FullName ".claude\skills")
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) {
            $sources += @{ Repo = $dir.Name; Path = $c }
            break
        }
    }
}

$installed = 0
$skipped = 0
$errors = @()

foreach ($s in $sources) {
    if (-not (Test-Path $s.Path)) {
        Write-Warning "Repository path not found: $($s.Path)"
        continue
    }

    $skills = @(Get-ChildItem -Path $s.Path -Filter "SKILL.md" -Recurse -File)
    Write-Host "[>>] Processing $($s.Repo) ($($skills.Count) skills)..." -ForegroundColor Cyan

    foreach ($sk in $skills) {
        $skillDir = $sk.Directory
        $skillName = $skillDir.Name
        $destPath = Join-Path $TargetDir $skillName

        # Jika sudah terpasang dan tidak menggunakan -Force, lewati
        if ((Test-Path $destPath) -and -not $Force) {
            $destSkillMd = Join-Path $destPath "SKILL.md"
            if (Test-Path $destSkillMd) {
                $skipped++
                continue
            }
        }

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
Write-Host "New skills installed    : $installed" -ForegroundColor Green
Write-Host "Skipped (already exists): $skipped" -ForegroundColor Gray

if ($errors.Count -gt 0) {
    Write-Host "Errors encountered: $($errors.Count)" -ForegroundColor Red
    $errors | Format-Table -AutoSize
} elseif ($installed -gt 0) {
    Write-Host "Skill baru berhasil dipasang dan siap digunakan di Antigravity!" -ForegroundColor Green
} else {
    Write-Host "Semua skill sudah terpasang. Gunakan -Force jika ingin memasang ulang." -ForegroundColor Cyan
}
