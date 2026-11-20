# Skill Suite Sch — Universal AI Agent & Skill Suite Installer

> Repositori resmi installer, pengelola, audit integritas, dan sinkronisasi otomatis seluruh **164+ Skill Unik** dan **2 Plugin Lifecycle** untuk **Google Antigravity, Kiro IDE, Claude Code, Cursor, Windsurf, dan VS Code** di lintas sistem operasi (**Windows, macOS, dan Linux**).

[![OS: Windows](https://img.shields.io/badge/OS-Windows-0078D6?logo=windows&logoColor=white)](#1-windows-powershell)
[![OS: macOS](https://img.shields.io/badge/OS-macOS-000000?logo=apple&logoColor=white)](#2-macos-terminal)
[![OS: Linux](https://img.shields.io/badge/OS-Linux-FCC624?logo=linux&logoColor=black)](#3-linux-terminal)
[![Skills: 164+](https://img.shields.io/badge/Skills-164%2B%20Available-brightgreen)](#paket-skill-yang-tersedia-12-paket)
[![Packages: 12 Modules](https://img.shields.io/badge/Packages-12%20Modules-blueviolet)](#paket-skill-yang-tersedia-12-paket)
[![Plugins: 2](https://img.shields.io/badge/Plugins-RTK%20%26%20Superpowers-blue)](#plugin-antigravity)
[![Backup Org: 18schwarz](https://img.shields.io/badge/Backup%20Org-18schwarz-orange?logo=github&logoColor=white)](#pemetaan-repositori-upstream--backup-18schwarz)

---

## ⚡ Instalasi Cepat Satu Baris (Web One-Liner)

Pemasangan dapat dilakukan langsung tanpa perlu meng-clone repositori secara manual. Buka terminal pada komputer Anda dan jalankan satu baris perintah sesuai sistem operasi:

### 1. Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/23Barajapu/skill-suite-sch/main/scripts/skill.ps1 | iex
```

### 2. macOS (Terminal)
```bash
curl -fsSL https://raw.githubusercontent.com/23Barajapu/skill-suite-sch/main/scripts/skill.sh | bash
```

### 3. Linux (Terminal)
```bash
curl -fsSL https://raw.githubusercontent.com/23Barajapu/skill-suite-sch/main/scripts/skill.sh | bash
```

> **Catatan**: Installer otomatis mendeteksi AI Agent / IDE yang terpasang, menyajikan opsi pemilihan paket skill interaktif (cukup tekan **Enter** untuk memasang seluruh paket default), dan memvalidasi kompatibilitas frontmatter skill secara instan.

---

## 📑 Daftar Isi
1. [Fitur Unggulan](#-fitur-unggulan)
2. [Target AI Agent & Direktori Konfigurasi](#-target-ai-agent--direktori-konfigurasi)
3. [Paket Skill yang Tersedia (12 Paket)](#-paket-skill-yang-tersedia-12-paket)
4. [Pemetaan Repositori Upstream & Backup (`18schwarz`)](#-pemetaan-repositori-upstream--backup-18schwarz)
5. [Penggunaan Lokal (Bagi Pengelola / Maintainer)](#-penggunaan-lokal-bagi-pengelola--maintainer)
6. [Opsi dan Parameter CLI](#-opsi-dan-parameter-cli)
7. [Mekanisme Sinkronisasi Upstream & Backup](#-mekanisme-sinkronisasi-upstream--backup)
8. [Plugin Ekosistem](#-plugin-ekosistem)
9. [Dokumentasi Lengkap](#-dokumentasi-lengkap)
10. [Lisensi dan Kontributor](#-lisensi-dan-kontributor)

---

## 🚀 Fitur Unggulan

- **Universal Multi-Agent Support**: Mendukung otomatisasi pemasangan ke **6 lingkungan kerja agen sekaligus**: Google Antigravity, Kiro IDE, Claude Code, Cursor, Windsurf, dan VS Code / Cline.
- **Smart Environment Auto-Detection**: Secara cerdas memindai lingkungan sistem komputer untuk menemukan AI Agent mana saja yang aktif dan siap dipasangi skill.
- **Interactive Package Selector with Safe Default**: Pengguna dapat memilih untuk memasang paket tertentu saja atau seluruh **164+ skill** hanya dengan menekan tombol **Enter** (tanpa perlu mengetik ulang).
- **Dual-Source Intelligent Fallback**:
  - **Primary**: Mengutamakan repositori organisasi privat Anda (`18schwarz/*`) untuk kustomisasi dan stabilitas branch lokal.
  - **Fallback**: Jika lingkungan baru belum memiliki otentikasi git, skrip otomatis beralih menarik langsung dari repositori resmi *upstream* publik (`addyosmani`, `mattpocock`, `google`, `ChromeDevTools`, dll.).
- **Zero-Conflict Upstream Sync**: Skrip sinkronisasi dilengkapi strategi `--strategy-option=theirs` dan *auto-merge* yang menjamin adopsi 100% kode asli pemiliknya tanpa merusak struktur branch `backup-lokal`.
- **Progressive Disclosure & Token Efficiency**: Konten skill dimuat secara *on-demand*, memangkas pemborosan token konteks pada model AI hingga 90%.

---

## 🎯 Target AI Agent & Direktori Konfigurasi

Installer secara otomatis menyelaraskan struktur berkas (format `SKILL.md`, `.mdc`, atau aturan rule) sesuai standar masing-masing agen:

| AI Agent / IDE | Jalur Pemasangan Konfigurasi | Format Aturan |
| :--- | :--- | :--- |
| **Google Antigravity** | `~/.gemini/config/skills/`<br>`~/.gemini/config/plugins/` | Native `SKILL.md` & Plugins |
| **Kiro IDE** | `~/.kiro/skills/` | Native `SKILL.md` |
| **Claude Code / Desktop** | `~/.claude/skills/` | Claude Agent Skill Format |
| **Windsurf (Codeium)** | `~/.codeium/windsurf/rules/` | Global Rules `.md` |
| **Cursor IDE** | `~/.cursor/rules/` | Cursor Rules `.mdc` |
| **VS Code / Cline** | `~/.cline/rules/` | Markdown Rules |

---

## 📦 Paket Skill yang Tersedia (12 Paket)

Seluruh **164+ Skill Unik** dikurasi ke dalam 12 paket fungsional:

| No | Nama Paket | Jumlah | Deskripsi & Cakupan Fungsional |
| :---: | :--- | :---: | :--- |
| **1** | **Anti-Slop** | 6 Skill | Desain antarmuka bersih, copywriting non-AI, aksesibilitas humanis, dan tata letak responsif. |
| **2** | **Caveman & Token Efficiency** | 26 Skill | Komunikasi ultra-ringkas, kompresi konteks, metrik token, dan knowledge graph code architecture. |
| **3** | **Ponytail** | 6 Skill | Koding pragmatis minimalis, audit bloatware, dan pencegahan over-engineering. |
| **4** | **Agent Core Engineering** | 25 Skill | Desain API stabil, TDD, audit keamanan OWASP, penanganan bug sistematis, dan CI/CD pipeline. |
| **5** | **Engineering & Productivity** | 37 Skill | Praktik rekayasa Matt Pocock: TDD, safe refactor, lean build, triage issue/PR, dan migrasi tipe. |
| **6** | **RTK Specialist** | 13 Skill | CLI token killer proxy, TDD Rust, eliminasi output log terminal redundan hingga 90%. |
| **7** | **REA - Reverse Engineering Anything** | 5 Skill | Rekayasa balik biner native, aplikasi Electron, runtime browser, dan pembuatan AgentEnv. |
| **8** | **Apple Design & Motion** | 14 Skill | Fisika fluida Apple, animasi 60/120fps, nuansa Emil Kowalski, interaksi mobile native, & Swift modern. |
| **9** | **Security Audit & Pen-Testing** | 1 Skill | Audit keamanan mendalam, deteksi celah OWASP, inspeksi API, dan pen-testing. |
| **10** | **Superpowers Workflow** | 15 Skill | Metodologi rekayasa agen (brainstorming, spec-first, TDD ketat, git worktree, delegasi sub-agen paralel). |
| **11** | **Chrome DevTools MCP** | 8 Skill | Otomasi browser via Chrome DevTools MCP, audit a11y, Core Web Vitals (LCP), dan memory leak. |
| **12** | **ARTEMIS Mobile Testing** | 1 Skill | Pengujian otomatis Android, eksplorasi UI lintas aplikasi, diagnostik Logcat, dan orkestrasi ADB multimodal. |
| **TOTAL** | | **164+ Skill** | **12 Repositori Terkurasi Lintas Domain** |

---

## 🔗 Pemetaan Repositori Upstream & Backup (`18schwarz`)

Seluruh sub-repositori terhubung secara dual-remote ke upstream resmi dan organisasi backup pribadi:

| Modul Sub-Repo | Upstream Resmi (Pemilik Asli) | Repositori Backup (`18schwarz`) | Branch Aktif |
| :--- | :--- | :--- | :---: |
| `agent-skills` | `https://github.com/addyosmani/agent-skills.git` | `https://github.com/18schwarz/agent-skill-sch.git` | `backup-lokal` |
| `anti-slop` | `https://github.com/miqdadbadjuber/anti-slop.git` | `https://github.com/18schwarz/antislop-sch.git` | `backup-lokal` |
| `apple-design` | `https://github.com/emilkowalski/skills.git` | `https://github.com/18schwarz/apple-design.git` | `backup-lokal` |
| `artemis` | `https://github.com/google/artemis.git` | `https://github.com/18schwarz/artemis-sch.git` | `backup-lokal` |
| `caveman` | `https://github.com/JuliusBrussee/caveman.git` | `https://github.com/18schwarz/caveman-sch.git` | `backup-lokal` |
| `chrome-devtools-mcp` | `https://github.com/ChromeDevTools/chrome-devtools-mcp.git` | `https://github.com/18schwarz/chrome-devtools-sch.git` | `backup-lokal` |
| `engineering-skills` | `https://github.com/mattpocock/skills.git` | `https://github.com/18schwarz/engineering-skills-sch.git` | `backup-lokal` |
| `ponytail-bara` | `https://github.com/DietrichGebert/ponytail.git` | `https://github.com/18schwarz/ponytail-sch.git` | `backup-lokal` |
| `rea` | `https://github.com/morluto/rea.git` | `https://github.com/18schwarz/rea-sch.git` | `backup-lokal` |
| `rtk` | `https://github.com/rtk-ai/rtk.git` (*develop*) | `https://github.com/18schwarz/rtk-sch.git` | `backup-lokal` |
| `security-audit-skill` | `https://github.com/cloudflare/security-audit-skill.git` | `https://github.com/18schwarz/security-audit-skill.git` | `backup-lokal` |
| `superpowers` | `https://github.com/obra/superpowers.git` | `https://github.com/18schwarz/superpowers-sch.git` | `backup-lokal` |

---

## 💻 Penggunaan Lokal (Bagi Pengelola / Maintainer)

Jika Anda meng-clone repositori ini ke komputer lokal untuk mengelola, mengaudit, atau menyinkronkan skill:

```bash
git clone https://github.com/23Barajapu/skill-suite-sch.git
cd skill-suite-sch
```

### Windows (PowerShell)
```powershell
# Mode interaktif (pilih target agen dan paket skill):
powershell -ExecutionPolicy Bypass -File .\scripts\skill.ps1

# Pemasangan non-interaktif cepat (semua target & semua paket default):
powershell -ExecutionPolicy Bypass -File .\scripts\skill.ps1 -NonInteractive -Yes

# Audit integritas dan pemetaan seluruh skill global:
powershell -ExecutionPolicy Bypass -File .\scripts\skill.ps1 -Check

# Sinkronisasi update dari upstream dan push otomatis ke 18schwarz:
powershell -ExecutionPolicy Bypass -File .\scripts\skill.ps1 -Sync
```

### macOS & Linux (Bash)
```bash
# Berikan izin eksekusi skrip:
chmod +x ./scripts/skill.sh

# Mode interaktif:
./scripts/skill.sh

# Pemasangan non-interaktif:
./scripts/skill.sh --yes

# Audit integritas skill:
./scripts/skill.sh --check

# Sinkronisasi repositori:
./scripts/skill.sh --sync
```

---

## 🛠 Opsi dan Parameter CLI

| Parameter Windows | Parameter macOS / Linux | Fungsi / Kegunaan |
| :--- | :--- | :--- |
| *(tanpa argumen)* | *(tanpa argumen)* | Mode interaktif: deteksi agen AI otomatis dan pemilihan paket (tekan Enter untuk Default). |
| `-Target <all\|1,2>` | `--target <all\|1,2>` | Menentukan target pemasangan spesifik (`antigravity`, `kiro`, `claude`, `windsurf`, `cursor`, `vscode`, atau `all`). |
| `-Package <all\|1,12>` | `--package <all\|1,12>` | Menentukan nomor paket skill yang dipasang (contoh: `1,6,10` atau `all`). |
| `-NonInteractive` / `-Yes` | `--yes` / `-y` | Menjalankan instalasi tanpa jeda prompt konfirmasi. |
| `-Force` | `--force` / `-f` | Menimpa (*overwrite*) seluruh berkas skill yang sudah ada. |
| `-CloneLocal` | `--clone` | Mengkloning seluruh 12 repositori Git ke folder lokal saat ini. |
| `-Check` | `--check` | Memeriksa integritas pemetaan `$SKILL_MAP` terhadap skill di komputer lokal. |
| `-Sync` | `--sync` | Melakukan penarikan upstream resmi (`git pull`) dan push ke remote `18schwarz`. |
| `-DryRun` | `--dry-run` | Menjalankan uji simulasi sinkronisasi tanpa mengubah remote git. |

---

## 🔄 Mekanisme Sinkronisasi Upstream & Backup

- **Upstream Adherence**: Memastikan branch lokal selalu mengadopsi 100% versi pembuat asli (*original owner*) tanpa modifikasi yang merusak.
- **Auto-Resolve Conflicts**: Jika terjadi konflik berkas saat `pull`, skrip secara cerdas memprioritaskan versi *upstream* (`theirs`).
- **CI Safety Guard**: Repositori privat di organisasi `18schwarz` telah dilindungi dari kegagalan eksekusi GitHub Actions atau tagihan kuota berbayar, menjaga seluruh alur sinkronisasi tetap bersih dan aman.

---

## 🔌 Plugin Ekosistem

1. **RTK Plugin (`~/.gemini/config/plugins/rtk`)**:  
   Mencegat perintah shell terminal (`PreToolUse`) dan memangkas log output berulang hingga 60%–90%, menghemat kuota konteks secara masif.
2. **Superpowers Plugin (`~/.gemini/config/plugins/superpowers`)**:  
   Mengarahkan agen AI pada metodologi rekayasa *spec-driven development*, sub-agen paralel, dan verifikasi berbasis bukti sebelum kode disetujui.

---

## 📖 Dokumentasi Lengkap

Untuk panduan mendalam setiap skill, skenario penggunaan, dan contoh prompt pemanggilan:
* [Katalog Lengkap Skill & Plugin](CATALOG_SKILLS_DAN_PLUGIN.md)
* Panduan Antigravity: `~/.gemini/antigravity/builtin/skills/antigravity_guide/SKILL.md`

---

## 📄 Lisensi dan Kontributor

Seluruh skill dan plugin dikurasi dari karya terbaik komunitas *agentic software engineering* dunia (`addyosmani`, `obra`, `emilkowalski`, `mattpocock`, `rtk-ai`, `ChromeDevTools`, `google`, `cloudflare`, dll.).  
Dilisensikan di bawah lisensi MIT / Apache 2.0 sesuai dengan lisensi masing-masing proyek *upstream*.
