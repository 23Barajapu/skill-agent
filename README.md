# Skill Agent — Google Antigravity Skill & Plugin Suite

> Repositori resmi installer, pengelola, dan sinkronisasi otomatis seluruh **155 Skill Unik** dan **2 Plugin Lifecycle** untuk **Google Antigravity** di lintas sistem operasi (**Windows, macOS, dan Linux**).

[![OS: Windows](https://img.shields.io/badge/OS-Windows-0078D6?logo=windows&logoColor=white)](#1-windows-powershell)
[![OS: macOS](https://img.shields.io/badge/OS-macOS-000000?logo=apple&logoColor=white)](#2-macos-terminal)
[![OS: Linux](https://img.shields.io/badge/OS-Linux-FCC624?logo=linux&logoColor=black)](#3-linux-terminal)
[![Skills: 155](https://img.shields.io/badge/Skills-155%20Installed-brightgreen)](#paket-skill-yang-tersedia-12-paket)
[![Plugins: 2](https://img.shields.io/badge/Plugins-RTK%20%26%20Superpowers-blue)](#plugin-antigravity)

---

## Instalasi Cepat Satu Baris (Web Installer / One-Liner)

Pemasangan dapat dilakukan langsung tanpa perlu meng-clone repositori. Buka terminal pada komputer Anda dan jalankan satu baris perintah sesuai sistem operasi:

### 1. Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/23Barajapu/skill-agent/main/scripts/skill.ps1 | iex
```

### 2. macOS (Terminal)
```bash
curl -fsSL https://raw.githubusercontent.com/23Barajapu/skill-agent/main/scripts/skill.sh | bash
```

### 3. Linux (Terminal)
```bash
curl -fsSL https://raw.githubusercontent.com/23Barajapu/skill-agent/main/scripts/skill.sh | bash
```

> **Catatan**: Installer otomatis mendeteksi konfigurasi global Antigravity (`~/.gemini/config/`), mengunduh seluruh 155 skill dan 2 plugin dengan mekanisme dual-source fallback (primary org dan upstream publik), serta memvalidasi frontmatter skill secara otomatis.

---

## Daftar Isi
1. [Fitur Utama](#fitur-utama)
2. [Lokasi Konfigurasi Global Antigravity (3 OS)](#lokasi-konfigurasi-global-antigravity-3-os)
3. [Penggunaan Lokal (Bagi Pengelola / Maintainer)](#penggunaan-lokal-bagi-pengelola--maintainer)
4. [Opsi dan Parameter CLI](#opsi-dan-parameter-cli)
5. [Sinkronisasi Berkala (Sync)](#sinkronisasi-berkala-sync)
6. [Paket Skill yang Tersedia (12 Paket)](#paket-skill-yang-tersedia-12-paket)
7. [Plugin Antigravity](#plugin-antigravity)
8. [Dokumentasi Lengkap](#dokumentasi-lengkap)

---

## Fitur Utama

- **One-Liner Web Streaming (`irm` / `curl`)**: Pemasangan instan di perangkat mana pun tanpa perlu dependensi atau clone manual.
- **Root Repositori Bersih (Zero-Script in Root)**: Seluruh file eksekusi dan engine modular tersimpan di subdirektori `scripts/`, menjaga root repositori tetap rapi.
- **Dual-Source Fallback (Private Org & Public Upstream)**:
  - **Primary**: Mengutamakan repositori organisasi (`agent-bara/*-bara.git`) untuk kustomisasi terbaru.
  - **Fallback**: Jika repositori privat dan lingkungan belum memiliki token GitHub, installer otomatis beralih ke repositori official upstream publik (`addyosmani`, `obra`, `mattpocock`, `JuliusBrussee`, dll.).
- **Progressive Disclosure**: Konten skill hanya dimuat *on-demand* saat dibutuhkan oleh agen AI guna menghemat pemakaian token konteks.
- **Validasi Frontmatter Otomatis**: Memastikan header `name:` dan `description:` pada setiap `SKILL.md` valid dan sesuai standar Google Antigravity.

---

## Lokasi Konfigurasi Global Antigravity (3 OS)

Seluruh skill dan plugin dipasang ke direktori konfigurasi global Antigravity:

| Sistem Operasi | Direktori Skills Global | Direktori Plugins Global |
| :--- | :--- | :--- |
| **Windows** | `%USERPROFILE%\.gemini\config\skills\`<br>`(C:\Users\<User>\.gemini\config\skills\)` | `%USERPROFILE%\.gemini\config\plugins\`<br>`(C:\Users\<User>\.gemini\config\plugins\)` |
| **macOS** | `~/.gemini/config/skills/`<br>`(/Users/<user>/.gemini/config/skills/)` | `~/.gemini/config/plugins/`<br>`(/Users/<user>/.gemini/config/plugins/)` |
| **Linux** | `~/.gemini/config/skills/`<br>`(/home/<user>/.gemini/config/skills/)` | `~/.gemini/config/plugins/`<br>`(/home/<user>/.gemini/config/plugins/)` |

---

## Penggunaan Lokal (Bagi Pengelola / Maintainer)

Jika Anda meng-clone repositori ini ke komputer lokal untuk mengelola atau mengembangkan skill:

```bash
git clone https://github.com/23Barajapu/skill-agent.git
cd skill-agent
```

### Windows (PowerShell)
```powershell
# Memasang / memperbarui skill ke global:
powershell -ExecutionPolicy Bypass -File .\scripts\skill.ps1

# Memasang ulang secara paksa (overwrite):
powershell -ExecutionPolicy Bypass -File .\scripts\skill.ps1 -Force

# Audit integritas dan pemetaan skill:
powershell -ExecutionPolicy Bypass -File .\scripts\skill.ps1 -Check

# Sinkronisasi update upstream dan push ke backup repo:
powershell -ExecutionPolicy Bypass -File .\scripts\skill.ps1 -Sync
```

### macOS & Linux (Bash)
```bash
# Berikan izin eksekusi skrip jika belum:
chmod +x ./scripts/skill.sh

# Memasang / memperbarui skill:
./scripts/skill.sh

# Memasang ulang paksa:
./scripts/skill.sh --force

# Audit integritas skill:
./scripts/skill.sh --check

# Sinkronisasi repositori:
./scripts/skill.sh --sync
```

---

## Opsi dan Parameter CLI

| Parameter Windows | Parameter macOS / Linux | Fungsi / Kegunaan |
| :--- | :--- | :--- |
| *(tanpa argumen)* | *(tanpa argumen)* | Mode instalasi default: memasang skill baru, melewati yang sudah ada, auto-download jika folder lokal belum ada. |
| `-Force` | `--force` / `-f` | Menimpa (*overwrite*) seluruh berkas skill yang sudah ada. |
| `-CloneLocal` | `--clone` | Mengkloning seluruh repositori Git ke folder kerja lokal saat ini. |
| `-Check` | `--check` | Memeriksa integritas pemetaan `$SKILL_MAP` dan repositori lokal. |
| `-Sync` | `--sync` | Melakukan git pull dari upstream dan git push ke backup repository. |

---

## Sinkronisasi Berkala (Sync)

### Gerbang Otomatisasi Cloud (GitHub Actions Gateway)
Repositori ini menyediakan gerbang otomatisasi resmi di cloud melalui GitHub Actions (`.github/workflows/sync-skills.yml`):
- **Otomatis Terjadwal**: Berjalan setiap hari Minggu pukul 00:00 UTC (07:00 WIB) untuk menarik pembaruan upstream.
- **Manual (On-Demand)**: Dapat dipicu kapan saja melalui tab **Actions** -> **Sync Skills Gateway** -> **Run workflow**.
- **Bebas Notifikasi CI Gagal**: Seluruh folder `.github/workflows` upstream telah dibersihkan secara permanen dari repositori backup `agent-bara/*-bara`.

---

## Paket Skill yang Tersedia (12 Paket)

Seluruh **155 Skill Unik** dikelompokkan ke dalam 12 paket kapabilitas:

| Paket | Nama Kategori | Jumlah | Cakupan Utama |
| :---: | :--- | :---: | :--- |
| **Paket 1** | **Anti-Slop** | 6 Skill | Desain antarmuka bersih, copywriting non-AI, aksesibilitas, & tata letak responsif. |
| **Paket 2** | **Caveman & Token Efficiency** | 26 Skill | Komunikasi ultra-ringkas, kompresi konteks, metrik token, dan analisis arsitektur graphify. |
| **Paket 3** | **Ponytail** | 6 Skill | Solusi koding pragmatis minimalis, audit bloatware, dan pencegahan over-engineering. |
| **Paket 4** | **Agent Core Engineering** | 25 Skill | Desain API stabil, TDD, audit keamanan OWASP, penanganan bug sistematis, dan CI/CD. |
| **Paket 5** | **Engineering & Productivity** | 37 Skill | Praktik rekayasa Matt Pocock: TDD, safe refactor, lean build, triage issue/PR, dan migrasi tipe. |
| **Paket 6** | **RTK Specialist** | 13 Skill | CLI token killer proxy, TDD Rust, eliminasi log terminal redundan hingga 90%. |
| **Paket 7** | **REA - Reverse Engineering Anything** | 5 Skill | Rekayasa balik biner native, aplikasi Electron, runtime browser, dan pembuatan AgentEnv. |
| **Paket 8** | **Apple Design, Motion & UI Polish** | 14 Skill | Fisika fluida Apple, animasi 60/120fps, nuansa Emil Kowalski, interaksi mobile native, & Swift modern. |
| **Paket 9** | **Security Audit & Pen-Testing** | 1 Skill | Audit keamanan mendalam, deteksi kerentanan OWASP, inspeksi API, dan pen-testing. |
| **Paket 10** | **Superpowers Agentic Workflow** | 15 Skill | Metodologi rekayasa agen (brainstorming, spec-first, TDD ketat, git worktree, delegasi paralel). |
| **Paket 11** | **Chrome DevTools & Browser Automation** | 7 Skill | Otomasi browser via MCP, audit aksesibilitas (a11y), profil LCP/Core Web Vitals, dan memory leak. |
| **Paket 12** | **Mobile Automation & Testing (ARTEMIS)** | 1 Skill | Pengujian otomatis Android, eksplorasi UI lintas aplikasi, diagnostik Logcat, dan orkestrasi ADB multimodal. |
| **TOTAL** | | **155 Skill** | **12 Repositori Terkurasi** |

---

## Plugin Antigravity

1. **RTK Plugin (`~/.gemini/config/plugins/rtk`)**: Mencegat perintah terminal (`PreToolUse`) dan memangkas log output hingga 60%-90%.
2. **Superpowers Plugin (`~/.gemini/config/plugins/superpowers`)**: Mengarahkan agen pada metodologi rekayasa *spec-driven*, sub-agen paralel, dan verifikasi berbasis bukti.

---

## Dokumentasi Lengkap

Untuk panduan rinci setiap skill, deskripsi teknis, contoh prompt pemanggilan, dan mekanisme kerja plugin, silakan baca dokumentasi utama pada berkas:
[CATALOG_SKILLS_DAN_PLUGIN.md](CATALOG_SKILLS_DAN_PLUGIN.md)

---

## Lisensi dan Kontributor

Seluruh skill dan plugin dikompilasi dari proyek sumber terbuka terbaik oleh komunitas agentic software engineering (`addyosmani`, `obra`, `emilkowalski`, `mattpocock`, `rtk-ai`, `ChromeDevTools`, `remotion-dev`, dll.). Dilisensikan di bawah lisensi MIT / masing-masing upstream.
