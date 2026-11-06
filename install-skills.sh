#!/usr/bin/env bash
# ==============================================================================
# Antigravity Global Skill Installer for macOS & Linux
# ==============================================================================
# Deskripsi:
#   Memasang seluruh 155 skill dan plugin ke direktori konfigurasi global
#   Google Antigravity (~/.gemini/config/skills & ~/.gemini/config/plugins).
#   - Jika repositori lokal tersedia: menyalin langsung secara offline & instan.
#   - Jika repositori lokal belum ada: otomatis mengunduh dari GitHub (Auto-Download).
#
# Penggunaan:
#   ./install-skills.sh              # Pasang/update skill (auto-download jika lokal belum ada)
#   ./install-skills.sh --force      # Pasang ulang seluruh skill secara paksa
#   ./install-skills.sh --clone      # Clone repositori ke workspace lokal lalu pasang
# ==============================================================================

set -euo pipefail

TARGET_DIR="${HOME}/.gemini/config/skills"
PLUGINS_DIR="${HOME}/.gemini/config/plugins"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
    esac
done

echo -e "\033[1;35m=== Antigravity Global Skill Installer (macOS & Linux) ===\033[0m"
echo -e "Direktori Workspace : ${SCRIPT_DIR}"
echo -e "Target Instalasi    : ${TARGET_DIR}\n"

# Pastikan folder target tersedia
mkdir -p "${TARGET_DIR}"
mkdir -p "${PLUGINS_DIR}"

# Daftar repositori remote
declare -a REPOS=(
    "agent-skills|https://github.com/agent-bara/agent-skill-bara.git|skills"
    "anti-slop|https://github.com/agent-bara/antislop-bara.git|skills"
    "apple-design|https://github.com/agent-bara/apple-design.git|skills"
    "caveman|https://github.com/agent-bara/caveman-bara.git|skills"
    "chrome-devtools-mcp|https://github.com/ChromeDevTools/chrome-devtools-mcp.git|skills"
    "engineering-skills|https://github.com/agent-bara/engineering-skills-bara.git|skills"
    "ponytail-bara|https://github.com/agent-bara/ponytail-bara.git|skills"
    "rea|https://github.com/agent-bara/rea-bara.git|.agents/skills"
    "rtk|https://github.com/agent-bara/rtk-bara.git|skills"
    "security-audit-skill|https://github.com/agent-bara/security-audit-skill.git|skills"
    "superpowers|https://github.com/agent-bara/superpowers-bara.git|skills"
)

# 1. Opsi --clone: Clone repositori ke direktori kerja jika diminta
if [[ ${CLONE_LOCAL} -eq 1 ]]; then
    echo -e "\033[1;36m[>>] Opsi --clone aktif: Mengkloning repositori ke direktori kerja lokal...\033[0m"
    for item in "${REPOS[@]}"; do
        IFS='|' read -r name url path <<< "${item}"
        dest="${SCRIPT_DIR}/${name}"
        if [[ ! -d "${dest}" ]]; then
            echo -e "     Cloning ${name}..."
            git clone --depth 1 --quiet "${url}" "${dest}" || echo "  [!!] Gagal clone ${name}"
        else
            echo -e "     [--] ${name} sudah ada di direktori lokal."
        fi
    done
    echo ""
fi

# 2. Periksa apakah ada folder repositori lokal di direktori kerja
LOCAL_SOURCES=()
for item in "${REPOS[@]}"; do
    IFS='|' read -r name url relpath <<< "${item}"
    local_path="${SCRIPT_DIR}/${name}/${relpath}"
    if [[ -d "${local_path}" ]]; then
        LOCAL_SOURCES+=("${name}|${local_path}")
    fi
done

# 3. Fitur Auto-Download jika folder lokal tidak ada
if [[ ${#LOCAL_SOURCES[@]} -eq 0 ]]; then
    echo -e "\033[1;33m[!!] Tidak ada folder repositori skill lokal yang ditemukan di: ${SCRIPT_DIR}\033[0m"
    echo -e "\033[1;36m[>>] Mengaktifkan fitur Auto-Download skill dari GitHub ke Antigravity...\033[0m\n"

    # Jika PowerShell Core (pwsh) tersedia dan sync-skills.ps1 ada, gunakan sync-skills.ps1
    if command -v pwsh >/dev/null 2>&1 && [[ -f "${SCRIPT_DIR}/sync-skills.ps1" ]]; then
        echo -e "Menjalankan instalasi otomatis via pwsh & sync-skills.ps1..."
        SYNC_ARGS=("-File" "${SCRIPT_DIR}/sync-skills.ps1" "-SkillFilter" "all" "-SkipPush" "-SkipOrgCheck")
        if [[ ${FORCE} -eq 1 ]]; then SYNC_ARGS+=("-Force"); fi
        pwsh "${SYNC_ARGS[@]}"
        exit 0
    fi

    # Fallback native bash git clone
    TEMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'skills-sync')
    trap 'rm -rf "${TEMP_DIR}"' EXIT

    echo -e "Mengunduh langsung dari GitHub ke folder sementara..."
    DOWNLOADED=0
    for item in "${REPOS[@]}"; do
        IFS='|' read -r name url relpath <<< "${item}"
        echo -e "\033[0;36m[>>] Mengunduh ${name}...\033[0m"
        clone_dest="${TEMP_DIR}/${name}"
        if git clone --depth 1 --quiet "${url}" "${clone_dest}" 2>/dev/null; then
            skill_base="${clone_dest}/${relpath}"
            if [[ -d "${skill_base}" ]]; then
                while IFS= read -r -d '' skill_file; do
                    skill_folder="$(dirname "${skill_file}")"
                    skill_name="$(basename "${skill_folder}")"
                    target="${TARGET_DIR}/${skill_name}"
                    if [[ -d "${target}" && ${FORCE} -eq 0 ]]; then
                        continue
                    fi
                    rm -rf "${target}"
                    cp -R "${skill_folder}" "${target}"
                    ((DOWNLOADED++)) || true
                done < <(find "${skill_base}" -name "SKILL.md" -print0)
            fi
        fi
    done

    echo -e "\n\033[1;35m=== Installation Summary ===\033[0m"
    echo -e "\033[1;32mNew skills installed : ${DOWNLOADED}\033[0m"
    echo -e "\033[1;32mSeluruh skill berhasil diunduh dan dipasang ke Google Antigravity!\033[0m"
    exit 0
fi

# 4. Instalasi dari folder lokal yang ada
INSTALLED=0
SKIPPED=0

for item in "${LOCAL_SOURCES[@]}"; do
    IFS='|' read -r name src_path <<< "${item}"
    echo -e "\033[0;36m[>>] Processing ${name}...\033[0m"

    while IFS= read -r -d '' skill_file; do
        skill_folder="$(dirname "${skill_file}")"
        skill_name="$(basename "${skill_folder}")"
        target="${TARGET_DIR}/${skill_name}"

        if [[ -d "${target}" && ${FORCE} -eq 0 ]]; then
            ((SKIPPED++)) || true
            continue
        fi

        rm -rf "${target}"
        cp -R "${skill_folder}" "${target}"

        # Perbaiki frontmatter jika tag name: belum ada
        if ! grep -q "^name:" "${target}/SKILL.md" 2>/dev/null; then
            sed -i.bak "1s/^/---\nname: ${skill_name}\n---\n/" "${target}/SKILL.md" 2>/dev/null || true
            rm -f "${target}/SKILL.md.bak"
        fi

        ((INSTALLED++)) || true
    done < <(find "${src_path}" -name "SKILL.md" -print0)
done

# Salin plugin rtk dan superpowers jika ada
if [[ -d "${SCRIPT_DIR}/rtk" ]]; then
    mkdir -p "${PLUGINS_DIR}/rtk"
    cp -R "${SCRIPT_DIR}/rtk/"* "${PLUGINS_DIR}/rtk/" 2>/dev/null || true
fi
if [[ -d "${SCRIPT_DIR}/superpowers" ]]; then
    mkdir -p "${PLUGINS_DIR}/superpowers"
    cp -R "${SCRIPT_DIR}/superpowers/"* "${PLUGINS_DIR}/superpowers/" 2>/dev/null || true
fi

echo -e "\n\033[1;35m=== Installation Summary ===\033[0m"
echo -e "\033[1;32mNew skills installed    : ${INSTALLED}\033[0m"
echo -e "\033[0;37mSkipped (already exists): ${SKIPPED}\033[0m"
if [[ ${INSTALLED} -gt 0 ]]; then
    echo -e "\033[1;32mSkill baru berhasil dipasang dan siap digunakan di Antigravity!\033[0m"
else
    echo -e "\033[1;36mSemua skill sudah terpasang. Gunakan --force jika ingin memasang ulang.\033[0m"
fi

