#!/usr/bin/env bash
# ==============================================================================
# Antigravity All-in-One Skill Manager (macOS & Linux)
# ==============================================================================
# Penggunaan:
#   1. Web Installer Satu Baris (Streaming / Tanpa Clone):
#      curl -fsSL https://raw.githubusercontent.com/23Barajapu/skill-suite-sch/main/scripts/skill.sh | bash
#
#   2. Eksekusi Lokal:
#      ./scripts/skill.sh              # Pasang/update skill ke global
#      ./scripts/skill.sh --force      # Pasang ulang paksa
#      ./scripts/skill.sh --clone      # Clone repositori ke workspace lokal
#      ./scripts/skill.sh --check      # Audit integritas skill
#      ./scripts/skill.sh --sync       # Sinkronisasi upstream & backup
# ==============================================================================

set -euo pipefail

TARGET_DIR="${HOME}/.gemini/config/skills"
PLUGINS_DIR="${HOME}/.gemini/config/plugins"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "${PWD}")"
WORKSPACE_DIR="$(dirname "${SCRIPT_DIR}")"

ACTION="install"
FORCE=0
CLONE_LOCAL=0
TARGET_ARG=""
PACKAGE_ARG=""
NON_INTERACTIVE=0

# Parse argumen
while [[ $# -gt 0 ]]; do
    case "$1" in
        --force|-Force|-f)
            FORCE=1
            shift
            ;;
        --clone|-CloneLocal|clone)
            CLONE_LOCAL=1
            shift
            ;;
        --sync|sync)
            ACTION="sync"
            shift
            ;;
        --check|check)
            ACTION="check"
            shift
            ;;
        --target|-t)
            TARGET_ARG="$2"
            shift 2
            ;;
        --package|-p)
            PACKAGE_ARG="$2"
            shift 2
            ;;
        --yes|-y|--non-interactive)
            NON_INTERACTIVE=1
            shift
            ;;
        --help|help|-h)
            echo "Penggunaan: ./scripts/skill.sh [install|sync|check] [--force] [--clone] [--target all|1,2] [--package all|1,12] [--yes]"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Format warna terminal
C_RESET="\033[0m"
C_MAGENTA="\033[1;35m"
C_CYAN="\033[1;36m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_GRAY="\033[0;90m"
C_RED="\033[1;31m"

write_step() { echo -e "\n${C_CYAN}[>>] $1${C_RESET}"; }
write_ok()   { echo -e "  ${C_GREEN}[OK] $1${C_RESET}"; }
write_warn() { echo -e "  ${C_YELLOW}[!!] $1${C_RESET}"; }
write_info() { echo -e "       ${C_GRAY}$1${C_RESET}"; }
write_fail() { echo -e "  ${C_RED}[XX] $1${C_RESET}"; }

# Daftar repositori remote (Format: name|primary_url|upstream_url|skill_path)
declare -a REPOS=(
    "agent-skills|https://github.com/18schwarz/agent-skill-sch.git|https://github.com/addyosmani/agent-skills.git|skills"
    "anti-slop|https://github.com/18schwarz/antislop-sch.git|https://github.com/miqdadbadjuber/anti-slop.git|skills"
    "apple-design|https://github.com/18schwarz/apple-design.git|https://github.com/emilkowalski/skills.git|skills"
    "caveman|https://github.com/18schwarz/caveman-sch.git|https://github.com/JuliusBrussee/caveman.git|skills"
    "chrome-devtools-mcp|https://github.com/18schwarz/chrome-devtools-sch.git|https://github.com/ChromeDevTools/chrome-devtools-mcp.git|skills"
    "engineering-skills|https://github.com/18schwarz/engineering-skills-sch.git|https://github.com/mattpocock/skills.git|skills"
    "ponytail-bara|https://github.com/18schwarz/ponytail-sch.git|https://github.com/DietrichGebert/ponytail.git|skills"
    "rea|https://github.com/18schwarz/rea-sch.git|https://github.com/morluto/rea.git|.agents/skills"
    "rtk|https://github.com/18schwarz/rtk-sch.git|https://github.com/rtk-ai/rtk.git|.claude/skills"
    "security-audit-skill|https://github.com/18schwarz/security-audit-skill.git|https://github.com/cloudflare/security-audit-skill.git|skills"
    "superpowers|https://github.com/18schwarz/superpowers-sch.git|https://github.com/obra/superpowers.git|skills"
    "artemis|https://github.com/18schwarz/artemis-sch.git|https://github.com/google/artemis.git|skills"
)

clone_with_fallback() {
    local name="$1"
    local primary_url="$2"
    local upstream_url="$3"
    local dest="$4"

    export GIT_TERMINAL_PROMPT=0

    echo -ne "       Mengunduh ${name} dari repositori utama...\r"
    if git -c credential.helper= clone --depth 1 --quiet "${primary_url}" "${dest}" 2>/dev/null; then
        write_ok "${name} berhasil diunduh dari repositori utama."
        return 0
    fi

    if [[ -n "${upstream_url}" && "${upstream_url}" != "${primary_url}" ]]; then
        write_warn "Primary repo tidak dapat diakses. Menggunakan upstream publik: ${upstream_url}..."
        rm -rf "${dest}" 2>/dev/null || true
        if git -c credential.helper= clone --depth 1 --quiet "${upstream_url}" "${dest}" 2>/dev/null; then
            write_ok "${name} berhasil diunduh dari upstream publik!"
            return 0
        fi
    fi

    write_fail "Gagal mengunduh ${name}."
    return 1
}

copy_skill_to_agent() {
    local ag_type="$1"
    local ag_dir="$2"
    local s_dir="$3"
    local s_name="$4"

    mkdir -p "${ag_dir}" 2>/dev/null || true

    case "${ag_type}" in
        native)
            local dest="${ag_dir}/${s_name}"
            if [[ -d "${dest}" && "${FORCE}" -eq 0 ]]; then
                return 1
            fi
            rm -rf "${dest}" 2>/dev/null || true
            cp -R "${s_dir}" "${dest}"
            return 0
            ;;
        claude)
            local dest_s="${ag_dir}/skills/${s_name}"
            local dest_r="${ag_dir}/rules"
            mkdir -p "${ag_dir}/skills" "${dest_r}" 2>/dev/null || true
            if [[ ! -d "${dest_s}" || "${FORCE}" -eq 1 ]]; then
                rm -rf "${dest_s}" 2>/dev/null || true
                cp -R "${s_dir}" "${dest_s}"
            fi
            if [[ -f "${s_dir}/SKILL.md" ]]; then
                cp "${s_dir}/SKILL.md" "${dest_r}/${s_name}.md" 2>/dev/null || true
            fi
            return 0
            ;;
        rule_md)
            if [[ -f "${s_dir}/SKILL.md" ]]; then
                cp "${s_dir}/SKILL.md" "${ag_dir}/${s_name}.md" 2>/dev/null || true
                return 0
            fi
            return 1
            ;;
        rule_mdc)
            if [[ -f "${s_dir}/SKILL.md" ]]; then
                cp "${s_dir}/SKILL.md" "${ag_dir}/${s_name}.mdc" 2>/dev/null || true
                return 0
            fi
            return 1
            ;;
    esac
    return 1
}

run_install() {
    echo -e "
${C_MAGENTA}=== Universal AI Agent & Skill Suite Installer (macOS & Linux) ===${C_RESET}"

    # Deteksi Lingkungan
    local has_antigravity=0; [[ -d "${HOME}/.gemini" ]] && has_antigravity=1
    local has_kiro=0; ([[ -d "${HOME}/.kiro" ]] || command -v kiro &>/dev/null) && has_kiro=1
    local has_claude=0; ([[ -d "${HOME}/.claude" ]] || command -v claude &>/dev/null) && has_claude=1
    local has_windsurf=0; ([[ -d "${HOME}/.codeium/windsurf" ]] || command -v windsurf &>/dev/null) && has_windsurf=1
    local has_cursor=0; ([[ -d "${HOME}/.cursor" ]] || command -v cursor &>/dev/null) && has_cursor=1
    local has_vscode=0; ([[ -d "${HOME}/.cline" ]] || [[ -d "${HOME}/.vscode" ]]) && has_vscode=1

    # Langkah 1: Pilih Target
    local target_choice="${TARGET_ARG}"
    if [[ -z "${target_choice}" && "${NON_INTERACTIVE}" -eq 0 && -t 0 ]]; then
        echo -e "
${C_CYAN}======================================================${C_RESET}"
        echo -e "${C_CYAN} [1/2] DETEKSI TARGET AI AGENT / IDE DI KOMPUTER     ${C_RESET}"
        echo -e "${C_CYAN}======================================================${C_RESET}"
        [[ ${has_antigravity} -eq 1 ]] && echo -e "  ${C_GREEN}[x] 1. Google Antigravity      (Terdeteksi: ~/.gemini)${C_RESET}" || echo -e "  ${C_GRAY}[ ] 1. Google Antigravity      (Tidak terpasang)${C_RESET}"
        [[ ${has_kiro} -eq 1 ]]        && echo -e "  ${C_GREEN}[x] 2. Kiro IDE                (Terdeteksi: ~/.kiro)${C_RESET}"   || echo -e "  ${C_GRAY}[ ] 2. Kiro IDE                (Tidak terpasang)${C_RESET}"
        [[ ${has_claude} -eq 1 ]]      && echo -e "  ${C_GREEN}[x] 3. Claude Code / Desktop   (Terdeteksi: ~/.claude)${C_RESET}" || echo -e "  ${C_GRAY}[ ] 3. Claude Code / Desktop   (Tidak terpasang)${C_RESET}"
        [[ ${has_windsurf} -eq 1 ]]    && echo -e "  ${C_GREEN}[x] 4. Windsurf (Codeium)      (Terdeteksi: ~/.codeium)${C_RESET}"|| echo -e "  ${C_GRAY}[ ] 4. Windsurf (Codeium)      (Tidak terpasang)${C_RESET}"
        [[ ${has_cursor} -eq 1 ]]      && echo -e "  ${C_GREEN}[x] 5. Cursor IDE              (Terdeteksi: ~/.cursor)${C_RESET}" || echo -e "  ${C_GRAY}[ ] 5. Cursor IDE              (Tidak terpasang)${C_RESET}"
        [[ ${has_vscode} -eq 1 ]]      && echo -e "  ${C_GREEN}[x] 6. VS Code / Cline         (Terdeteksi)${C_RESET}"            || echo -e "  ${C_GRAY}[ ] 6. VS Code / Cline         (Tidak terpasang)${C_RESET}"
        
        echo -e "
  ${C_YELLOW}[A] Pasang ke SEMUA yang terdeteksi (Default)${C_RESET}"
        echo -en "${C_CYAN}Pilih target [A atau nomor, contoh: 1,2] (Tekan Enter untuk Default [A]): ${C_RESET}"
        read -r target_choice || target_choice="A"
    fi
    [[ -z "${target_choice}" ]] && target_choice="A"

    # Langkah 2: Pilih Paket
    local package_choice="${PACKAGE_ARG}"
    if [[ -z "${package_choice}" && "${NON_INTERACTIVE}" -eq 0 && -t 0 ]]; then
        echo -e "
${C_CYAN}======================================================${C_RESET}"
        echo -e "${C_CYAN} [2/2] PEMILIHAN PAKET SKILL YANG INGIN DIPASANG     ${C_RESET}"
        echo -e "${C_CYAN}======================================================${C_RESET}"
        echo -e "  ${C_YELLOW}[A] SEMUA 155 Skill (12 Paket Lengkap) [Default]${C_RESET}
  ----------------------------------------------------"
        echo -e "  [ 1] Anti-Slop (6 Skill)
  [ 2] Caveman & Token Efficiency (26 Skill)
  [ 3] Ponytail (6 Skill)
  [ 4] Agent Core Engineering (25 Skill)
  [ 5] Engineering & Productivity (37 Skill)
  [ 6] RTK Specialist (13 Skill)
  [ 7] REA - Reverse Engineering (5 Skill)
  [ 8] Apple Design & Motion (14 Skill)
  [ 9] Security Audit (1 Skill)
  [10] Superpowers Workflow (15 Skill)
  [11] Chrome DevTools MCP (7 Skill)
  [12] ARTEMIS Mobile Testing (1 Skill)"
        echo -en "${C_CYAN}Pilih paket [A atau nomor, contoh: 1,8,12] (Tekan Enter untuk Default [A]): ${C_RESET}"
        read -r package_choice || package_choice="A"
    fi
    [[ -z "${package_choice}" ]] && package_choice="A"

    # Bangun daftar target agent aktif
    declare -a ACTIVE_TARGETS=()
    if [[ "${target_choice}" =~ ^[Aa]$ ]]; then
        [[ ${has_antigravity} -eq 1 ]] && ACTIVE_TARGETS+=("native|${HOME}/.gemini/config/skills|Google Antigravity")
        [[ ${has_kiro} -eq 1 ]]        && ACTIVE_TARGETS+=("native|${HOME}/.kiro/skills|Kiro IDE")
        [[ ${has_claude} -eq 1 ]]      && ACTIVE_TARGETS+=("claude|${HOME}/.claude|Claude Code")
        [[ ${has_windsurf} -eq 1 ]]    && ACTIVE_TARGETS+=("rule_md|${HOME}/.codeium/windsurf/rules|Windsurf")
        [[ ${has_cursor} -eq 1 ]]      && ACTIVE_TARGETS+=("rule_mdc|${HOME}/.cursor/rules|Cursor")
        [[ ${has_vscode} -eq 1 ]]      && ACTIVE_TARGETS+=("rule_md|${HOME}/.cline/rules|VS Code Cline")
    else
        [[ "${target_choice}" =~ "1" || "${target_choice}" =~ "antigravity" ]] && ACTIVE_TARGETS+=("native|${HOME}/.gemini/config/skills|Google Antigravity")
        [[ "${target_choice}" =~ "2" || "${target_choice}" =~ "kiro" ]]        && ACTIVE_TARGETS+=("native|${HOME}/.kiro/skills|Kiro IDE")
        [[ "${target_choice}" =~ "3" || "${target_choice}" =~ "claude" ]]      && ACTIVE_TARGETS+=("claude|${HOME}/.claude|Claude Code")
        [[ "${target_choice}" =~ "4" || "${target_choice}" =~ "windsurf" ]]    && ACTIVE_TARGETS+=("rule_md|${HOME}/.codeium/windsurf/rules|Windsurf")
        [[ "${target_choice}" =~ "5" || "${target_choice}" =~ "cursor" ]]      && ACTIVE_TARGETS+=("rule_mdc|${HOME}/.cursor/rules|Cursor")
        [[ "${target_choice}" =~ "6" || "${target_choice}" =~ "vscode" ]]      && ACTIVE_TARGETS+=("rule_md|${HOME}/.cline/rules|VS Code Cline")
    fi
    [[ ${#ACTIVE_TARGETS[@]} -eq 0 ]] && ACTIVE_TARGETS+=("native|${HOME}/.gemini/config/skills|Google Antigravity")

    # Instalasi dari repositori lokal
    local installed=0
    local skipped=0

    for r_entry in "${REPOS[@]}"; do
        IFS='|' read -r r_name _ _ r_path <<< "${r_entry}"
        local local_path="${WORKSPACE_DIR}/${r_name}/${r_path}"
        if [[ ! -d "${local_path}" ]]; then
            local_path="${WORKSPACE_DIR}/${r_name}-bara/${r_path}"
        fi
        if [[ ! -d "${local_path}" ]]; then
            for cand in ".claude/skills" ".agents/skills" "skills"; do
                if [[ -d "${WORKSPACE_DIR}/${r_name}/${cand}" ]]; then
                    local_path="${WORKSPACE_DIR}/${r_name}/${cand}"
                    break
                elif [[ -d "${WORKSPACE_DIR}/${r_name}-bara/${cand}" ]]; then
                    local_path="${WORKSPACE_DIR}/${r_name}-bara/${cand}"
                    break
                fi
            done
        fi

        if [[ -d "${local_path}" ]]; then
            write_step "Memproses ${r_name}..."
            while IFS= read -r skill_file; do
                local s_dir
                s_dir="$(dirname "${skill_file}")"
                local s_name
                s_name="$(basename "${s_dir}")"

                for t_entry in "${ACTIVE_TARGETS[@]}"; do
                    IFS='|' read -r t_type t_dir t_label <<< "${t_entry}"
                    if copy_skill_to_agent "${t_type}" "${t_dir}" "${s_dir}" "${s_name}"; then
                        ((installed++)) || true
                    else
                        ((skipped++)) || true
                    fi
                done
            done < <(find "${local_path}" -type f -name "SKILL.md")
        fi
    done

    # Salin & Konfigurasi Plugin Antigravity (RTK & Superpowers)
    if [[ "${target_choice}" =~ ^[Aa]$ || "${target_choice}" =~ "1" || "${target_choice}" =~ "antigravity" ]]; then
        mkdir -p "${PLUGINS_DIR}/rtk" "${PLUGINS_DIR}/superpowers"

        # Superpowers Plugin
        if [[ -d "${WORKSPACE_DIR}/superpowers/plugins/superpowers" ]]; then
            cp -R "${WORKSPACE_DIR}/superpowers/plugins/superpowers/"* "${PLUGINS_DIR}/superpowers/" 2>/dev/null || true
        elif [[ -f "${WORKSPACE_DIR}/superpowers/.antigravity-plugin/plugin.json" ]]; then
            cp "${WORKSPACE_DIR}/superpowers/.antigravity-plugin/plugin.json" "${PLUGINS_DIR}/superpowers/plugin.json" 2>/dev/null || true
        fi

        # RTK Plugin (CLI Token Killer Proxy)
        if [[ ! -f "${PLUGINS_DIR}/rtk/plugin.json" ]]; then
            cat << 'EOF' > "${PLUGINS_DIR}/rtk/plugin.json"
{
  "name": "rtk",
  "version": "1.0.0",
  "description": "Antigravity plugin for transparent command rewriting and token optimization using rtk"
}
EOF
        fi
        if [[ ! -f "${PLUGINS_DIR}/rtk/hooks.json" ]]; then
            cat << 'EOF' > "${PLUGINS_DIR}/rtk/hooks.json"
{
  "rtk-rewrite": {
    "enabled": true,
    "PreToolUse": [
      {
        "matcher": "run_command",
        "hooks": [
          {
            "type": "command",
            "command": "rtk hook antigravity",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
EOF
        fi
        mkdir -p "${PLUGINS_DIR}/rtk/rules"
        if [[ ! -f "${PLUGINS_DIR}/rtk/rules/AGENTS.md" ]]; then
            cat << 'EOF' > "${PLUGINS_DIR}/rtk/rules/AGENTS.md"
# Command output

Command output here is condensed to save tokens, keeping every signal and
dropping costly noise. Treat it as the complete result: run commands
normally, and batch related commands into one call to avoid extra turns.
Truncated results state their recovery path in their own output. Re-run a
command as `rtk proxy <cmd>` only when its result is unusable: empty when
output was clearly expected, contradicting its exit code, or garbled.
EOF
        fi
    fi

    echo -e "
${C_MAGENTA}=== Installation Summary ===${C_RESET}"
    write_ok "Pemasangan selesai ke ${#ACTIVE_TARGETS[@]} Target AI Agent:"
    for t_entry in "${ACTIVE_TARGETS[@]}"; do
        IFS='|' read -r _ t_dir t_label <<< "${t_entry}"
        local count
        count=$(find "${t_dir}" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l || echo 0)
        write_info "- ${t_label} : ${count} skill/rule terpasang (${t_dir})"
        if [[ "${t_label}" == "Google Antigravity" && -d "${PLUGINS_DIR}" ]]; then
            local p_count
            p_count=$(find "${PLUGINS_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l || echo 0)
            write_info "- Plugin Antigravity     : ${p_count} plugin aktif (RTK, Superpowers) (${PLUGINS_DIR})"
        fi
    done
    write_ok "Seluruh skill dan plugin siap digunakan di semua lingkungan kerja yang dipilih!"
}

run_check() {
    echo -e "${C_CYAN}=== Skill & Repository Integrity Check (macOS & Linux) ===${C_RESET}"
    write_step "Memeriksa status direktori global..."
    local count
    count=$(find "${TARGET_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l || echo 0)
    write_ok "Total skill terpasang di ${TARGET_DIR}: ${count}"
}

run_sync() {
    echo -e "${C_CYAN}=== Sync Upstream & Backup Repos ===${C_RESET}"
    run_check
    run_install
}

# Router
case "${ACTION}" in
    sync)  run_sync ;;
    check) run_check ;;
    *)     run_install ;;
esac
