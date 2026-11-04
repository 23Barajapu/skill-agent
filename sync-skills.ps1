#Requires -Version 5.1
<#
.SYNOPSIS
    Sync skill updates from upstream repos, merge with local customizations,
    push to agent-bara backup repos.

.DESCRIPTION
    Skill map:
      caveman  : JuliusBrussee/caveman      -> agent-bara/caveman-bara   (branch: main)
      ponytail : DietrichGebert/ponytail    -> agent-bara/ponytail-bara  (branch: main)
      antislop : miqdadbadjuber/anti-slop   -> agent-bara/agent-skill-bara (branch: main)
      rtk      : rtk-ai/rtk                 -> agent-bara/rtk-bara       (branch: backup-bara)

.PARAMETER SkillFilter
    Comma-separated list of skills to sync. Default: all.
    Values: caveman, ponytail, antislop, rtk

.PARAMETER DryRun
    Show what would happen without making changes.

.PARAMETER SkipPush
    Sync and merge locally but skip the push to backup repos.

.EXAMPLE
    # Set token first:
    $env:GITHUB_TOKEN = "ghp_xxxx"

    # Sync all skills:
    .\sync-skills.ps1

    # Dry run to see what would change:
    .\sync-skills.ps1 -DryRun

    # Only sync caveman and rtk:
    .\sync-skills.ps1 -SkillFilter "caveman,rtk"
#>
param(
    [string]$SkillFilter = "all",
    [switch]$DryRun,
    [switch]$SkipPush,
    [switch]$CheckOnly,
    [switch]$SkipOrgCheck,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$env:GIT_TERMINAL_PROMPT = "0"

$CURRENT_SCRIPT_PATH = if ($PSCommandPath) {
    $PSCommandPath
} elseif ($MyInvocation.MyCommand.Path) {
    $MyInvocation.MyCommand.Path
} else {
    "C:\laragon\www\agent\sync-skills.ps1"
}

$LOCAL_SKILLS_DIR = if ($env:USERPROFILE) { Join-Path $env:USERPROFILE ".gemini\config\skills" } else { "C:\Users\Administrator\.gemini\config\skills" }
$LOCAL_PLUGINS_DIR = if ($env:USERPROFILE) { Join-Path $env:USERPROFILE ".gemini\config\plugins" } else { "C:\Users\Administrator\.gemini\config\plugins" }
$WORKSPACE_DIR = if ($CURRENT_SCRIPT_PATH) { Split-Path -Parent $CURRENT_SCRIPT_PATH } else { "c:\laragon\www\agent" }
$SYNC_STATE_FILE = Join-Path $LOCAL_SKILLS_DIR ".sync-state.json"
$REAL_TEMP = (Get-Item $env:TEMP).FullName
$TEMP_DIR = Join-Path $REAL_TEMP "skill-sync-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

function Get-SyncState {
    if (Test-Path $SYNC_STATE_FILE) {
        try {
            $raw = Get-Content -Path $SYNC_STATE_FILE -Raw -Encoding UTF8
            if ($raw) {
                $obj = $raw | ConvertFrom-Json
                $hash = @{}
                foreach ($prop in $obj.PSObject.Properties) {
                    $hash[$prop.Name] = $prop.Value
                }
                return $hash
            }
        } catch {}
    }
    return @{}
}

function Save-SyncState([hashtable]$State) {
    try {
        $json = $State | ConvertTo-Json -Depth 5
        [System.IO.File]::WriteAllText($SYNC_STATE_FILE, $json, [System.Text.UTF8Encoding]::new($false))
    } catch {}
}

# Skill definitions
$SKILL_MAP = @{
    caveman = @{
        upstream_repo        = "https://github.com/JuliusBrussee/caveman.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("caveman", "caveman-commit", "caveman-compress",
                                  "caveman-discover", "caveman-evidence-review",
                                  "caveman-explore", "caveman-help", "caveman-learn",
                                  "caveman-manage", "caveman-optimize", "caveman-review",
                                  "caveman-setup", "caveman-stats", "cavecrew",
                                  "investigate-first", "lean-build", "migration",
                                  "safe-refactor", "surgical-patch", "verify-and-stop")
        backup_repo          = "https://github.com/agent-bara/caveman-bara.git"
        backup_branch        = "main"
    }
    ponytail = @{
        upstream_repo        = "https://github.com/DietrichGebert/ponytail.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("ponytail", "ponytail-audit", "ponytail-debt",
                                  "ponytail-gain", "ponytail-help", "ponytail-review")
        backup_repo          = "https://github.com/agent-bara/ponytail-bara.git"
        backup_branch        = "main"
    }
    antislop = @{
        upstream_repo        = "https://github.com/miqdadbadjuber/anti-slop.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("antislop", "antislop-code", "antislop-copywriting",
                                  "antislop-human", "antislop-layoutmobile", "antislop-ui")
        backup_repo          = "https://github.com/agent-bara/antislop-bara.git"
        backup_branch        = "main"
    }
    rtk = @{
        upstream_repo        = "https://github.com/rtk-ai/rtk.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("code-simplifier", "design-patterns", "issue-triage",
                                  "performance", "pr-review", "pr-triage", "repo-recap",
                                  "rtk-tdd", "rtk-triage", "security-guardian", "ship", "tdd-rust")
        local_plugin_path    = "rtk"
        backup_repo          = "https://github.com/agent-bara/rtk-bara.git"
        backup_branch        = "backup-bara"
    }

    'engineering-skills' = @{
        upstream_repo        = "https://github.com/mattpocock/skills.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("ask-matt", "code-review", "codebase-design", "diagnosing-bugs",
                                  "domain-modeling", "grill-with-docs", "implement", "implement-spec",
                                  "improve-codebase-architecture", "pr", "prototype", "research",
                                  "retro", "setup-matt-pocock-skills", "tdd", "to-spec", "to-tickets",
                                  "triage", "wayfinder", "wizard", "claude-handoff", "loop-me",
                                  "setup-ts-deep-modules", "writing-beats", "writing-fragments",
                                  "writing-shape", "git-guardrails-claude-code", "migrate-to-shoehorn",
                                  "scaffold-exercises", "setup-pre-commit", "grill-me", "grilling",
                                  "handoff", "teach", "to-questionnaire", "wait-what", "writing-for-agents")
        backup_repo          = "https://github.com/agent-bara/engineering-skills-bara.git"
        backup_branch        = "backup"
    }

    'agent-skills' = @{
        upstream_repo        = "https://github.com/addyosmani/agent-skills.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("api-and-interface-design", "browser-testing-with-devtools",
                                  "ci-cd-and-automation", "code-review-and-quality", "code-simplification",
                                  "constraint-driven-development", "context-engineering",
                                  "debugging-and-error-recovery", "deprecation-and-migration",
                                  "documentation-and-adrs", "doubt-driven-development",
                                  "frontend-ui-engineering", "git-workflow-and-versioning",
                                  "idea-refine", "incremental-implementation", "interview-me",
                                  "observability-and-instrumentation", "performance-optimization",
                                  "planning-and-task-breakdown", "security-and-hardening",
                                  "shipping-and-launch", "source-driven-development",
                                  "spec-driven-development", "test-driven-development", "using-agent-skills")
        backup_repo          = "https://github.com/agent-bara/agent-skill-bara.git"
        backup_branch        = "main"
    }

    'hermes' = @{
        upstream_repo        = "https://github.com/agent-bara/hermes-bara.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("hermes")
        backup_repo          = "https://github.com/agent-bara/hermes-bara.git"
        backup_branch        = "main"
    }

    'rea' = @{
        upstream_repo        = "https://github.com/morluto/rea.git"
        upstream_skill_path  = ".agents/skills"
        local_skill_prefixes = @("rea-analysis-optimization", "rea-changelog-update",
                                  "rea-ci-tests-audit", "rea-tool-design", "reverse-engineer-anything")
        backup_repo          = "https://github.com/agent-bara/rea-bara.git"
        backup_branch        = "personal-skills"
    }

    'apple-design' = @{
        upstream_repo        = "https://github.com/emilkowalski/skills.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("animate", "animate-expo", "animation-performance", "animation-vocabulary",
                                  "apple-design", "ask-sonner", "break-ui", "emil-design-eng",
                                  "find-animation-opportunities", "improve-animations", "mobile-native",
                                  "pick-ui-library", "review-animations", "write-swift")
        backup_repo          = "https://github.com/agent-bara/apple-design.git"
        backup_branch        = "main"
    }

    'security-audit-skill' = @{
        upstream_repo        = "https://github.com/cloudflare/security-audit-skill.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("security-audit")
        backup_repo          = "https://github.com/agent-bara/security-audit-skill.git"
        backup_branch        = "main"
    }

    'superpowers' = @{
        upstream_repo        = "https://github.com/obra/superpowers.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("brainstorming", "diagnosing-superpowers", "dispatching-parallel-agents",
                                  "executing-plans", "finishing-a-development-branch", "receiving-code-review",
                                  "requesting-code-review", "subagent-driven-development", "systematic-debugging",
                                  "using-git-worktrees", "using-superpowers",
                                  "verification-before-completion", "writing-plans", "writing-skills")
        local_plugin_path    = "superpowers"
        backup_repo          = "https://github.com/agent-bara/superpowers-bara.git"
        backup_branch        = "main"
    }

    'chrome-devtools-mcp' = @{
        upstream_repo        = "https://github.com/ChromeDevTools/chrome-devtools-mcp.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("a11y-debugging", "chrome-devtools", "chrome-devtools-cli",
                                  "cookie-debugging", "debug-optimize-lcp", "memory-leak-debugging",
                                  "troubleshooting")
        backup_repo          = "https://github.com/agent-bara/chrome-devtools-mcp-bara.git"
        backup_branch        = "main"
    }
}

function Write-Step([string]$msg) { Write-Host "`n[>>] $msg" -ForegroundColor Cyan }
function Write-Ok([string]$msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn([string]$msg) { Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function Write-Fail([string]$msg) { Write-Host "  [XX] $msg" -ForegroundColor Red }
function Write-Info([string]$msg) { Write-Host "       $msg" -ForegroundColor Gray }

function Invoke-Git {
    param([string]$WorkDir, [string[]]$GitArgs)
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $out = & git -C $WorkDir @GitArgs 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prevEAP
    }
    if ($exitCode -ne 0) {
        $errMsg = ($out | Out-String).Trim()
        throw "git $($GitArgs -join ' ') failed (code $exitCode): $errMsg"
    }
    return $out
}

function Get-AuthenticatedUrl([string]$url) {
    $token = $env:GITHUB_TOKEN
    if (-not $token) { return $url }
    return $url -replace "https://", "https://$token@"
}

function Get-OrgRepositories {
    param([string]$Org = "agent-bara")
    $headers = @{
        "Accept"     = "application/vnd.github.v3+json"
        "User-Agent" = "PowerShell-SkillSync"
    }
    if ($env:GITHUB_TOKEN) {
        $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
    }
    $url = "https://api.github.com/orgs/$Org/repos?per_page=100&type=all"
    try {
        $res = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 15
        return $res
    } catch {
        Write-Warn "Gagal mengambil daftar repo dari org $Org : $_"
        return @()
    }
}

function Get-RepoDetail {
    param([string]$FullName)
    $headers = @{
        "Accept"     = "application/vnd.github.v3+json"
        "User-Agent" = "PowerShell-SkillSync"
    }
    if ($env:GITHUB_TOKEN) {
        $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
    }
    $url = "https://api.github.com/repos/$FullName"
    try {
        return Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 15
    } catch {
        return $null
    }
}

function Update-ScriptWithNewRepo {
    param(
        [string]$SkillKey,
        [hashtable]$NewConfig,
        [string]$ScriptPath
    )

    if (-not (Test-Path $ScriptPath)) {
        Write-Warn "File script tidak ditemukan: $ScriptPath"
        return
    }

    $content = Get-Content $ScriptPath -Raw
    $prefixesJoined = ($NewConfig.local_skill_prefixes | ForEach-Object { "`"$_`"" }) -join ", "
    
    $entryText = @"

    '$SkillKey' = @{
        upstream_repo        = "$($NewConfig.upstream_repo)"
        upstream_skill_path  = "$($NewConfig.upstream_skill_path)"
        local_skill_prefixes = @($prefixesJoined)
        backup_repo          = "$($NewConfig.backup_repo)"
        backup_branch        = "$($NewConfig.backup_branch)"
    }
"@

    # Pattern: cari penutup kurung kurawal sebelum blok Helpers / Write-Step
    $pattern = '(?ms)(\$SKILL_MAP\s*=\s*@\{.*?\r?\n)(\}\r?\n\r?\n.*?function Write-Step)'
    $match = [regex]::Match($content, $pattern)
    if ($match.Success) {
        $replacement = "$($match.Groups[1].Value)$entryText`r`n$($match.Groups[2].Value)"
        $newContent = $content.Substring(0, $match.Index) + $replacement + $content.Substring($match.Index + $match.Length)
        Set-Content -Path $ScriptPath -Value $newContent -Encoding UTF8
        Write-Ok "Script '$ScriptPath' berhasil diperbarui dengan entri repo baru: $SkillKey"
    } else {
        Write-Warn "Tidak dapat menemukan blok `$SKILL_MAP untuk update script di $ScriptPath"
    }
}

function Check-And-Update-OrgRepos {
    param(
        [string]$Org = "agent-bara",
        [string]$ScriptPath,
        [switch]$DryRun
    )

    Write-Step "Mengecek apakah ada repo baru di organisasi GitHub: $Org"
    $orgRepos = Get-OrgRepositories -Org $Org
    if (-not $orgRepos -or $orgRepos.Count -eq 0) {
        Write-Info "Tidak ada respon repo dari org $Org (cek koneksi atau token)."
        return
    }

    # Kumpulkan nama repo yang sudah ada di $SKILL_MAP
    $knownRepos = @{}
    foreach ($k in $SKILL_MAP.Keys) {
        $bRepo = $SKILL_MAP[$k].backup_repo
        if ($bRepo -match "github\.com[/:]([^/]+)/([^/\.]+)") {
            $knownRepos["$($Matches[2])".ToLower()] = $k
        }
    }

    $newCount = 0
    foreach ($repo in $orgRepos) {
        $rName = $repo.name.ToLower()
        $cleanName = ($repo.name -replace '-bara$', '').ToLower()
        if ($knownRepos.ContainsKey($rName) -or $SKILL_MAP.ContainsKey($cleanName) -or $SKILL_MAP.ContainsKey($repo.name.ToLower())) {
            continue
        }
        $newCount++
        Write-Warn "Repo baru terdeteksi di ${Org}: $($repo.name)"

            $detail = Get-RepoDetail -FullName $repo.full_name
            $upstream = ""
            if ($detail -and $detail.fork -and $detail.parent) {
                $upstream = $detail.parent.clone_url
                Write-Info "  Terdeteksi sebagai fork dari: $upstream"
            } else {
                $upstream = $repo.clone_url
                Write-Info "  Bukan fork atau parent tidak terdeteksi. Upstream diset ke: $upstream"
            }

            $branch = if ($repo.default_branch) { $repo.default_branch } else { "main" }
            $cleanName = ($repo.name -replace '-bara$', '').ToLower()
            $skillKey = $cleanName

            # Cari folder skill lokal yang cocok
            $localPrefixes = @()
            if (Test-Path $LOCAL_SKILLS_DIR) {
                $allLocalDirs = Get-ChildItem -Path $LOCAL_SKILLS_DIR -Directory | Select-Object -ExpandProperty Name
                $matched = $allLocalDirs | Where-Object { $_ -eq $cleanName -or $_ -like "$cleanName-*" }
                if ($matched) {
                    $localPrefixes = @($matched)
                }
            }
            if ($localPrefixes.Count -eq 0) {
                $localPrefixes = @($cleanName)
            }

            $newConfig = @{
                upstream_repo        = $upstream
                upstream_skill_path  = "skills"
                local_skill_prefixes = $localPrefixes
                backup_repo          = $repo.clone_url
                backup_branch        = $branch
            }

            # Daftarkan ke in-memory map
            $SKILL_MAP[$skillKey] = $newConfig
            $knownRepos[$rName] = $skillKey

            if (-not $DryRun -and $ScriptPath) {
                Update-ScriptWithNewRepo -SkillKey $skillKey -NewConfig $newConfig -ScriptPath $ScriptPath
            } else {
                Write-Info "[DryRun] Deteksi repo baru '$($repo.name)', script tidak ditulis."
            }
        }
    if ($newCount -eq 0) {
        Write-Ok "Semua repo di $Org ($($orgRepos.Count) repo) sudah terdaftar di `$SKILL_MAP."
    }
}

function Check-And-Update-LocalRepos {
    param(
        [string]$WorkspaceDir,
        [string]$ScriptPath,
        [switch]$DryRun
    )

    if (-not $WorkspaceDir -or -not (Test-Path $WorkspaceDir)) { return }

    Write-Step "Mengecek apakah ada folder repository skill baru di direktori lokal..."
    
    # Kumpulkan seluruh nama skill dan key yang sudah terdaftar di $SKILL_MAP
    $knownSkills = @{}
    $knownKeys = @{}
    foreach ($k in $SKILL_MAP.Keys) {
        $knownKeys[$k.ToLower()] = $true
        $knownKeys[($k -replace '-bara$', '' -replace '-', '').ToLower()] = $true
        if ($SKILL_MAP[$k].local_skill_prefixes) {
            foreach ($p in $SKILL_MAP[$k].local_skill_prefixes) {
                $knownSkills[$p.ToLower()] = $true
            }
        }
    }

    $newCount = 0
    Get-ChildItem -Path $WorkspaceDir -Directory | Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'mcp-bahasa-indonesia' } | ForEach-Object {
        $dir = $_
        $folderName = $dir.Name.ToLower()
        $normName = ($folderName -replace '-bara$', '' -replace '-', '')

        if ($knownKeys.ContainsKey($folderName) -or $knownKeys.ContainsKey($normName)) {
            return
        }

        # Deteksi letak folder skill
        $skillRelPath = $null
        $candidates = @("skills", ".agents\skills", ".claude\skills")
        foreach ($c in $candidates) {
            $testPath = Join-Path $dir.FullName $c
            if (Test-Path $testPath) {
                $skillRelPath = $c.Replace('\', '/')
                break
            }
        }

        if (-not $skillRelPath) { return }

        # Cari prefix / nama skill di dalamnya
        $fullSkillPath = Join-Path $dir.FullName $skillRelPath
        $skillDirs = @(Get-ChildItem -Path $fullSkillPath -Directory | Select-Object -ExpandProperty Name)
        if (-not $skillDirs -or $skillDirs.Count -eq 0) { return }

        # Cek apakah skill-skill di dalamnya sudah pernah terdaftar di repo lain
        $unregistered = @()
        foreach ($sd in $skillDirs) {
            if (-not $knownSkills.ContainsKey($sd.ToLower())) {
                $unregistered += $sd
            }
        }
        if ($unregistered.Count -eq 0) {
            return
        }

        $newCount++
        Write-Warn "Folder repo baru terdeteksi di lokal: $($dir.Name)"

        # Baca git remote jika ada
        $remotes = & git -C $dir.FullName remote -v 2>$null
        $upstreamUrl = ""
        $backupUrl = ""

        if ($remotes) {
            foreach ($line in ($remotes -split "`r?`n")) {
                if ($line -match '^upstream\s+(\S+)\s+\(fetch\)') {
                    $upstreamUrl = $Matches[1]
                } elseif ($line -match '^origin\s+(\S+)\s+\(fetch\)') {
                    $backupUrl = $Matches[1]
                }
            }
        }

        if (-not $upstreamUrl -and $backupUrl) { $upstreamUrl = $backupUrl }
        if (-not $backupUrl -and $upstreamUrl) { $backupUrl = $upstreamUrl }
        if (-not $backupUrl) {
            $backupUrl = "https://github.com/agent-bara/$($dir.Name)-bara.git"
            $upstreamUrl = $backupUrl
        }

        # Cek branch aktif
        $branch = (& git -C $dir.FullName rev-parse --abbrev-ref HEAD 2>$null)
        if (-not $branch -or $LASTEXITCODE -ne 0) { $branch = "main" }

        $cleanKey = ($folderName -replace '-bara$', '')
        $newConfig = @{
            upstream_repo        = $upstreamUrl
            upstream_skill_path  = $skillRelPath
            local_skill_prefixes = @($skillDirs)
            backup_repo          = $backupUrl
            backup_branch        = $branch.Trim()
        }

        $SKILL_MAP[$cleanKey] = $newConfig
        $knownKeys[$cleanKey] = $true
        foreach ($sd in $skillDirs) { $knownSkills[$sd.ToLower()] = $true }
        Write-Ok "Repo lokal '$cleanKey' ($($skillDirs.Count) skill) berhasil ditambahkan ke `$SKILL_MAP."

        if (-not $DryRun -and $ScriptPath) {
            Update-ScriptWithNewRepo -SkillKey $cleanKey -NewConfig $newConfig -ScriptPath $ScriptPath
        }
    }

    if ($newCount -eq 0) {
        Write-Ok "Semua folder skill di direktori lokal sudah terdaftar di `$SKILL_MAP."
    }
}

function Merge-SkillFolder {
    <#
    Merge strategy:
      - File only in upstream : copy to local (new content from upstream)
      - File only in local    : keep (local custom file)
      - File in both          : take upstream UNLESS local has # custom: / # bara: marker
    #>
    param(
        [string]$UpstreamDir,
        [string]$LocalDir,
        [switch]$DryRun
    )

    $stats = @{ new = 0; updated = 0; kept = 0; conflicts = 0 }
    if (-not (Test-Path $UpstreamDir)) { return $stats }

    if (-not (Test-Path $LocalDir)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null }
        Write-Info "New skill dir: $(Split-Path $LocalDir -Leaf)"
    }

    # Normalize paths: resolve symlinks/8.3 short paths to full long paths
    $resolvedUpstreamDir = (Resolve-Path $UpstreamDir).Path.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $resolvedLocalDir    = (Resolve-Path $LocalDir).Path.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar

    $processedUpstream = @{}

    Get-ChildItem -Path $UpstreamDir -Recurse -File | ForEach-Object {
        $file     = $_
        $filePath = (Resolve-Path $file.FullName).Path
        $relPath  = $filePath.Substring($resolvedUpstreamDir.Length)
        $localFile = Join-Path $LocalDir $relPath
        $processedUpstream[$relPath] = $true

        $localParent = Split-Path $localFile -Parent
        if (-not (Test-Path $localParent) -and -not $DryRun) {
            New-Item -ItemType Directory -Path $localParent -Force | Out-Null
        }

        if (-not (Test-Path $localFile)) {
            if (-not $DryRun) { Copy-Item $file.FullName $localFile -Force }
            Write-Info "  + $relPath"
            $stats.new++
        } else {
            $localContent    = Get-Content $localFile -Raw -ErrorAction SilentlyContinue
            $upstreamContent = Get-Content $file.FullName -Raw

            if ($localContent -match "(?m)^#\s*(custom|bara|local-only):") {
                Write-Warn "  ~ $relPath has custom marker - kept (review manually)"
                $stats.conflicts++
            } elseif ($localContent -ne $upstreamContent) {
                if (-not $DryRun) { Copy-Item $file.FullName $localFile -Force }
                Write-Info "  u $relPath"
                $stats.updated++
            } else {
                $stats.kept++
            }
        }
    }

    # Local-only files: count them
    if (Test-Path $LocalDir) {
        Get-ChildItem -Path $LocalDir -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $filePath = (Resolve-Path $_.FullName).Path
            $relPath  = $filePath.Substring($resolvedLocalDir.Length)
            if (-not $processedUpstream.ContainsKey($relPath)) {
                Write-Info "  = $relPath (local-only)"
                $stats.kept++
            }
        }
    }

    return $stats
}

function Clone-SkillToLocal {
    param(
        [string]$Name,
        [hashtable]$Config,
        [switch]$DryRun
    )

    $missingPrefixes = @()
    foreach ($prefix in $Config.local_skill_prefixes) {
        $localDir = Join-Path $LOCAL_SKILLS_DIR $prefix
        if (-not (Test-Path $localDir)) {
            $missingPrefixes += $prefix
        }
    }

    $missingPlugin = $false
    if ($Config.ContainsKey('local_plugin_path')) {
        $localPlugin = Join-Path $LOCAL_PLUGINS_DIR $Config.local_plugin_path
        if (-not (Test-Path $localPlugin)) {
            $missingPlugin = $true
        }
    }

    if ($missingPrefixes.Count -eq 0 -and -not $missingPlugin) {
        return # Semua folder lokal sudah ada
    }

    Write-Info "Folder lokal untuk '$Name' belum ada ($($missingPrefixes -join ', ')). Mencoba git clone ke lokal..."

    $tempCloneTarget = Join-Path $TEMP_DIR "${Name}-clone-init"
    New-Item -ItemType Directory -Path $tempCloneTarget -Force | Out-Null

    # Prioritas sumber clone: 1. backup_repo (agent-bara), 2. upstream_repo
    $cloned = $false
    $sources = @($Config.backup_repo)
    if ($Config.upstream_repo -and ($Config.upstream_repo -ne $Config.backup_repo)) {
        $sources += $Config.upstream_repo
    }

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        foreach ($srcUrl in $sources) {
            $authUrl = Get-AuthenticatedUrl $srcUrl
            Write-Info "  Mencoba clone dari: $srcUrl"
            $branchArg = if ($srcUrl -eq $Config.backup_repo -and $Config.backup_branch) { @("--branch", $Config.backup_branch) } else { @() }
            $out = & git -c credential.helper= clone --depth 1 --quiet @branchArg $authUrl $tempCloneTarget 2>&1
            if ($LASTEXITCODE -eq 0) {
                $cloned = $true
                Write-Ok "Berhasil clone dari $srcUrl"
                break
            } else {
                if ($branchArg.Count -gt 0) {
                    $out = & git -c credential.helper= clone --depth 1 --quiet $authUrl $tempCloneTarget 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $cloned = $true
                        Write-Ok "Berhasil clone default branch dari $srcUrl"
                        break
                    }
                }
                Write-Info "  Tidak dapat clone dari $srcUrl"
            }
        }
    } finally {
        $ErrorActionPreference = $prevEAP
    }

    if (-not $cloned) {
        Write-Warn "  Gagal clone dari semua sumber. Folder lokal belum dapat dibuat."
        return
    }

    # Pasang skill folders yang belum ada ke lokal
    foreach ($prefix in $missingPrefixes) {
        $localDir = Join-Path $LOCAL_SKILLS_DIR $prefix
        if (Test-Path $localDir) { continue }

        $candidates = @(
            (Join-Path $tempCloneTarget "skills\$prefix"),
            (Join-Path $tempCloneTarget $prefix),
            $tempCloneTarget
        )

        $srcFolder = $null
        foreach ($c in $candidates) {
            if (Test-Path $c) {
                if ($c -eq $tempCloneTarget) {
                    if (Test-Path (Join-Path $c "SKILL.md")) {
                        $srcFolder = $c
                        break
                    }
                } else {
                    $srcFolder = $c
                    break
                }
            }
        }

        if ($srcFolder) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $localDir -Force | Out-Null
                $resolvedSrc = (Resolve-Path $srcFolder).Path.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
                Get-ChildItem -Path $srcFolder -Recurse -File | ForEach-Object {
                    $fullPath = (Resolve-Path $_.FullName).Path
                    $rel = $fullPath.Substring($resolvedSrc.Length)
                    if ($rel -notmatch '^\.git[\\/]') {
                        $destFile = Join-Path $localDir $rel
                        $destParent = Split-Path $destFile -Parent
                        if (-not (Test-Path $destParent)) {
                            New-Item -ItemType Directory -Path $destParent -Force | Out-Null
                        }
                        Copy-Item $_.FullName $destFile -Force
                    }
                }
                Write-Ok "Skill '$prefix' berhasil di-clone ke lokal: $localDir"
            } else {
                Write-Info "[DryRun] Akan clone skill '$prefix' ke lokal: $localDir"
            }
        } else {
            Write-Warn "  Tidak menemukan konten skill untuk '$prefix' di repo yang diclone."
        }
    }

    # Pasang plugin folder jika belum ada
    if ($missingPlugin -and $Config.ContainsKey('local_plugin_path')) {
        $localPlugin = Join-Path $LOCAL_PLUGINS_DIR $Config.local_plugin_path
        $srcPlugin = Join-Path $tempCloneTarget "plugins\$($Config.local_plugin_path)"
        if (Test-Path $srcPlugin) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $localPlugin -Force | Out-Null
                $resolvedPluginSrc = (Resolve-Path $srcPlugin).Path.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
                Get-ChildItem -Path $srcPlugin -Recurse -File | ForEach-Object {
                    $fullPath = (Resolve-Path $_.FullName).Path
                    $rel = $fullPath.Substring($resolvedPluginSrc.Length)
                    if ($rel -notmatch '^\.git[\\/]') {
                        $destFile = Join-Path $localPlugin $rel
                        $destParent = Split-Path $destFile -Parent
                        if (-not (Test-Path $destParent)) {
                            New-Item -ItemType Directory -Path $destParent -Force | Out-Null
                        }
                        Copy-Item $_.FullName $destFile -Force
                    }
                }
                Write-Ok "Plugin '$($Config.local_plugin_path)' berhasil di-clone ke lokal: $localPlugin"
            } else {
                Write-Info "[DryRun] Akan clone plugin '$($Config.local_plugin_path)' ke lokal: $localPlugin"
            }
        }
    }
}

function Sync-Skill {
    param([string]$Name, [hashtable]$Config, [hashtable]$SyncState)

    Write-Step "Syncing: $Name"

    # Jika folder lokal belum ada, otomatis clone terlebih dahulu
    Clone-SkillToLocal -Name $Name -Config $Config -DryRun:$DryRun

    $hasUpstream = ($Config.upstream_repo -and ($Config.upstream_repo -ne $Config.backup_repo))
    $total = @{ new = 0; updated = 0; kept = 0; conflicts = 0 }
    $upstreamSha = $null

    if ($hasUpstream) {
        $upstreamAuth = Get-AuthenticatedUrl $Config.upstream_repo

        # Cek apakah upstream SHA sama dengan catatan sinkronisasi terakhir
        try {
            $lsOut = & git ls-remote $upstreamAuth HEAD 2>$null
            if ($LASTEXITCODE -eq 0 -and $lsOut -match '^([0-9a-fA-F]{40})\s+') {
                $upstreamSha = $Matches[1]
            }
        } catch {}

        # Jika SHA sama dengan state terakhir dan tidak menggunakan -Force, langsung lewati
        if ($upstreamSha -and -not $Force -and $SyncState.ContainsKey($Name)) {
            $lastSha = $SyncState[$Name].upstream_sha
            if ($lastSha -and $lastSha -eq $upstreamSha) {
                Write-Ok "Upstream sudah sinkron (Commit: $($upstreamSha.Substring(0,7))). Dilewati."
                return "skipped"
            }
        }

        $tempCloneDir = Join-Path $TEMP_DIR "${Name}-upstream"
        New-Item -ItemType Directory -Path $tempCloneDir -Force | Out-Null

        # 1. Clone upstream (shallow)
        Write-Info "Cloning upstream..."
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        $cloneOut = & git -c credential.helper= clone --depth 1 --quiet $upstreamAuth $tempCloneDir 2>&1
        $cloneExit = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP
        if ($cloneExit -ne 0) {
            Write-Fail "Clone failed: $cloneOut"
            return "failed"
        }

        # Dapatkan SHA dari clone jika ls-remote belum dapat
        if (-not $upstreamSha) {
            $headSha = (& git -C $tempCloneDir rev-parse HEAD 2>$null)
            if ($headSha -and $LASTEXITCODE -eq 0) { $upstreamSha = $headSha.Trim() }
        }

        $upstreamSkillBase = Join-Path $tempCloneDir $Config.upstream_skill_path

        # 2. Merge each skill folder locally
        foreach ($prefix in $Config.local_skill_prefixes) {
            $upDir    = Join-Path $upstreamSkillBase $prefix
            if (-not (Test-Path $upDir)) {
                $nested = Get-ChildItem -Path $upstreamSkillBase -Filter $prefix -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($nested) { $upDir = $nested.FullName }
            }
            $localDir = Join-Path $LOCAL_SKILLS_DIR $prefix
            if (-not (Test-Path $upDir)) {
                Write-Info "  '$prefix' not in upstream (local-only)"
                continue
            }
            $s = Merge-SkillFolder -UpstreamDir $upDir -LocalDir $localDir -DryRun:$DryRun
            $total.new       += $s.new
            $total.updated   += $s.updated
            $total.kept      += $s.kept
            $total.conflicts += $s.conflicts
        }

        # Plugin folder (rtk only)
        if ($Config.ContainsKey('local_plugin_path')) {
            $upPlugin    = Join-Path $tempCloneDir "plugins\$($Config.local_plugin_path)"
            $localPlugin = Join-Path $LOCAL_PLUGINS_DIR $Config.local_plugin_path
            if (Test-Path $upPlugin) {
                $s = Merge-SkillFolder -UpstreamDir $upPlugin -LocalDir $localPlugin -DryRun:$DryRun
                $total.new     += $s.new
                $total.updated += $s.updated
            }
        }

        Write-Ok "+$($total.new) new  ~$($total.updated) updated  =$($total.kept) kept  !$($total.conflicts) needs-review"

        if ($total.new -eq 0 -and $total.updated -eq 0) {
            Write-Info "Tidak ada perubahan dari upstream. Dilewati (skip push)."
            if ($upstreamSha -and -not $DryRun) {
                $SyncState[$Name] = @{
                    upstream_sha = $upstreamSha
                    last_sync    = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
                }
                Save-SyncState $SyncState
            }
            return "skipped"
        }
    } else {
        Write-Info "Skill tidak memiliki upstream eksternal (backup lokal)."
    }

    if ($DryRun -or $SkipPush) {
        if ($DryRun)   { Write-Info "[DryRun] Would push to $($Config.backup_repo) [$($Config.backup_branch)]" }
        if ($SkipPush) { Write-Info "SkipPush: local changes applied, no push." }
        if ($upstreamSha -and -not $DryRun) {
            $SyncState[$Name] = @{
                upstream_sha = $upstreamSha
                last_sync    = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
            }
            Save-SyncState $SyncState
        }
        return "ok"
    }

    # 3. Push to backup repo
    Write-Info "Pushing to backup repo..."
    $tempBackupDir = Join-Path $TEMP_DIR "${Name}-backup"
    if (Test-Path $tempBackupDir) { Remove-Item $tempBackupDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tempBackupDir -Force | Out-Null

    $backupAuth = Get-AuthenticatedUrl $Config.backup_repo
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $cloneBackup = & git -c credential.helper= clone --depth 1 --quiet --branch $Config.backup_branch $backupAuth $tempBackupDir 2>&1
    $cloneExit = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP

    if ($cloneExit -ne 0) {
        # Branch may not exist: clone default then create
        Write-Info "Branch '$($Config.backup_branch)' belum ada di backup repo. Mengkloning default branch..."
        if (Test-Path $tempBackupDir) { Remove-Item $tempBackupDir -Recurse -Force }
        New-Item -ItemType Directory -Path $tempBackupDir -Force | Out-Null

        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        $cloneBackup2 = & git -c credential.helper= clone --depth 1 --quiet $backupAuth $tempBackupDir 2>&1
        $cloneExit2 = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP

        if ($cloneExit2 -ne 0) {
            Write-Fail "Clone backup failed: $cloneBackup2"
            return "failed"
        }

        # Pastikan checkout ke branch yang diinginkan
        $currentBranch = (& git -C $tempBackupDir rev-parse --abbrev-ref HEAD 2>$null)
        if ($currentBranch -ne $Config.backup_branch) {
            $branchExists = (& git -C $tempBackupDir branch --list $Config.backup_branch 2>$null)
            if ($branchExists) {
                Invoke-Git $tempBackupDir @("checkout", $Config.backup_branch) | Out-Null
            } else {
                Invoke-Git $tempBackupDir @("checkout", "-b", $Config.backup_branch) | Out-Null
            }
        }
    }

    # Setup identity for commit
    & git -C $tempBackupDir config user.name "agent-bara"
    & git -C $tempBackupDir config user.email "agent-bara@users.noreply.github.com"

    # Copy skill folders into backup repo under skills/
    $backupSkillsDir = Join-Path $tempBackupDir "skills"
    if (-not (Test-Path $backupSkillsDir)) {
        New-Item -ItemType Directory -Path $backupSkillsDir -Force | Out-Null
    }

    foreach ($prefix in $Config.local_skill_prefixes) {
        $src  = Join-Path $LOCAL_SKILLS_DIR $prefix
        $dest = Join-Path $backupSkillsDir $prefix
        if (Test-Path $src) {
            if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
            Copy-Item $src $dest -Recurse -Force
        }
    }

    # Copy plugin folder if applicable
    if ($Config.ContainsKey('local_plugin_path')) {
        $src = Join-Path $LOCAL_PLUGINS_DIR $Config.local_plugin_path
        if (Test-Path $src) {
            $backupPluginsDir = Join-Path $tempBackupDir "plugins"
            if (-not (Test-Path $backupPluginsDir)) {
                New-Item -ItemType Directory -Path $backupPluginsDir -Force | Out-Null
            }
            $dest = Join-Path $backupPluginsDir $Config.local_plugin_path
            if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
            Copy-Item $src $dest -Recurse -Force
        }
    }

    # Commit and push
    Invoke-Git $tempBackupDir @("add", "-A") | Out-Null
    $status = Invoke-Git $tempBackupDir @("status", "--porcelain")
    if ($status) {
        $ts  = Get-Date -Format "yyyy-MM-dd HH:mm"
        $msg = "sync: update $Name from upstream ($ts)"
        Invoke-Git $tempBackupDir @("commit", "-m", $msg) | Out-Null
        Invoke-Git $tempBackupDir @("push", "-u", "origin", $Config.backup_branch) | Out-Null
        Write-Ok "Pushed -> $($Config.backup_repo) [$($Config.backup_branch)]"
    } else {
        Write-Info "Backup repo already up to date."
    }

    if ($upstreamSha) {
        $SyncState[$Name] = @{
            upstream_sha = $upstreamSha
            last_sync    = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        }
        Save-SyncState $SyncState
    }

    return "ok"
}

# ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ Main ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬

Write-Host "`n=== Skill Sync ===" -ForegroundColor Magenta
if ($DryRun)    { Write-Warn "DRY RUN: no files will be changed." }
if ($SkipPush)  { Write-Warn "SKIP PUSH: local merge only." }
if ($CheckOnly) { Write-Info "CHECK ONLY: cek repo baru di org agent-bara tanpa sync." }

if (-not $SkipPush -and -not $DryRun -and -not $CheckOnly) {
    if (-not $env:GITHUB_TOKEN) {
        Write-Warn "GITHUB_TOKEN belum di-set."
        Write-Host "`nLangkah membuat token di GitHub:" -ForegroundColor Yellow
        Write-Host "  1. Buka browser: https://github.com/settings/tokens/new" -ForegroundColor Gray
        Write-Host "  2. Isi Note (misal: agent-bara-sync)" -ForegroundColor Gray
        Write-Host "  3. Centang permission scope: [x] repo (Full control of private repositories)" -ForegroundColor Gray
        Write-Host "  4. Klik 'Generate token' di bagian bawah, lalu copy token (ghp_...)" -ForegroundColor Gray
        Write-Host "  (Tips permanen: setx GITHUB_TOKEN `"ghp_xxxxxxxxxxxx`")`n" -ForegroundColor DarkGray
        
        $inputToken = Read-Host "Masukkan GitHub Token Anda (atau tekan Enter untuk batal)"
        if ($inputToken -and $inputToken.Trim() -ne "") {
            $env:GITHUB_TOKEN = $inputToken.Trim()
            Write-Ok "GITHUB_TOKEN berhasil dipasang untuk sesi ini."
        } else {
            Write-Fail "GITHUB_TOKEN diperlukan untuk push. Eksekusi dibatalkan."
            exit 1
        }
    } else {
        Write-Ok "GITHUB_TOKEN found."
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Fail "git not found in PATH."
    exit 1
}

# 1. Cek apakah ada folder repo baru di direktori lokal workspace
Check-And-Update-LocalRepos -WorkspaceDir $WORKSPACE_DIR -ScriptPath $CURRENT_SCRIPT_PATH -DryRun:$DryRun

# 2. Cek apakah ada repo baru di agent-bara dan update script jika ada
if (-not $SkipOrgCheck) {
    Check-And-Update-OrgRepos -Org "agent-bara" -ScriptPath $CURRENT_SCRIPT_PATH -DryRun:$DryRun
}

# Jika hanya mode check, keluar di sini
if ($CheckOnly) {
    Write-Host "`nPengecekan selesai." -ForegroundColor Cyan
    exit 0
}

New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null

$selected = if ($SkillFilter -eq "all") {
    @($SKILL_MAP.Keys)
} else {
    $SkillFilter -split "," | ForEach-Object { $_.Trim().ToLower() }
}

$syncState = Get-SyncState
$results = @{}

foreach ($name in $selected) {
    if (-not $SKILL_MAP.ContainsKey($name)) {
        Write-Warn "Unknown skill '$name'. Valid: $(($SKILL_MAP.Keys) -join ', ')"
        continue
    }
    try {
        $res = Sync-Skill -Name $name -Config $SKILL_MAP[$name] -SyncState $syncState
        if (-not $res) { $res = "ok" }
        $results[$name] = $res
    } catch {
        Write-Fail "Error: $_"
        $results[$name] = "failed"
    }
}

Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n=== Summary ===" -ForegroundColor Magenta
foreach ($k in $results.Keys) {
    $res = $results[$k]
    if ($res -eq "ok") {
        Write-Host "  [OK] $k : BERHASIL DISINKRONISASI" -ForegroundColor Green
    } elseif ($res -eq "skipped") {
        Write-Host "  [--] $k : DILEWATI (SUDAH TERUPDATE)" -ForegroundColor Cyan
    } else {
        Write-Host "  [XX] $k : GAGAL" -ForegroundColor Red
    }
}
Write-Host "`nDone." -ForegroundColor Cyan



