#Requires -Version 5.1
<#
.SYNOPSIS
    Installs all local skills from agent repositories into Antigravity global configuration.

.DESCRIPTION
    Scans repositories in workspace and copies all skills into:
    C:\Users\<User>\.gemini\config\skills\<skill_name>

    If no local repositories exist in the workspace, it automatically downloads and installs
    all skills directly from remote GitHub repositories (Auto-Download).

.PARAMETER TargetDir
    The global Antigravity skills directory (default: %USERPROFILE%\.gemini\config\skills).

.PARAMETER Force
    Overwrites existing skills even if already installed.

.PARAMETER CloneLocal
    Clones the remote repositories directly into the workspace folder so they are permanently available locally.
#>
param(
    [string]$TargetDir = "$env:USERPROFILE\.gemini\config\skills",
    [switch]$Force,
    [switch]$CloneLocal
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

# Daftar repositori remote untuk auto-download & clone fallback (Dual-Source Fallback)
$REMOTE_REPOS = @(
    @{ Name = "agent-skills";         Url = "https://github.com/agent-bara/agent-skill-bara.git";        UpstreamUrl = "https://github.com/addyosmani/agent-skills.git";        SkillPath = "skills" },
    @{ Name = "anti-slop";            Url = "https://github.com/agent-bara/antislop-bara.git";           UpstreamUrl = "https://github.com/miqdadbadjuber/anti-slop.git";       SkillPath = "skills" },
    @{ Name = "apple-design";         Url = "https://github.com/agent-bara/apple-design.git";            UpstreamUrl = "https://github.com/emilkowalski/skills.git";             SkillPath = "skills" },
    @{ Name = "caveman";              Url = "https://github.com/agent-bara/caveman-bara.git";             UpstreamUrl = "https://github.com/JuliusBrussee/caveman.git";          SkillPath = "skills" },
    @{ Name = "chrome-devtools-mcp";   Url = "https://github.com/ChromeDevTools/chrome-devtools-mcp.git"; UpstreamUrl = "https://github.com/ChromeDevTools/chrome-devtools-mcp.git"; SkillPath = "skills" },
    @{ Name = "engineering-skills";   Url = "https://github.com/agent-bara/engineering-skills-bara.git"; UpstreamUrl = "https://github.com/mattpocock/skills.git";            SkillPath = "skills" },
    @{ Name = "ponytail-bara";        Url = "https://github.com/agent-bara/ponytail-bara.git";           UpstreamUrl = "https://github.com/DietrichGebert/ponytail.git";        SkillPath = "skills" },
    @{ Name = "rea";                  Url = "https://github.com/agent-bara/rea-bara.git";                 UpstreamUrl = "https://github.com/morluto/rea.git";                     SkillPath = ".agents/skills" },
    @{ Name = "rtk";                  Url = "https://github.com/agent-bara/rtk-bara.git";                 UpstreamUrl = "https://github.com/rtk-ai/rtk.git";                     SkillPath = "skills" },
    @{ Name = "security-audit-skill"; Url = "https://github.com/agent-bara/security-audit-skill.git";    UpstreamUrl = "https://github.com/cloudflare/security-audit-skill.git";SkillPath = "skills" },
    @{ Name = "superpowers";          Url = "https://github.com/agent-bara/superpowers-bara.git";         UpstreamUrl = "https://github.com/obra/superpowers.git";               SkillPath = "skills" }
)

# Helper function: Clone repositori dengan mekanisme Dual-Source Fallback
function Invoke-GitCloneWithFallback {
    param(
        [string]$Name,
        [string]$PrimaryUrl,
        [string]$FallbackUrl,
        [string]$Destination
    )

    $env:GIT_TERMINAL_PROMPT = "0"
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        # 1. Coba clone dari repositori Primary (agent-bara)
        Write-Host "     [Primary] Mencoba clone $Name dari $PrimaryUrl..." -ForegroundColor Gray
        & git -c credential.helper= clone --depth 1 --quiet $PrimaryUrl $Destination 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0 -and (Test-Path $Destination)) {
            Write-Host "     [OK] Berhasil mengunduh $Name dari repositori utama." -ForegroundColor Green
            return $true
        }

        # 2. Jika Primary gagal dan ada FallbackUrl (upstream publik), coba fallback
        if ($FallbackUrl -and ($FallbackUrl -ne $PrimaryUrl)) {
            Write-Host "     [Fallback] Primary repo privat/tidak dapat diakses. Beralih ke upstream publik: $FallbackUrl..." -ForegroundColor Yellow
            if (Test-Path $Destination) { Remove-Item -Path $Destination -Recurse -Force -ErrorAction SilentlyContinue }
            & git -c credential.helper= clone --depth 1 --quiet $FallbackUrl $Destination 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0 -and (Test-Path $Destination)) {
                Write-Host "     [OK] Berhasil mengunduh $Name dari upstream publik!" -ForegroundColor Green
                return $true
            }
        }

        Write-Warning "Gagal mengunduh $Name baik dari repositori utama maupun upstream publik."
        return $false
    } finally {
        $ErrorActionPreference = $prevEAP
    }
}

# Fungsi untuk mendeteksi folder skill lokal di workspace
function Get-LocalSources([string]$BaseDir) {
    if (-not (Test-Path $BaseDir)) { return @() }
    $dirs = @(Get-ChildItem -Path $BaseDir -Directory | Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'mcp-bahasa-indonesia' -and $_.Name -ne 'skills' })
    $res = foreach ($dir in $dirs) {
        $candidates = @(
            (Join-Path $dir.FullName "skills"),
            (Join-Path $dir.FullName ".agents\skills"),
            (Join-Path $dir.FullName ".claude\skills")
        )
        foreach ($c in $candidates) {
            if (Test-Path $c) {
                [PSCustomObject]@{ Repo = $dir.Name; Path = $c }
                break
            }
        }
    }
    if ($res) { return @($res) }
    return @()
}

# 1. Jika parameter -CloneLocal aktif, clone repositori yang belum ada ke workspace
if ($CloneLocal) {
    Write-Host "[>>] Opsi -CloneLocal aktif: Memeriksa dan mengkloning repositori ke workspace lokal ($repoBase)..." -ForegroundColor Cyan
    foreach ($repo in $REMOTE_REPOS) {
        $destRepo = Join-Path $repoBase $repo.Name
        if (-not (Test-Path $destRepo)) {
            $cloned = Invoke-GitCloneWithFallback -Name $repo.Name -PrimaryUrl $repo.Url -FallbackUrl $repo.UpstreamUrl -Destination $destRepo
            if ($cloned) {
                Write-Host "     [OK] $($repo.Name) berhasil di-clone ke workspace." -ForegroundColor Green
            }
        } else {
            Write-Host "     [--] $($repo.Name) sudah ada di workspace lokal." -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# 2. Pindai folder repositori lokal
$sources = @(Get-LocalSources -BaseDir $repoBase)

# 3. FITUR AUTO-DOWNLOAD: Jika tidak ada folder lokal yang terdeteksi
if ($sources.Count -eq 0) {
    Write-Host "[!!] Tidak ada folder repositori skill lokal yang ditemukan di: $repoBase" -ForegroundColor Yellow
    Write-Host "[>>] Mengaktifkan fitur Auto-Download skill dari GitHub ke Antigravity...`n" -ForegroundColor Cyan

    $syncScript = Join-Path $repoBase "sync-skills.ps1"
    if (Test-Path $syncScript) {
        Write-Host "Menjalankan instalasi dan sinkronisasi otomatis via sync-skills.ps1 (mode download-only, no push)...`n" -ForegroundColor Gray
        $syncArgs = @("-File", $syncScript, "-SkillFilter", "all", "-SkipPush", "-SkipOrgCheck")
        if ($Force) { $syncArgs += "-Force" }

        & powershell -NoProfile -ExecutionPolicy Bypass @syncArgs
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Host "`n=== Installation Summary ===" -ForegroundColor Magenta
            Write-Host "Seluruh skill berhasil diunduh dan dipasang secara otomatis ke Antigravity!" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "`n[XX] Gagal mengunduh skill otomatis via sync-skills.ps1 (Kode error: $exitCode)." -ForegroundColor Red
            exit $exitCode
        }
    } else {
        # Fallback mandiri jika sync-skills.ps1 tidak ada
        Write-Host "Mengunduh langsung dari repositori GitHub ke direktori sementara..." -ForegroundColor Gray
        $tempDir = Join-Path $env:TEMP "skills-auto-dl-$(Get-Date -Format 'yyyyMMddHHmmss')"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        $dlCount = 0

        try {
            foreach ($repo in $REMOTE_REPOS) {
                Write-Host "[>>] Mengunduh $($repo.Name)..." -ForegroundColor Cyan
                $cloneTarget = Join-Path $tempDir $repo.Name
                $cloned = Invoke-GitCloneWithFallback -Name $repo.Name -PrimaryUrl $repo.Url -FallbackUrl $repo.UpstreamUrl -Destination $cloneTarget

                if ($cloned) {
                    $skillBase = Join-Path $cloneTarget $repo.SkillPath
                    if (Test-Path $skillBase) {
                        $sList = @(Get-ChildItem -Path $skillBase -Filter "SKILL.md" -Recurse -File)
                        foreach ($sk in $sList) {
                            $skDir = $sk.Directory
                            $dPath = Join-Path $TargetDir $skDir.Name
                            if ((Test-Path $dPath) -and -not $Force) { continue }
                            if (Test-Path $dPath) { Remove-Item -Path $dPath -Recurse -Force }
                            Copy-Item -Path $skDir.FullName -Destination $dPath -Recurse -Force
                            $dlCount++
                        }
                    }
                }
            }
            Write-Host "`n=== Installation Summary ===" -ForegroundColor Magenta
            Write-Host "New skills installed : $dlCount" -ForegroundColor Green
            Write-Host "Seluruh skill berhasil diunduh dan dipasang ke Antigravity!" -ForegroundColor Green
            exit 0
        } finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# 4. Instalasi dari folder repositori lokal yang ada
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

# Salin folder plugin Antigravity jika ada
$pluginsTarget = if ($env:USERPROFILE) { Join-Path $env:USERPROFILE ".gemini\config\plugins" } else { "C:\Users\Administrator\.gemini\config\plugins" }
$rtkPlugin = Join-Path $repoBase "rtk\plugins\rtk"
if (-not (Test-Path $rtkPlugin)) { $rtkPlugin = Join-Path $repoBase "rtk" }
if (Test-Path (Join-Path $rtkPlugin "plugin.json")) {
    $rtkDest = Join-Path $pluginsTarget "rtk"
    if (-not (Test-Path $rtkDest) -or $Force) {
        if (-not (Test-Path $pluginsTarget)) { New-Item -ItemType Directory -Path $pluginsTarget -Force | Out-Null }
        Copy-Item -Path $rtkPlugin -Destination $rtkDest -Recurse -Force
    }
}
$spPlugin = Join-Path $repoBase "superpowers"
if (Test-Path (Join-Path $spPlugin "plugin.json")) {
    $spDest = Join-Path $pluginsTarget "superpowers"
    if (-not (Test-Path $spDest) -or $Force) {
        if (-not (Test-Path $pluginsTarget)) { New-Item -ItemType Directory -Path $pluginsTarget -Force | Out-Null }
        Copy-Item -Path $spPlugin -Destination $spDest -Recurse -Force
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
