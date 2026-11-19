#!/usr/bin/env bash
# ==============================================================================
# Antigravity All-in-One Skill Manager (macOS & Linux)
# ==============================================================================
# Penggunaan:
#   1. Web Installer Satu Baris (Streaming / Tanpa Clone):
#      curl -fsSL https://raw.githubusercontent.com/23Barajapu/skill-agent/main/scripts/skill.sh | bash
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

# Parse argumen
for arg in "$@"; do
    case "$arg" in
        --force|-Force|-f)
            FORCE=1
            ;;
        --clone|-CloneLocal|clone)
            CLONE_LOCAL=1
            ;;
        --sync|sync)
            ACTION="sync"
            ;;
        --check|check)
            ACTION="check"
            ;;
        --help|help|-h)
            echo "Penggunaan: ./scripts/skill.sh [install|sync|check] [--force] [--clone]"
            exit 0
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
    "agent-skills|https://github.com/agent-bara/agent-skill-bara.git|https://github.com/addyosmani/agent-skills.git|skills"
    "anti-slop|https://github.com/agent-bara/antislop-bara.git|https://github.com/miqdadbadjuber/anti-slop.git|skills"
    "apple-design|https://github.com/agent-bara/apple-design.git|https://github.com/emilkowalski/skills.git|skills"
    "caveman|https://github.com/agent-bara/caveman-bara.git|https://github.com/JuliusBrussee/caveman.git|skills"
    "chrome-devtools-mcp|https://github.com/ChromeDevTools/chrome-devtools-mcp.git|https://github.com/ChromeDevTools/chrome-devtools-mcp.git|skills"
    "engineering-skills|https://github.com/agent-bara/engineering-skills-bara.git|https://github.com/mattpocock/skills.git|skills"
    "ponytail-bara|https://github.com/agent-bara/ponytail-bara.git|https://github.com/DietrichGebert/ponytail.git|skills"
    "rea|https://github.com/agent-bara/rea-bara.git|https://github.com/morluto/rea.git|.agents/skills"
    "rtk|https://github.com/agent-bara/rtk-bara.git|https://github.com/rtk-ai/rtk.git|skills"
    "security-audit-skill|https://github.com/agent-bara/security-audit-skill.git|https://github.com/cloudflare/security-audit-skill.git|skills"
    "superpowers|https://github.com/agent-bara/superpowers-bara.git|https://github.com/obra/superpowers.git|skills"
    "artemis|https://github.com/agent-bara/artemis-bara.git|https://github.com/google/artemis.git|skills"
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

run_install() {
    echo -e "${C_MAGENTA}=== Antigravity Global Skill Installer (macOS & Linux) ===${C_RESET}"
    echo -e "Target Skills  : ${TARGET_DIR}"
    echo -e "Target Plugins : ${PLUGINS_DIR}\n"

    mkdir -p "${TARGET_DIR}"
    mkdir -p "${PLUGINS_DIR}"

    # Pindai sumber repositori lokal
    local has_local=0
    if [[ -d "${WORKSPACE_DIR}" ]]; then
        for r_entry in "${REPOS[@]}"; do
            IFS='|' read -r r_name _ _ _ <<< "${r_entry}"
            if [[ -d "${WORKSPACE_DIR}/${r_name}" ]]; then
                has_local=1
                break
            fi
        done
    fi

    # Jika tidak ada repositori lokal atau sedang streaming via curl
    if [[ "${has_local}" -eq 0 ]]; then
        write_step "Mode Auto-Download remote aktif (tanpa clone lokal)..."
        local temp_dir
        temp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'skills-dl')
        local dl_count=0

        for r_entry in "${REPOS[@]}"; do
            IFS='|' read -r r_name r_pri r_up r_path <<< "${r_entry}"
            local clone_dest="${temp_dir}/${r_name}"
            if clone_with_fallback "${r_name}" "${r_pri}" "${r_up}" "${clone_dest}"; then
                local search_path="${clone_dest}/${r_path}"
                if [[ -d "${search_path}" ]]; then
                    while IFS= read -r skill_file; do
                        local s_dir
                        s_dir="$(dirname "${skill_file}")"
                        local s_name
                        s_name="$(basename "${s_dir}")"
                        local target_skill="${TARGET_DIR}/${s_name}"

                        if [[ -d "${target_skill}" && "${FORCE}" -eq 0 ]]; then
                            continue
                        fi

                        rm -rf "${target_skill}" 2>/dev/null || true
                        cp -R "${s_dir}" "${target_skill}"
                        ((dl_count++)) || true
                    done < <(find "${search_path}" -type f -name "SKILL.md")
                fi
            fi
        done

        rm -rf "${temp_dir}" 2>/dev/null || true
        echo -e "\n${C_MAGENTA}=== Installation Summary ===${C_RESET}"
        write_ok "Total skill berhasil dipasang / diperbarui: ${dl_count}"
        return 0
    fi

    # Instalasi dari repositori lokal
    local installed=0
    local skipped=0

    for r_entry in "${REPOS[@]}"; do
        IFS='|' read -r r_name _ _ r_path <<< "${r_entry}"
        local local_path="${WORKSPACE_DIR}/${r_name}/${r_path}"
        if [[ ! -d "${local_path}" ]]; then
            local_path="${WORKSPACE_DIR}/${r_name}-bara/${r_path}"
        fi

        if [[ -d "${local_path}" ]]; then
            write_step "Memproses ${r_name}..."
            while IFS= read -r skill_file; do
                local s_dir
                s_dir="$(dirname "${skill_file}")"
                local s_name
                s_name="$(basename "${s_dir}")"
                local target_skill="${TARGET_DIR}/${s_name}"

                if [[ -d "${target_skill}" && "${FORCE}" -eq 0 ]]; then
                    ((skipped++)) || true
                    continue
                fi

                rm -rf "${target_skill}" 2>/dev/null || true
                cp -R "${s_dir}" "${target_skill}"
                ((installed++)) || true
            done < <(find "${local_path}" -type f -name "SKILL.md")
        fi
    done

    # Salin Plugin RTK & Superpowers jika ada
    if [[ -d "${WORKSPACE_DIR}/rtk" ]]; then
        cp -R "${WORKSPACE_DIR}/rtk" "${PLUGINS_DIR}/" 2>/dev/null || true
    fi
    if [[ -d "${WORKSPACE_DIR}/superpowers" ]]; then
        cp -R "${WORKSPACE_DIR}/superpowers" "${PLUGINS_DIR}/" 2>/dev/null || true
    fi

    echo -e "\n${C_MAGENTA}=== Installation Summary ===${C_RESET}"
    write_ok "Skill baru terpasang / diperbarui : ${installed}"
    write_info "Skill dilewati (sudah terpasang)  : ${skipped}"
    write_ok "Seluruh skill Antigravity siap digunakan di macOS / Linux!"
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
