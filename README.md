# 🚀 Skill Agent — Google Antigravity Skill & Plugin Suite

> Repositori resmi installer, pengelola, dan sinkronisasi otomatis seluruh **155 Skill Unik** dan **2 Plugin Lifecycle** untuk **Google Antigravity** di lintas sistem operasi (**Windows, macOS, dan Linux**).

[![OS: Windows](https://img.shields.io/badge/OS-Windows-0078D6?logo=windows&logoColor=white)](#-1-windows)
[![OS: macOS](https://img.shields.io/badge/OS-macOS-000000?logo=apple&logoColor=white)](#-2-macos)
[![OS: Linux](https://img.shields.io/badge/OS-Linux-FCC624?logo=linux&logoColor=black)](#-3-linux)
[![Skills: 155](https://img.shields.io/badge/Skills-155%20Installed-brightgreen)](#-paket-skill-yang-tersedia)
[![Plugins: 2](https://img.shields.io/badge/Plugins-RTK%20%26%20Superpowers-blue)](#-plugin-antigravity)

---

## 📑 Daftar Isi
1. [Fitur Utama](#-fitur-utama)
2. [Lokasi Konfigurasi Global Antigravity (3 OS)](#-lokasi-konfigurasi-global-antigravity-3-os)
3. [Panduan Instalasi (Windows, macOS, Linux)](#-panduan-instalasi-3-os)
   - [1. Windows](#1-windows)
   - [2. macOS](#2-macos)
   - [3. Linux](#3-linux)
4. [Opsi & Parameter Instalasi](#-opsi--parameter-instalasi)
5. [Sinkronisasi Berkala (Sync Upstream)](#-sinkronisasi-berkala-sync)
6. [Paket Skill yang Tersedia (12 Paket)](#-paket-skill-yang-tersedia)
7. [Dokumentasi Lengkap](#-dokumentasi-lengkap)

---

## ✨ Fitur Utama

- **Dual-Mode Installer (Offline & Auto-Download)**:
  - **Mode Cepat / Offline**: Jika folder repositori lokal sudah ada, installer langsung menyalinnya secara instan tanpa membutuhkan koneksi internet.
  - **Mode Auto-Download**: Jika folder lokal belum ada (misal di PC baru yang baru saja meng-clone repositori ini), installer secara otomatis mengunduh seluruh 155 skill dan plugin langsung dari GitHub ke Antigravity.
- **Dukungan Penuh 3 OS**: Skrip siap pakai untuk Windows (`.bat` / `.ps1`) serta macOS dan Linux (`.sh`).
- **Progressive Disclosure**: Instruksi skill dimuat secara *on-demand* saat dibutuhkan oleh agen AI, menjaga kuota token percakapan tetap hemat.
- **Validasi Frontmatter Otomatis**: Memastikan header `name:` dan `description:` pada setiap `SKILL.md` valid dan sesuai standar Google Antigravity.

---

## 📂 Lokasi Konfigurasi Global Antigravity (3 OS)

Seluruh skill dan plugin akan dipasang secara universal ke direktori konfigurasi global Antigravity pada masing-masing OS:

| Sistem Operasi | Direktori Skills Global | Direktori Plugins Global |
| :--- | :--- | :--- |
| **🪟 Windows** | `%USERPROFILE%\.gemini\config\skills\`<br>`(C:\Users\<User>\.gemini\config\skills\)` | `%USERPROFILE%\.gemini\config\plugins\`<br>`(C:\Users\<User>\.gemini\config\plugins\)` |
| **🍎 macOS** | `~/.gemini/config/skills/`<br>`(/Users/<user>/.gemini/config/skills/)` | `~/.gemini/config/plugins/`<br>`(/Users/<user>/.gemini/config/plugins/)` |
| **🐧 Linux** | `~/.gemini/config/skills/`<br>`(/home/<user>/.gemini/config/skills/)` | `~/.gemini/config/plugins/`<br>`(/home/<user>/.gemini/config/plugins/)` |

---

## 💻 Panduan Instalasi (3 OS)

Pilih instruksi instalasi sesuai sistem operasi yang Anda gunakan di bawah ini:

### 1. Windows

Tersedia dua opsi cara instalasi yang sangat mudah di Windows:

#### Opsi A: Menggunakan File Batch (Paling Praktis)
1. Buka **Command Prompt (CMD)** atau klik ganda langsung pada berkas:
   ```cmd
   git clone https://github.com/23Barajapu/skill-agent.git
   cd skill-agent
   install-skills.bat
   ```
2. Jika ingin memasang ulang seluruh skill secara paksa:
   ```cmd
   install-skills.bat force
   ```
3. Jika ingin sekaligus mengkloning ke-11 repositori ke folder kerja lokal Anda:
   ```cmd
   install-skills.bat clone
   ```

#### Opsi B: Menggunakan PowerShell
Buka **PowerShell** dan jalankan:
```powershell
git clone https://github.com/23Barajapu/skill-agent.git
cd skill-agent
powershell -ExecutionPolicy Bypass -File .\install-global-skills.ps1
```
*Opsi tambahan:*
- Pasang ulang paksa: `.\install-global-skills.ps1 -Force`
- Simpan repositori ke lokal: `.\install-global-skills.ps1 -CloneLocal`

---

### 2. macOS

Di terminal macOS (zsh atau bash), jalankan perintah berikut:

```bash
# 1. Clone repositori installer
git clone https://github.com/23Barajapu/skill-agent.git
cd skill-agent

# 2. Berikan izin eksekusi skrip
chmod +x install-skills.sh

# 3. Jalankan instalasi
./install-skills.sh
```

*Opsi tambahan di macOS:*
- Pasang ulang paksa: `./install-skills.sh --force`
- Simpan repositori ke lokal: `./install-skills.sh --clone`

---

### 3. Linux

Dapat dijalankan di semua distribusi Linux (Ubuntu, Debian, Fedora, Arch, Alpine, dll.):

```bash
# 1. Pastikan git dan curl/bash terpasang
sudo apt update && sudo apt install -y git   # Untuk Ubuntu / Debian
# sudo dnf install -y git                    # Untuk Fedora / RHEL
# sudo pacman -S git                         # Untuk Arch Linux

# 2. Clone repositori installer
git clone https://github.com/23Barajapu/skill-agent.git
cd skill-agent

# 3. Berikan izin eksekusi skrip
chmod +x install-skills.sh

# 4. Jalankan instalasi
./install-skills.sh
```

*Opsi tambahan di Linux:*
- Pasang ulang paksa: `./install-skills.sh --force`
- Simpan repositori ke lokal: `./install-skills.sh --clone`

---

## ⚙️ Opsi & Parameter Instalasi

Installer mendukung beberapa parameter untuk kebutuhan fleksibel:

| Parameter (Windows) | Parameter (macOS / Linux) | Fungsi / Kegunaan |
| :--- | :--- | :--- |
| *(tanpa argumen)* | *(tanpa argumen)* | Memasang skill baru. Jika sudah terpasang, akan dilewati agar instan. Jika folder lokal belum ada, otomatis mengunduh dari GitHub. |
| `-Force` / `force` | `--force` / `-f` | Memasang ulang dan menimpa (*overwrite*) seluruh berkas skill yang sudah ada. |
| `-CloneLocal` / `clone` | `--clone` | Mengunduh dan mengkloning seluruh repositori Git ke folder kerja lokal saat ini, lalu memasangnya ke Antigravity. |
| `-TargetDir <path>` | *(ubah variabel `TARGET_DIR`)* | Mengubah folder tujuan instalasi (berguna untuk lingkungan testing atau profil kustom). |

---

## 🔄 Sinkronisasi Berkala (Sync)

Jika Anda ingin memperbarui skill dengan rilis upstream terbaru dari GitHub, jalankan launcher sinkronisasi:

- **Windows**:
  ```cmd
  sync-skills.bat
  ```
  *Hanya download & merge lokal tanpa push:*
  ```cmd
  sync-skills.bat nopush
  ```
- **macOS & Linux**:
  ```bash
  pwsh -File sync-skills.ps1 -SkipPush -SkipOrgCheck
  ```

---

## 📦 Paket Skill yang Tersedia

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
| **Paket 10** | **Multi-Agent & Orchestration** | 1 Skill | Integrasi dan protokol komunikasi antar agen asisten otonom Hermes. |
| **Paket 11** | **Superpowers Agentic Workflow** | 15 Skill | Metodologi rekayasa agen (brainstorming, spec-first, TDD ketat, git worktree, delegasi paralel). |
| **Paket 12** | **Chrome DevTools & Browser Automation** | 7 Skill | Otomasi browser via MCP, audit aksesibilitas (a11y), profil LCP/Core Web Vitals, dan memory leak. |
| **TOTAL** | | **155 Skill** | **12 Repositori Terkurasi** |

---

## 🔌 Plugin Antigravity

Selain skill, repositori ini menyertakan 2 Plugin Antigravity:
1. **RTK Plugin (`~/.gemini/config/plugins/rtk`)**: Mencegat perintah terminal (`PreToolUse`) dan memangkas log sampah hingga 60%-90%.
2. **Superpowers Plugin (`~/.gemini/config/plugins/superpowers`)**: Mengarahkan agen pada metodologi rekayasa *spec-driven*, sub-agen paralel, dan verifikasi berbasis bukti.

---

## 📖 Dokumentasi Lengkap

Untuk panduan rinci setiap skill, deskripsi teknis, contoh prompt pemanggilan, dan mekanisme kerja plugin, silakan baca dokumentasi utama pada berkas:
👉 **[CATALOG_SKILLS_DAN_PLUGIN.md](CATALOG_SKILLS_DAN_PLUGIN.md)**

---

## 📄 Lisensi & Kontributor

Seluruh skill dan plugin dikompilasi dari proyek sumber terbuka terbaik oleh komunitas agentic software engineering (`addyosmani`, `obra`, `emilkowalski`, `mattpocock`, `rtk-ai`, `ChromeDevTools`, dll.). Dilisensikan di bawah lisensi MIT / masing-masing upstream.

