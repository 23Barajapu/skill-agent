# Antigravity All-in-One Skill Manager (Windows PowerShell)
# Repositori resmi: https://github.com/23Barajapu/skill-agent

function Invoke-AntigravitySkillManager {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Position = 0)]
        [ValidateSet("install", "sync", "check", "help", "")]
        [string]$Action = "install",

        [string]$SkillFilter = "all",
        [switch]$Install,
        [switch]$Sync,
        [switch]$Check,
        [switch]$CheckOnly,
        [switch]$Force,
        [switch]$CloneLocal,
        [switch]$DryRun,
        [switch]$SkipPush,
        [switch]$SkipOrgCheck,
        [string]$TargetDir = ""
    )

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$env:GIT_TERMINAL_PROMPT = "0"

# Normalisasi Action berdasarkan switch
if ($Sync)                  { $Action = "sync" }
elseif ($Check -or $CheckOnly) { $Action = "check" }
elseif ($Install)           { $Action = "install" }
elseif (-not $Action)       { $Action = "install" }

# Resolusi path direktori kerja & konfigurasi global Antigravity
$cmdPath = ""
if ($PSCommandPath) {
    $cmdPath = $PSCommandPath
} elseif ($MyInvocation -and $MyInvocation.MyCommand -and ($MyInvocation.MyCommand.PSObject.Properties['Path'])) {
    $cmdPath = $MyInvocation.MyCommand.Path
}

$CURRENT_SCRIPT_PATH = if ($cmdPath) { $cmdPath } else { Join-Path $env:TEMP "skill.ps1" }

$WORKSPACE_DIR = if ($cmdPath -and (Test-Path $cmdPath)) {
    Split-Path -Parent (Split-Path -Parent (Resolve-Path $cmdPath).Path)
} else {
    if (Test-Path "c:\laragon\www\agent") { "c:\laragon\www\agent" } else { (Get-Location).Path }
}

$LOCAL_SKILLS_DIR = if ($TargetDir) {
    $TargetDir
} elseif ($env:USERPROFILE) {
    Join-Path $env:USERPROFILE ".gemini\config\skills"
} else {
    "C:\Users\Administrator\.gemini\config\skills"
}

$LOCAL_PLUGINS_DIR = if ($env:USERPROFILE) {
    Join-Path $env:USERPROFILE ".gemini\config\plugins"
} else {
    "C:\Users\Administrator\.gemini\config\plugins"
}

$SYNC_STATE_FILE = Join-Path $LOCAL_SKILLS_DIR ".sync-state.json"

# Daftar Repositori Remote untuk Fallback & Dual-Source
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
    @{ Name = "superpowers";          Url = "https://github.com/agent-bara/superpowers-bara.git";         UpstreamUrl = "https://github.com/obra/superpowers.git";               SkillPath = "skills" },
    @{ Name = "artemis";              Url = "https://github.com/agent-bara/artemis-bara.git";             UpstreamUrl = "https://github.com/google/artemis.git";                 SkillPath = "skills" }
)

# Pemetaan lengkap 155 Skill untuk Sinkronisasi & Backup
$SKILL_MAP = @{
    caveman = @{
        upstream_repo        = "https://github.com/JuliusBrussee/caveman.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("caveman", "caveman-commit", "caveman-compress",
                                  "caveman-discover", "caveman-evidence-review",
                                  "caveman-explore", "caveman-help", "caveman-learn",
                                  "caveman-manage", "caveman-optimize", "caveman-review",
                                  "caveman-setup", "caveman-stats", "cavecrew",
                                  "cave", "megacave", "ultracave", "graphify",
                                  "quality-control", "bahasa-indonesia",
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
        local_skill_prefixes = @("rtk", "code-simplifier", "design-patterns", "issue-triage",
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
    artemis = @{
        upstream_repo        = "https://github.com/google/artemis.git"
        upstream_skill_path  = "skills"
        local_skill_prefixes = @("artemis")
        backup_repo          = "https://github.com/agent-bara/artemis-bara.git"
        backup_branch        = "main"
    }
}

# --- Format & Logging Helpers ---
function Write-Step([string]$msg) { Write-Host "`n[>>] $msg" -ForegroundColor Cyan }
function Write-Ok([string]$msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn([string]$msg) { Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function Write-Fail([string]$msg) { Write-Host "  [XX] $msg" -ForegroundColor Red }
function Write-Info([string]$msg) { Write-Host "       $msg" -ForegroundColor Gray }

function Invoke-GitWithSpinner {
    param(
        [string]$Message,
        [string]$WorkDir = "",
        [string[]]$GitArgs = @()
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "git"
    $escapedArgs = $GitArgs | ForEach-Object {
        if ($_ -match '[\s"]') { '"{0}"' -f ($_ -replace '"', '\"') } else { $_ }
    }
    $psi.Arguments = ($escapedArgs -join " ")
    if ($WorkDir -and (Test-Path $WorkDir)) {
        $psi.WorkingDirectory = (Resolve-Path $WorkDir).Path
    }
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        [void]$proc.Start()
    } catch {
        return [PSCustomObject]@{ ExitCode = 1; Output = $_.Exception.Message; Elapsed = [TimeSpan]::Zero }
    }

    $outTask = $proc.StandardOutput.ReadToEndAsync()
    $errTask = $proc.StandardError.ReadToEndAsync()

    $frames = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    if ([Console]::OutputEncoding.CodePage -ne 65001) {
        $frames = @('|', '/', '-', '\')
    }

    $i = 0
    while (-not $proc.HasExited) {
        $f = $frames[$i % $frames.Length]
        $el = "{0:d2}:{1:d2}" -f [int]$sw.Elapsed.TotalMinutes, $sw.Elapsed.Seconds
        $line = "       [$f] $Message ($el)..."
        if ($line.Length -gt 78) { $line = $line.Substring(0, 78) }
        Write-Host -NoNewline "`r$line"
        Start-Sleep -Milliseconds 80
        $i++
    }

    $proc.WaitForExit()
    $exitCode = $proc.ExitCode
    $stdout = $outTask.Result
    $stderr = $errTask.Result
    $sw.Stop()

    Write-Host -NoNewline ("`r" + (" " * 79) + "`r")

    $combined = ($stdout + "`n" + $stderr).Trim()
    return [PSCustomObject]@{
        ExitCode = $exitCode
        Output   = $combined
        Elapsed  = $sw.Elapsed
    }
}

function Invoke-GitCloneWithFallback {
    param(
        [string]$Name,
        [string]$PrimaryUrl,
        [string]$FallbackUrl,
        [string]$Destination
    )

    $resPri = Invoke-GitWithSpinner -Message "Mengunduh $Name dari repositori utama..." -GitArgs @("-c", "credential.helper=", "clone", "--depth", "1", "--quiet", $PrimaryUrl, $Destination)
    if ($resPri.ExitCode -eq 0 -and (Test-Path $Destination)) {
        Write-Ok "$Name berhasil diunduh dari repositori utama ($($resPri.Elapsed.TotalSeconds.ToString('0.0'))s)."
        return $true
    }

    if ($FallbackUrl -and ($FallbackUrl -ne $PrimaryUrl)) {
        Write-Warn "Primary repo tidak dapat diakses. Beralih ke upstream publik: $FallbackUrl..."
        if (Test-Path $Destination) { Remove-Item -Path $Destination -Recurse -Force -ErrorAction SilentlyContinue }
        $resFb = Invoke-GitWithSpinner -Message "Mengunduh $Name dari upstream publik..." -GitArgs @("-c", "credential.helper=", "clone", "--depth", "1", "--quiet", $FallbackUrl, $Destination)
        if ($resFb.ExitCode -eq 0 -and (Test-Path $Destination)) {
            Write-Ok "$Name berhasil diunduh dari upstream publik ($($resFb.Elapsed.TotalSeconds.ToString('0.0'))s)!"
            return $true
        }
    }

    Write-Fail "Gagal mengunduh $Name baik dari repositori utama maupun upstream."
    return $false
}

function Get-LocalSources([string]$BaseDir) {
    if (-not (Test-Path $BaseDir)) { return @() }
    $dirs = @(Get-ChildItem -Path $BaseDir -Directory | Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'mcp-bahasa-indonesia' -and $_.Name -ne 'skills' -and $_.Name -ne 'scripts' })
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

# ==============================================================================
# MODE 1: INSTALL SKILLS (Default / irm one-liner)
# ==============================================================================
function Run-Install {
    Write-Host "`n=== Antigravity Global Skill Installer (Windows) ===" -ForegroundColor Magenta
    Write-Host "Target Skills : $LOCAL_SKILLS_DIR" -ForegroundColor Gray
    Write-Host "Target Plugins: $LOCAL_PLUGINS_DIR`n" -ForegroundColor Gray

    if (-not (Test-Path $LOCAL_SKILLS_DIR))  { New-Item -ItemType Directory -Path $LOCAL_SKILLS_DIR -Force | Out-Null }
    if (-not (Test-Path $LOCAL_PLUGINS_DIR)) { New-Item -ItemType Directory -Path $LOCAL_PLUGINS_DIR -Force | Out-Null }

    if ($CloneLocal) {
        Write-Step "Opsi -CloneLocal aktif: Memeriksa dan mengkloning repositori ke workspace lokal..."
        foreach ($repo in $REMOTE_REPOS) {
            $destRepo = Join-Path $WORKSPACE_DIR $repo.Name
            if (-not (Test-Path $destRepo)) {
                Invoke-GitCloneWithFallback -Name $repo.Name -PrimaryUrl $repo.Url -FallbackUrl $repo.UpstreamUrl -Destination $destRepo | Out-Null
            }
        }
    }

    $sources = @(Get-LocalSources -BaseDir $WORKSPACE_DIR)

    # Auto-Download jika belum ada folder lokal
    if ($sources.Count -eq 0) {
        Write-Step "Tidak ada repositori lokal ditemukan di: $WORKSPACE_DIR"
        Write-Info "Mengunduh langsung dari GitHub ke folder sementara..."
        $tempDir = Join-Path $env:TEMP "skills-dl-$(Get-Date -Format 'yyyyMMddHHmmss')"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        $dlCount = 0

        try {
            foreach ($repo in $REMOTE_REPOS) {
                Write-Step "Mengunduh $($repo.Name)..."
                $cloneTarget = Join-Path $tempDir $repo.Name
                $cloned = Invoke-GitCloneWithFallback -Name $repo.Name -PrimaryUrl $repo.Url -FallbackUrl $repo.UpstreamUrl -Destination $cloneTarget
                if ($cloned) {
                    $skillBase = Join-Path $cloneTarget $repo.SkillPath
                    if (Test-Path $skillBase) {
                        $sList = @(Get-ChildItem -Path $skillBase -Filter "SKILL.md" -Recurse -File)
                        foreach ($sk in $sList) {
                            $skDir = $sk.Directory
                            $dPath = Join-Path $LOCAL_SKILLS_DIR $skDir.Name
                            if ((Test-Path $dPath) -and -not $Force) { continue }
                            if (Test-Path $dPath) { Remove-Item -Path $dPath -Recurse -Force }
                            Copy-Item -Path $skDir.FullName -Destination $dPath -Recurse -Force
                            $dlCount++
                        }
                    }
                }
            }
            Write-Host "`n=== Installation Summary ===" -ForegroundColor Magenta
            Write-Ok "Total skill berhasil diunduh dan dipasang: $dlCount"
            return
        } finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Pemasangan dari repositori lokal
    $installed = 0
    $skipped = 0
    $errors = @()

    foreach ($s in $sources) {
        $skills = @(Get-ChildItem -Path $s.Path -Filter "SKILL.md" -Recurse -File)
        Write-Step "Memproses $($s.Repo) ($($skills.Count) skills)..."

        foreach ($sk in $skills) {
            $skillDir = $sk.Directory
            $skillName = $skillDir.Name
            $destPath = Join-Path $LOCAL_SKILLS_DIR $skillName

            if ((Test-Path $destPath) -and -not $Force) {
                if (Test-Path (Join-Path $destPath "SKILL.md")) {
                    $skipped++
                    continue
                }
            }

            try {
                if (Test-Path $destPath) { Remove-Item -Path $destPath -Recurse -Force }
                Copy-Item -Path $skillDir.FullName -Destination $destPath -Recurse -Force

                # Validasi & perbaikan frontmatter jika name: belum ada
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
                $errors += [PSCustomObject]@{ Skill = $skillName; Repo = $s.Repo; Error = $_.Exception.Message }
            }
        }
    }

    # Salin Plugin Antigravity (RTK & Superpowers)
    $rtkPlugin = Join-Path $WORKSPACE_DIR "rtk\plugins\rtk"
    if (-not (Test-Path $rtkPlugin)) { $rtkPlugin = Join-Path $WORKSPACE_DIR "rtk" }
    if (Test-Path (Join-Path $rtkPlugin "plugin.json")) {
        $rtkDest = Join-Path $LOCAL_PLUGINS_DIR "rtk"
        if (-not (Test-Path $rtkDest) -or $Force) {
            Copy-Item -Path $rtkPlugin -Destination $rtkDest -Recurse -Force
        }
    }

    $spPlugin = Join-Path $WORKSPACE_DIR "superpowers"
    if (Test-Path (Join-Path $spPlugin "plugin.json")) {
        $spDest = Join-Path $LOCAL_PLUGINS_DIR "superpowers"
        if (-not (Test-Path $spDest) -or $Force) {
            Copy-Item -Path $spPlugin -Destination $spDest -Recurse -Force
        }
    }

    Write-Host "`n=== Installation Summary ===" -ForegroundColor Magenta
    Write-Ok "Skill baru terpasang / diperbarui : $installed"
    Write-Info "Skill dilewati (sudah terpasang)  : $skipped"
    if ($errors.Count -gt 0) {
        Write-Fail "Terjadi $($errors.Count) kesalahan:"
        $errors | Format-Table -AutoSize
    } else {
        Write-Ok "Seluruh skill Antigravity siap digunakan!"
    }
}

# ==============================================================================
# MODE 2: AUDIT & CHECK
# ==============================================================================
function Run-Check {
    Write-Host "`n=== Skill & Repository Integrity Check ===" -ForegroundColor Cyan

    Write-Step "Mengecek apakah ada folder repository skill baru di direktori lokal..."
    $ignored = @('mcp-bahasa-indonesia', 'scripts', 'skills', 'docs', 'markitdown', 'awesome-design-md')
    $localDirs = @(Get-ChildItem -Path $WORKSPACE_DIR -Directory | Where-Object { $_.Name -notmatch '^\.' -and $ignored -notcontains $_.Name })
    
    $knownKeys = @{}
    foreach ($k in $SKILL_MAP.Keys) {
        $knownKeys[$k.ToLower()] = $true
        $knownKeys[($k -replace '-bara$', '' -replace '-', '').ToLower()] = $true
    }

    $unmappedRepos = @()
    foreach ($d in $localDirs) {
        $norm = ($d.Name -replace '-bara$', '' -replace '-', '').ToLower()
        if (-not $knownKeys.ContainsKey($norm)) {
            $unmappedRepos += $d.Name
        }
    }
    if ($unmappedRepos.Count -gt 0) {
        Write-Warn "Folder repositori lokal belum terdaftar di `$SKILL_MAP: $($unmappedRepos -join ', ')"
    } else {
        Write-Ok "Semua folder skill di direktori lokal sudah terdaftar di `$SKILL_MAP."
    }

    Write-Step "Mengecek pemetaan skill di direktori global Antigravity..."
    $allPrefixes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in $SKILL_MAP.Values) {
        if ($entry.local_skill_prefixes) {
            foreach ($p in $entry.local_skill_prefixes) { [void]$allPrefixes.Add($p) }
        }
    }

    if (Test-Path $LOCAL_SKILLS_DIR) {
        $globalList = @(Get-ChildItem -Path $LOCAL_SKILLS_DIR -Directory | Select-Object -ExpandProperty Name)
        $unmappedSkills = @($globalList | Where-Object { -not $allPrefixes.Contains($_) })
        Write-Info "Total skill terpasang di global: $($globalList.Count)"
        Write-Info "Total prefix terdaftar: $($allPrefixes.Count)"
        if ($unmappedSkills.Count -gt 0) {
            Write-Warn "Skill global belum terpetakan ($($unmappedSkills.Count)): $($unmappedSkills -join ', ')"
        } else {
            Write-Ok "Semua skill global ($($globalList.Count) skill) 100% terpetakan di `$SKILL_MAP."
        }
    }

    Write-Host "`nPengecekan selesai." -ForegroundColor Green
}

# ==============================================================================
# MODE 3: SYNC UPSTREAM & PUSH BACKUP
# ==============================================================================
function Run-Sync {
    Write-Host "`n=== Skill Sync Upstream & Backup ===" -ForegroundColor Cyan
    Run-Check

    if ($DryRun)   { Write-Warn "Mode DRY RUN aktif. Tidak ada perubahan yang disimpan ke remote." }
    if ($SkipPush) { Write-Info "Mode SKIP PUSH aktif. Perubahan hanya digabungkan secara lokal." }

    $targetSkills = if ($SkillFilter -eq "all") {
        @($SKILL_MAP.Keys)
    } else {
        @($SkillFilter -split "," | ForEach-Object { $_.Trim() })
    }

    foreach ($skillKey in $targetSkills) {
        if (-not $SKILL_MAP.ContainsKey($skillKey)) {
            Write-Warn "Skill '$skillKey' tidak terdaftar di `$SKILL_MAP. Dilewati."
            continue
        }

        $cfg = $SKILL_MAP[$skillKey]
        Write-Step "Sinkronisasi: $skillKey"

        # Kloning/Update Upstream
        $localRepo = Join-Path $WORKSPACE_DIR $skillKey
        if (-not (Test-Path $localRepo)) {
            $localRepo = Join-Path $WORKSPACE_DIR "$skillKey-bara"
        }

        if (Test-Path $localRepo) {
            Write-Info "Menarik update upstream..."
            $pullRes = Invoke-GitWithSpinner -Message "git pull upstream..." -WorkDir $localRepo -GitArgs @("pull", "--no-edit", "--quiet")
            if ($pullRes.ExitCode -eq 0) {
                Write-Ok "Local repository up-to-date."
            } else {
                Write-Info "Status pull: $($pullRes.Output)"
            }

            if (-not $SkipPush -and -not $DryRun) {
                Write-Info "Push ke backup repo..."
                $pushRes = Invoke-GitWithSpinner -Message "git push backup..." -WorkDir $localRepo -GitArgs @("push", "origin", $cfg.backup_branch, "--quiet")
                if ($pushRes.ExitCode -eq 0) {
                    Write-Ok "Backup repo tersinkronisasi."
                } else {
                    Write-Info "Status push: $($pushRes.Output)"
                }
            }
        } else {
            Write-Info "Repositori lokal untuk '$skillKey' belum di-clone. Melewati sync lokal."
        }
    }

    # Pasang kembali ke global agar update langsung aktif
    Run-Install
}

    # --- Router Aksi Utama ---
    switch ($Action.ToLower()) {
        "sync"    { Run-Sync }
        "check"   { Run-Check }
        "help"    { Get-Help $MyInvocation.MyCommand.Path; return }
        default   { Run-Install }
    }
}

Invoke-AntigravitySkillManager @args
