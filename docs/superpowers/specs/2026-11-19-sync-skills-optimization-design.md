# Desain Optimasi Sinkronisasi & Pemetaan Skill Antigravity

**Tanggal:** 2026-11-19  
**Status:** Menunggu Persetujuan Pengguna (Pending Approval)  
**Tipe:** Small Change (Konsolidasi & Pembersihan)

---

## 1. Maksud & Tujuan (Intent & The Why)
Memastikan seluruh skill lokal dan global terpetakan secara lengkap dan presisi di dalam skrip sinkronisasi (`sync-skills.ps1`), installer global (`install-global-skills.ps1` dan `install-skills.sh`), serta katalog dokumentasi (`CATALOG_SKILLS_DAN_PLUGIN.md`). Menghilangkan broken directory junctions dan folder kosong agar lingkungan agent bersih, cepat, dan bebas error sinkronisasi.

## 2. Sasaran (Goals, Non-Goals, Anti-Goals)
- **Goals**:
  - Mendaftarkan 7 skill aktif (`rtk`, `graphify`, `quality-control`, `bahasa-indonesia`, `cave`, `megacave`, `ultracave`) ke `$SKILL_MAP` dan skrip instalasi terkait.
  - Menghapus 13 broken junction link Remotion (`remotion-*`) di direktori global `%USERPROFILE%\.gemini\config\skills`.
  - Menghapus folder kosong `c:\laragon\www\agent\skills`.
  - Memperbarui `CATALOG_SKILLS_DAN_PLUGIN.md` agar mencerminkan daftar ke-7 skill baru.
  - Memastikan `sync-skills.ps1 -CheckOnly` berjalan sukses tanpa ada skill tak terpetakan.
- **Non-Goals**:
  - Mengubah kode implementasi atau logika internal dari skill-skill tersebut.
  - Mengutak-atik repositori eksternal non-skill (`artemis`, `markitdown`, `awesome-design-md`).
- **Anti-Goals**:
  - Men-download monorepo Remotion publik (>1 GB) yang memperlambat sinkronisasi.
  - Mengubah hak akses atau struktur konfigurasi sistem di luar ruang lingkup agent.

## 3. Batasan (Constraints)
- Mengikuti aturan global Bahasa Indonesia.
- Menggunakan jalur Git dan PowerShell yang aman dan kompatibel dengan Windows serta Bash (`install-skills.sh`).

## 4. Pendekatan yang Dipertimbangkan (Approaches)
- **Opsi 1: Clean & Complete Consolidation (Dipilih oleh Pengguna)**
  - Mendaftarkan 7 skill riil yang ada di repo lokal (`rtk` dan `caveman`), membersihkan broken links Remotion di global, dan merapikan folder workspace.
  - *Alasan Dipilih*: Efisien, ringan, menghilangkan error tautan mati, dan mencakup 100% skill yang benar-benar aktif digunakan.
- **Opsi 2: Full Upstream Remotion Packages Sync (Ditolak)**
  - Menambahkan downstream Remotion `packages/skills/skills`.
  - *Alasan Ditolak*: Ukuran monorepo Remotion sangat besar (>1 GB) dan menambah beban jaringan/waktu sync secara tidak perlu.

## 5. Rincian Teknis Implementasi (The How)
1. **Pembaruan `sync-skills.ps1`**:
   - Menambahkan `"rtk"` ke dalam `local_skill_prefixes` entri `rtk`.
   - Menambahkan `"graphify"`, `"quality-control"`, `"bahasa-indonesia"`, `"cave"`, `"megacave"`, `"ultracave"` ke dalam `local_skill_prefixes` entri `caveman`.
2. **Pembersihan Direktori Global & Workspace**:
   - Menghapus 13 folder junction Remotion mati di `$HOME\.gemini\config\skills\remotion-*`.
   - Menghapus folder kosong `c:\laragon\www\agent\skills`.
3. **Pembaruan Skrip Installer**:
   - Menyesuaikan `install-global-skills.ps1` dan `install-skills.sh` jika memuat daftar statis skill.
4. **Pembaruan Katalog Dokumentasi**:
   - Menambahkan rincian fungsi 7 skill baru tersebut ke [CATALOG_SKILLS_DAN_PLUGIN.md](file:///c:/laragon/www/agent/CATALOG_SKILLS_DAN_PLUGIN.md).
5. **Verifikasi**:
   - Menjalankan `sync-skills.ps1 -CheckOnly` untuk memvalidasi bahwa seluruh skill global dan lokal telah sinkron 100%.
