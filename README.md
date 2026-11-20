# Skill Suite Sch — Universal AI Agent & Skill Suite Installer

> Repositori resmi installer dan pengelola seluruh **164+ Skill Unik** dan **2 Plugin Lifecycle** untuk **Google Antigravity, Kiro IDE, Claude Code, Cursor, Windsurf, dan VS Code** di lintas sistem operasi (**Windows, macOS, dan Linux**).

[![OS: Windows](https://img.shields.io/badge/OS-Windows-0078D6?logo=windows&logoColor=white)](#1-windows-powershell)
[![OS: macOS](https://img.shields.io/badge/OS-macOS-000000?logo=apple&logoColor=white)](#2-macos-terminal)
[![OS: Linux](https://img.shields.io/badge/OS-Linux-FCC624?logo=linux&logoColor=black)](#3-linux-terminal)
[![Skills: 164+](https://img.shields.io/badge/Skills-164%2B%20Available-brightgreen)](#-paket-skill-yang-tersedia-12-paket)
[![Packages: 12 Modules](https://img.shields.io/badge/Packages-12%20Modules-blueviolet)](#-paket-skill-yang-tersedia-12-paket)
[![Plugins: 2](https://img.shields.io/badge/Plugins-RTK%20%26%20Superpowers-blue)](#-plugin-ekosistem)

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
4. [Opsi dan Parameter CLI](#-opsi-dan-parameter-cli)
5. [Plugin Ekosistem](#-plugin-ekosistem)
6. [Dokumentasi Lengkap](#-dokumentasi-lengkap)
7. [Lisensi dan Kontributor](#-lisensi-dan-kontributor)

---

## 🚀 Fitur Unggulan

- **Universal Multi-Agent Support**: Mendukung otomatisasi pemasangan ke **6 lingkungan kerja agen sekaligus**: Google Antigravity, Kiro IDE, Claude Code, Cursor, Windsurf, dan VS Code / Cline.
- **Smart Environment Auto-Detection**: Secara cerdas memindai lingkungan sistem komputer untuk menemukan AI Agent mana saja yang aktif dan siap dipasangi skill.
- **Interactive Package Selector with Safe Default**: Pengguna dapat memilih untuk memasang paket tertentu saja atau seluruh **164+ skill** hanya dengan menekan tombol **Enter** (tanpa perlu mengetik ulang).
- **Progressive Disclosure & Token Efficiency**: Konten skill dimuat secara *on-demand*, memangkas pemborosan token konteks pada model AI hingga 90%.
- **Zero-Dependency Installation**: Skrip instalasi bekerja langsung menggunakan PowerShell bawaan Windows atau Bash bawaan macOS/Linux tanpa memerlukan dependensi runtime tambahan.

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
| **4** | **Agent Core Engineering** | 26 Skill | Desain API stabil, TDD, audit keamanan OWASP, penanganan bug sistematis, dan CI/CD pipeline. |
| **5** | **Engineering & Productivity** | 39 Skill | Praktik rekayasa Matt Pocock: TDD, safe refactor, lean build, triage issue/PR, dan migrasi tipe. |
| **6** | **RTK Specialist** | 13 Skill | CLI token killer proxy, TDD Rust, eliminasi output log terminal redundan hingga 90%. |
| **7** | **REA - Reverse Engineering Anything** | 5 Skill | Rekayasa balik biner native, aplikasi Electron, runtime browser, dan pembuatan AgentEnv. |
| **8** | **Apple Design & Motion** | 19 Skill | Fisika fluida Apple, animasi 60/120fps, nuansa Emil Kowalski, interaksi mobile native, & Swift modern. |
| **9** | **Security Audit & Pen-Testing** | 1 Skill | Audit keamanan mendalam, deteksi celah OWASP, inspeksi API, dan pen-testing. |
| **10** | **Superpowers Workflow** | 15 Skill | Metodologi rekayasa agen (brainstorming, spec-first, TDD ketat, git worktree, delegasi sub-agen paralel). |
| **11** | **Chrome DevTools MCP** | 8 Skill | Otomasi browser via Chrome DevTools MCP, audit a11y, Core Web Vitals (LCP), dan memory leak. |
| **12** | **ARTEMIS Mobile Testing** | 1 Skill | Pengujian otomatis Android, eksplorasi UI lintas aplikasi, diagnostik Logcat, dan orkestrasi ADB multimodal. |
| **TOTAL** | | **164+ Skill** | **12 Repositori Terkurasi Lintas Domain** |

---

## 🛠 Opsi dan Parameter CLI

Jika Anda menjalankan skrip secara lokal atau ingin menyesuaikan opsi instalasi:

| Parameter Windows | Parameter macOS / Linux | Fungsi / Kegunaan |
| :--- | :--- | :--- |
| *(tanpa argumen)* | *(tanpa argumen)* | Mode interaktif: deteksi agen AI otomatis dan pemilihan paket (tekan Enter untuk Default). |
| `-Target <all\|1,2>` | `--target <all\|1,2>` | Menentukan target pemasangan spesifik (`antigravity`, `kiro`, `claude`, `windsurf`, `cursor`, `vscode`, atau `all`). |
| `-Package <all\|1,12>` | `--package <all\|1,12>` | Menentukan nomor paket skill yang dipasang (contoh: `1,6,10` atau `all`). |
| `-NonInteractive` / `-Yes` | `--yes` / `-y` | Menjalankan instalasi tanpa jeda prompt konfirmasi. |
| `-Force` | `--force` / `-f` | Menimpa (*overwrite*) seluruh berkas skill yang sudah ada dengan versi terbaru. |

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
