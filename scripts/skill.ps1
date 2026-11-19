# Antigravity All-in-One Skill Manager (Windows PowerShell)
# Repositori resmi: https://github.com/23Barajapu/skill-agent

function Invoke-AntigravitySkillManager {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Position = 0)]
        [ValidateSet("install", "sync", "check", "help", "")]
        [string]$Action = "install",

        [string]$SkillFilter = "all",
        [string]$Target = "",
        [string]$Package = "",
        [switch]$NonInteractive,
        [switch]$Yes,
        [switch]$Y,
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

if ($Yes -or $Y) { $NonInteractive = $true }

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
    @{ Name = "rtk";                  Url = "https://github.com/agent-bara/rtk-bara.git";                 UpstreamUrl = "https://github.com/rtk-ai/rtk.git";                     SkillPath = ".claude/skills" },
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

# ==============================================================================
# MULTI-AGENT & PACKAGE DEFINITIONS
# ==============================================================================
$SKILL_PACKAGES = @(
    @{ Id = 1;  Key = "anti-slop";            Name = "Anti-Slop";                  Count = 6;  Desc = "UI Bersih, Aksesibilitas, Anti-AI Writing";      Repos = @("anti-slop") },
    @{ Id = 2;  Key = "caveman";              Name = "Caveman & Token Efficiency"; Count = 26; Desc = "Kompresi Konteks, Graphify, Hemat Token";       Repos = @("caveman") },
    @{ Id = 3;  Key = "ponytail";             Name = "Ponytail";                   Count = 6;  Desc = "Koding Pragmatis, Minimalis, Anti-Bloat";        Repos = @("ponytail-bara", "ponytail") },
    @{ Id = 4;  Key = "agent-skills";         Name = "Agent Core Engineering";     Count = 25; Desc = "API Design, TDD, OWASP, Debugging Sistematis";  Repos = @("agent-skills") },
    @{ Id = 5;  Key = "engineering-skills";   Name = "Engineering & Productivity"; Count = 37; Desc = "Praktik Rekayasa Matt Pocock, TDD, Refactor";    Repos = @("engineering-skills") },
    @{ Id = 6;  Key = "rtk";                  Name = "RTK Specialist";             Count = 13; Desc = "CLI Token Killer Proxy, Rust TDD";              Repos = @("rtk") },
    @{ Id = 7;  Key = "rea";                  Name = "REA - Reverse Engineering";  Count = 5;  Desc = "Rekayasa Balik Biner, Native, & Web Runtime";    Repos = @("rea") },
    @{ Id = 8;  Key = "apple-design";         Name = "Apple Design & Motion";      Count = 14; Desc = "Fisika Fluida, Animasi 60fps, Swift Modern";     Repos = @("apple-design") },
    @{ Id = 9;  Key = "security-audit-skill"; Name = "Security Audit & Pen-Testing";Count = 1; Desc = "Audit Keamanan OWASP, Inspeksi API";            Repos = @("security-audit-skill") },
    @{ Id = 10; Key = "superpowers";          Name = "Superpowers Workflow";       Count = 15; Desc = "Metodologi Agen, Spec-First, Sub-Agent Paralel"; Repos = @("superpowers") },
    @{ Id = 11; Key = "chrome-devtools-mcp";   Name = "Chrome DevTools MCP";        Count = 7;  Desc = "Otomasi Browser, Core Web Vitals, Memory Leak";   Repos = @("chrome-devtools-mcp") },
    @{ Id = 12; Key = "artemis";              Name = "ARTEMIS Mobile Testing";     Count = 1;  Desc = "Otomasi & Pengujian Android ADB Multimodal";     Repos = @("artemis") }
)

function Get-AvailableAgents {
    $uHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
    $appData = if ($env:APPDATA) { $env:APPDATA } else { "" }

    return @(
        @{
            Id        = 1
            Key       = "antigravity"
            Name      = "Google Antigravity"
            Detected  = (Test-Path (Join-Path $uHome ".gemini"))
            Home      = (Join-Path $uHome ".gemini")
            SkillsDir = (Join-Path $uHome ".gemini\config\skills")
            PluginsDir= (Join-Path $uHome ".gemini\config\plugins")
            Type      = "native_skill"
        },
        @{
            Id        = 2
            Key       = "kiro"
            Name      = "Kiro IDE"
            Detected  = (Test-Path (Join-Path $uHome ".kiro")) -or [bool](Get-Command kiro -ErrorAction SilentlyContinue)
            Home      = (Join-Path $uHome ".kiro")
            SkillsDir = (Join-Path $uHome ".kiro\skills")
            Type      = "native_skill"
        },
        @{
            Id        = 3
            Key       = "claude"
            Name      = "Claude Code / Desktop"
            Detected  = (Test-Path (Join-Path $uHome ".claude")) -or [bool](Get-Command claude -ErrorAction SilentlyContinue)
            Home      = (Join-Path $uHome ".claude")
            SkillsDir = (Join-Path $uHome ".claude\skills")
            RulesDir  = (Join-Path $uHome ".claude/rules")
            Type      = "claude"
        },
        @{
            Id        = 4
            Key       = "windsurf"
            Name      = "Windsurf (Codeium)"
            Detected  = (Test-Path (Join-Path $uHome ".codeium\windsurf")) -or [bool](Get-Command windsurf -ErrorAction SilentlyContinue)
            Home      = (Join-Path $uHome ".codeium\windsurf")
            RulesDir  = (Join-Path $uHome ".codeium/windsurf/rules")
            Type      = "windsurf_rule"
        },
        @{
            Id        = 5
            Key       = "cursor"
            Name      = "Cursor IDE"
            Detected  = (Test-Path (Join-Path $uHome ".cursor")) -or [bool](Get-Command cursor -ErrorAction SilentlyContinue)
            Home      = (Join-Path $uHome ".cursor")
            RulesDir  = (Join-Path $uHome ".cursor/rules")
            Type      = "cursor_mdc"
        },
        @{
            Id        = 6
            Key       = "vscode"
            Name      = "VS Code / Cline"
            Detected  = (Test-Path (Join-Path $uHome ".cline")) -or ($appData -and (Test-Path (Join-Path $appData "Code")))
            Home      = (Join-Path $uHome ".cline")
            RulesDir  = (Join-Path $uHome ".cline/rules")
            Type      = "cline_rule"
        }
    )
}

function Copy-SkillToAgent {
    param(
        [hashtable]$Agent,
        [System.IO.DirectoryInfo]$SkillDir,
        [string]$SkillName,
        [bool]$ForceOverwrite = $false
    )

    switch ($Agent.Type) {
        "native_skill" {
            if (-not (Test-Path $Agent.SkillsDir)) { New-Item -ItemType Directory -Path $Agent.SkillsDir -Force | Out-Null }
            $dest = Join-Path $Agent.SkillsDir $SkillName
            if ((Test-Path $dest) -and -not $ForceOverwrite) { return "skipped" }
            if (Test-Path $dest) { Remove-Item -Path $dest -Recurse -Force }
            Copy-Item -Path $SkillDir.FullName -Destination $dest -Recurse -Force

            $destSkillMd = Join-Path $dest "SKILL.md"
            if (Test-Path $destSkillMd) {
                $content = Get-Content -Path $destSkillMd -Raw
                if ($content -notmatch "(?m)^name:\s*") {
                    if ($content -match "^(?:?
)?---?
") {
                        $content = $content -replace "^(?:?
)?---?
", "---`nname: $SkillName`n"
                    } else {
                        $content = "---`nname: $SkillName`n---`n" + $content
                    }
                    Set-Content -Path $destSkillMd -Value $content -Encoding UTF8
                }
            }
            return "installed"
        }
        "claude" {
            if (-not (Test-Path $Agent.SkillsDir)) { New-Item -ItemType Directory -Path $Agent.SkillsDir -Force | Out-Null }
            if (-not (Test-Path $Agent.RulesDir))  { New-Item -ItemType Directory -Path $Agent.RulesDir -Force | Out-Null }
            
            $destSkill = Join-Path $Agent.SkillsDir $SkillName
            if (-not (Test-Path $destSkill) -or $ForceOverwrite) {
                if (Test-Path $destSkill) { Remove-Item -Path $destSkill -Recurse -Force }
                Copy-Item -Path $SkillDir.FullName -Destination $destSkill -Recurse -Force
            }
            
            $srcSkillMd = Join-Path $SkillDir.FullName "SKILL.md"
            if (Test-Path $srcSkillMd) {
                $destRule = Join-Path $Agent.RulesDir "$SkillName.md"
                Copy-Item -Path $srcSkillMd -Destination $destRule -Force
            }
            return "installed"
        }
        "cursor_mdc" {
            if (-not (Test-Path $Agent.RulesDir)) { New-Item -ItemType Directory -Path $Agent.RulesDir -Force | Out-Null }
            $srcSkillMd = Join-Path $SkillDir.FullName "SKILL.md"
            if (Test-Path $srcSkillMd) {
                $destMdc = Join-Path $Agent.RulesDir "$SkillName.mdc"
                Copy-Item -Path $srcSkillMd -Destination $destMdc -Force
                return "installed"
            }
            return "skipped"
        }
        "windsurf_rule" {
            if (-not (Test-Path $Agent.RulesDir)) { New-Item -ItemType Directory -Path $Agent.RulesDir -Force | Out-Null }
            $srcSkillMd = Join-Path $SkillDir.FullName "SKILL.md"
            if (Test-Path $srcSkillMd) {
                $destMd = Join-Path $Agent.RulesDir "$SkillName.md"
                Copy-Item -Path $srcSkillMd -Destination $destMd -Force
                return "installed"
            }
            return "skipped"
        }
        "cline_rule" {
            if (-not (Test-Path $Agent.RulesDir)) { New-Item -ItemType Directory -Path $Agent.RulesDir -Force | Out-Null }
            $srcSkillMd = Join-Path $SkillDir.FullName "SKILL.md"
            if (Test-Path $srcSkillMd) {
                $destMd = Join-Path $Agent.RulesDir "$SkillName.md"
                Copy-Item -Path $srcSkillMd -Destination $destMd -Force
                return "installed"
            }
            return "skipped"
        }
    }
    return "skipped"
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
# MODE 1: INSTALL SKILLS (Multi-Agent & Package Selection)
# ==============================================================================
function Run-Install {
    Write-Host "`n=== Universal AI Agent & Skill Suite Installer (Windows) ===" -ForegroundColor Magenta

    $allAgents = @(Get-AvailableAgents)
    $detectedAgents = @($allAgents | Where-Object { $_.Detected })
    if ($detectedAgents.Count -eq 0) {
        $detectedAgents = @($allAgents | Where-Object { $_.Key -eq "antigravity" })
    }

    # --- LANGKAH 1: DETEKSI & PEMILIHAN TARGET AGENT / IDE ---
    $selectedAgents = @()
    if ($Target -eq "all") {
        $selectedAgents = $detectedAgents
    } elseif ($Target) {
        $targetTokens = @($Target -split "," | ForEach-Object { $_.Trim().ToLower() })
        foreach ($tok in $targetTokens) {
            $match = $allAgents | Where-Object { $_.Key -eq $tok -or $_.Id.ToString() -eq $tok }
            if ($match) { $selectedAgents += $match }
        }
    } elseif (-not $NonInteractive) {
        Write-Host "`n======================================================" -ForegroundColor Cyan
        Write-Host " [1/2] DETEKSI TARGET AI AGENT / IDE DI KOMPUTER     " -ForegroundColor Cyan
        Write-Host "======================================================" -ForegroundColor Cyan
        foreach ($ag in $allAgents) {
            $mark = if ($ag.Detected) { "[x]" } else { "[ ]" }
            $color = if ($ag.Detected) { "Green" } else { "DarkGray" }
            $status = if ($ag.Detected) { "(Terdeteksi: $($ag.Home))" } else { "(Tidak terpasang)" }
            Write-Host "  $mark $($ag.Id). $($ag.Name.PadRight(23)) $status" -ForegroundColor $color
        }
        Write-Host "`n  [A] Pasang ke SEMUA yang terdeteksi (Default)" -ForegroundColor Yellow
        Write-Host "Pilih target [A atau nomor, contoh: 1,2] (Tekan Enter untuk Default [A]): " -NoNewline -ForegroundColor Cyan
        $tInput = ""
        try { $tInput = Read-Host } catch { $tInput = "A" }
        if ([string]::IsNullOrWhiteSpace($tInput)) { $tInput = "A" }

        if ($tInput -match '^(?i)a$') {
            $selectedAgents = $detectedAgents
        } else {
            $tokens = @($tInput -split "," | ForEach-Object { $_.Trim().ToLower() })
            foreach ($tok in $tokens) {
                $match = $allAgents | Where-Object { $_.Key -eq $tok -or $_.Id.ToString() -eq $tok }
                if ($match) { $selectedAgents += $match }
            }
        }
    } else {
        $selectedAgents = $detectedAgents
    }

    if ($selectedAgents.Count -eq 0) { $selectedAgents = $detectedAgents }

    # --- LANGKAH 2: PEMILIHAN PAKET SKILL ---
    $selectedPackages = @()
    if ($Package -eq "all") {
        $selectedPackages = $SKILL_PACKAGES
    } elseif ($Package) {
        $pkgTokens = @($Package -split "," | ForEach-Object { $_.Trim().ToLower() })
        foreach ($tok in $pkgTokens) {
            $match = $SKILL_PACKAGES | Where-Object { $_.Key -eq $tok -or $_.Id.ToString() -eq $tok }
            if ($match) { $selectedPackages += $match }
        }
    } elseif (-not $NonInteractive) {
        Write-Host "`n======================================================" -ForegroundColor Cyan
        Write-Host " [2/2] PEMILIHAN PAKET SKILL YANG INGIN DIPASANG     " -ForegroundColor Cyan
        Write-Host "======================================================" -ForegroundColor Cyan
        Write-Host "  [A] SEMUA 155 Skill (12 Paket Lengkap) [Default]`n  ----------------------------------------------------" -ForegroundColor Yellow
        foreach ($pkg in $SKILL_PACKAGES) {
            $num = $pkg.Id.ToString().PadLeft(2)
            Write-Host "  [$num] $($pkg.Name.PadRight(28)) ($($pkg.Count) Skill - $($pkg.Desc))" -ForegroundColor Gray
        }
        Write-Host "`nPilih paket [A atau nomor, contoh: 1,8,12] (Tekan Enter untuk Default [A]): " -NoNewline -ForegroundColor Cyan
        $pInput = ""
        try { $pInput = Read-Host } catch { $pInput = "A" }
        if ([string]::IsNullOrWhiteSpace($pInput)) { $pInput = "A" }

        if ($pInput -match '^(?i)a$') {
            $selectedPackages = $SKILL_PACKAGES
        } else {
            $tokens = @($pInput -split "," | ForEach-Object { $_.Trim().ToLower() })
            foreach ($tok in $tokens) {
                $match = $SKILL_PACKAGES | Where-Object { $_.Key -eq $tok -or $_.Id.ToString() -eq $tok }
                if ($match) { $selectedPackages += $match }
            }
        }
    } else {
        $selectedPackages = $SKILL_PACKAGES
    }

    if ($selectedPackages.Count -eq 0) { $selectedPackages = $SKILL_PACKAGES }

    # Himpun repositori yang diizinkan berdasarkan paket terpilih
    $allowedRepos = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($pkg in $selectedPackages) {
        foreach ($r in $pkg.Repos) { [void]$allowedRepos.Add($r) }
    }

    Write-Step "Target Agen : $(($selectedAgents | ForEach-Object { $_.Name }) -join ', ')"
    Write-Step "Paket Skill : $(($selectedPackages | ForEach-Object { $_.Name }) -join ', ')"

    if ($CloneLocal) {
        Write-Step "Opsi -CloneLocal aktif: Memeriksa dan mengkloning repositori ke workspace lokal..."
        foreach ($repo in $REMOTE_REPOS) {
            if (-not $allowedRepos.Contains($repo.Name)) { continue }
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
                if (-not $allowedRepos.Contains($repo.Name)) { continue }
                Write-Step "Mengunduh $($repo.Name)..."
                $cloneTarget = Join-Path $tempDir $repo.Name
                $cloned = Invoke-GitCloneWithFallback -Name $repo.Name -PrimaryUrl $repo.Url -FallbackUrl $repo.UpstreamUrl -Destination $cloneTarget
                if ($cloned) {
                    $skillBase = Join-Path $cloneTarget $repo.SkillPath
                    if (-not (Test-Path $skillBase)) {
                        foreach ($cand in @(".claude\skills", ".agents\skills", "skills")) {
                            $t = Join-Path $cloneTarget $cand
                            if (Test-Path $t) { $skillBase = $t; break }
                        }
                    }
                    if (Test-Path $skillBase) {
                        $sList = @(Get-ChildItem -Path $skillBase -Filter "SKILL.md" -Recurse -File)
                        foreach ($sk in $sList) {
                            $skDir = $sk.Directory
                            foreach ($ag in $selectedAgents) {
                                [void](Copy-SkillToAgent -Agent $ag -SkillDir $skDir -SkillName $skDir.Name -ForceOverwrite $Force)
                            }
                            $dlCount++
                        }
                    }
                }
            }
        } finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    } else {
        # Pemasangan dari repositori lokal
        $installed = 0
        $skipped = 0
        $errors = @()

        foreach ($s in $sources) {
            if (-not $allowedRepos.Contains($s.Repo) -and -not $allowedRepos.Contains(($s.Repo -replace '-bara$', ''))) { continue }
            $skills = @(Get-ChildItem -Path $s.Path -Filter "SKILL.md" -Recurse -File)
            Write-Step "Memproses $($s.Repo) ($($skills.Count) skills)..."

            foreach ($sk in $skills) {
                $skillDir = $sk.Directory
                $skillName = $skillDir.Name

                foreach ($ag in $selectedAgents) {
                    try {
                        $res = Copy-SkillToAgent -Agent $ag -SkillDir $skillDir -SkillName $skillName -ForceOverwrite $Force
                        if ($res -eq "installed") { $installed++ } else { $skipped++ }
                    } catch {
                        $errors += [PSCustomObject]@{ Skill = $skillName; Agent = $ag.Name; Error = $_.Exception.Message }
                    }
                }
            }
        }

        # Salin Plugin Antigravity (RTK & Superpowers) jika Antigravity dipilih
        $hasAntigravity = [bool]($selectedAgents | Where-Object { $_.Key -eq "antigravity" })
        if ($hasAntigravity) {
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
        }
    }

    Write-Host "`n=== Installation Summary ===" -ForegroundColor Magenta
    Write-Ok "Pemasangan selesai ke $($selectedAgents.Count) Target AI Agent:"
    foreach ($ag in $selectedAgents) {
        $destPath = if ($ag.ContainsKey('SkillsDir')) { $ag['SkillsDir'] } else { $ag['RulesDir'] }
        $count = 0
        if (Test-Path $destPath) {
            $count = @(Get-ChildItem -Path $destPath).Count
        }
        Write-Host "       - $($ag.Name.PadRight(22)) : $count skill/rule terpasang ($destPath)" -ForegroundColor Green
    }
    Write-Ok "Seluruh skill siap digunakan di semua lingkungan kerja yang dipilih!"
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
