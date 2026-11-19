# Sync Skills Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mengoptimalkan sinkronisasi skill Antigravity dengan memetakan seluruh skill aktif yang belum terdaftar, membersihkan broken junctions di direktori global, dan memperbarui dokumentasi katalog.

**Architecture:** Memperbarui konfigurasi `$SKILL_MAP` pada `sync-skills.ps1` untuk menyertakan prefix yang terlewat, membersihkan junction link usang di Windows FS, dan memperbarui dokumentasi Markdown agar konsisten dengan ekosistem lokal.

**Tech Stack:** PowerShell 5.1+, Git, Markdown, Windows NTFS Junctions.

**Spec:** [docs/superpowers/specs/2026-11-19-sync-skills-optimization-design.md](file:///c:/laragon/www/agent/docs/superpowers/specs/2026-11-19-sync-skills-optimization-design.md)

## Global Constraints

- Wajib menggunakan Bahasa Indonesia untuk seluruh dokumentasi dan catatan komit.
- Tidak menghapus repositori eksternal non-skill (`artemis`, `markitdown`, `awesome-design-md`).
- Menjaga kompatibilitas sintaks skrip PowerShell (`sync-skills.ps1`).

## Review Focus

1. Penambahan `rtk` ke `local_skill_prefixes` entri `rtk`: memastikan tidak ada duplikasi atau konflik prefix.
2. Penambahan 6 skill `caveman` (`graphify`, `quality-control`, `bahasa-indonesia`, `cave`, `megacave`, `ultracave`): memastikan folder lokal terbaca saat check sync.
3. Pembersihan 13 junction Remotion: memastikan hanya junction link rusak yang dihapus tanpa menyentuh skill `remotion-new-markup` atau skill lainnya yang valid.
4. Folder kosong `skills/`: memastikan penghapusan folder kosong tidak memengaruhi git working tree.
5. Verifikasi `sync-skills.ps1 -CheckOnly`: memastikan output menunjukkan semua skill dan repositori 100% sinkron.

---

### Task 1: Daftarkan 7 Skill Aktif di sync-skills.ps1

**Files:**
- Modify: `c:/laragon/www/agent/sync-skills.ps1:91-130`

**Interfaces:**
- Consumes: Struktur hashtable `$SKILL_MAP` pada `sync-skills.ps1`.
- Produces: Pemetaan `caveman` dan `rtk` yang memuat seluruh skill lokal aktif.

- [ ] **Step 1: Edit pemetaan caveman dan rtk di sync-skills.ps1**
  Tambahkan `"graphify"`, `"quality-control"`, `"bahasa-indonesia"`, `"cave"`, `"megacave"`, `"ultracave"` ke `local_skill_prefixes` pada entri `caveman`.
  Tambahkan `"rtk"` ke `local_skill_prefixes` pada entri `rtk`.

- [ ] **Step 2: Verifikasi sintaks PowerShell**
  Jalankan: `powershell -NoProfile -Command "Get-Command -Syntax c:\laragon\www\agent\sync-skills.ps1"`
  Expected: Command syntax tervalidasi tanpa parser error.

- [ ] **Step 3: Commit perubahan Task 1**
  Jalankan:
  ```bash
  git add sync-skills.ps1
  git commit -m "feat(sync): daftarkan rtk, graphify, quality-control, dan varian caveman di SKILL_MAP"
  ```

---

### Task 2: Bersihkan Broken Junctions Remotion & Folder Kosong

**Files:**
- Delete: 13 broken junction directories di `%USERPROFILE%\.gemini\config\skills\remotion-*`
- Delete: Direktori kosong `c:\laragon\www\agent\skills`

**Interfaces:**
- Consumes: Jalur `%USERPROFILE%\.gemini\config\skills` dan `c:\laragon\www\agent\skills`.
- Produces: Direktori bersih tanpa dangling links dan tanpa folder lokal kosong.

- [ ] **Step 1: Hapus 13 broken junction Remotion secara aman**
  Hapus junction: `remotion-best-practices`, `remotion-captions`, `remotion-create`, `remotion-docs`, `remotion-interactivity`, `remotion-license`, `remotion-maps`, `remotion-markup`, `remotion-multimedia`, `remotion-render`, `remotion-saas`, `remotion-studio`, `remotion-upgrade`.
  *Catatan*: Pastikan skill aktif `remotion-new-markup` TIDAK terhapus.

- [ ] **Step 2: Hapus folder kosong skills di root workspace**
  Hapus direktori: `c:\laragon\www\agent\skills`.

- [ ] **Step 3: Verifikasi pembersihan direktori**
  Jalankan skrip verifikasi junction untuk memastikan 0 broken links tersisa di direktori global.

- [ ] **Step 4: Commit perubahan status jika ada berkas terlacak yang terhapus**

---

### Task 3: Perbarui Dokumentasi Katalog Skill

**Files:**
- Modify: `c:/laragon/www/agent/CATALOG_SKILLS_DAN_PLUGIN.md`

**Interfaces:**
- Consumes: Daftar 7 skill baru beserta kegunaannya.
- Produces: Dokumentasi katalog yang lengkap dan mutakhir.

- [ ] **Step 1: Tambahkan rincian 7 skill baru ke CATALOG_SKILLS_DAN_PLUGIN.md**
  Tambahkan entri untuk:
  - `rtk`: Token killer CLI proxy.
  - `graphify`: Visualizer knowledge graph kode repositori.
  - `quality-control`: Multi-axis quality audit across entire project.
  - `bahasa-indonesia`: Kebijakan penegakan Bahasa Indonesia konsisten.
  - `cave`, `megacave`, `ultracave`: Modus kompresi caveman tingkat lanjut.

- [ ] **Step 2: Commit pembaruan dokumentasi**
  Jalankan:
  ```bash
  git add CATALOG_SKILLS_DAN_PLUGIN.md
  git commit -m "docs: perbarui CATALOG_SKILLS_DAN_PLUGIN dengan 7 skill baru"
  ```

---

### Task 4: Verifikasi Menyeluruh Sinkronisasi Skill

**Files:**
- Read-only execution

**Interfaces:**
- Consumes: Skrip `sync-skills.ps1` dan struktur direktori global yang telah dibersihkan.
- Produces: Bukti eksekusi bahwa seluruh repositori dan skill berstatus `[OK]`.

- [ ] **Step 1: Jalankan sync-skills.ps1 -CheckOnly**
  Jalankan: `powershell -NoProfile -ExecutionPolicy Bypass -File .\sync-skills.ps1 -CheckOnly`
  Expected: Tidak ada pesan peringatan skill tidak terdaftar, semua folder lokal dan repositori terdaftar `[OK]`.

- [ ] **Step 2: Jalankan skrip audit scratch untuk memastikan unmapped count = 0**
  Expected: `Unmapped count: 0`.
