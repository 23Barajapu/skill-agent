# Desain Arsitektur All-in-One Skill Manager Antigravity

**Tanggal:** 2026-11-19  
**Status:** Menunggu Persetujuan Pengguna (Pending Approval)  
**Tipe:** Small Change (Konsolidasi & Restrukturisasi Entry Point)

---

## 1. Maksud & Tujuan (Intent & The Why)
Menghilangkan penumpukan skrip terpisah (`install-global-skills.ps1`, `install-skills.bat`, `install-skills.sh`, `sync-skills.bat`, `sync-skills.ps1`) di root repositori agar tampilan workspace bersih, rapi, dan mudah digunakan oleh pemula maupun pengguna tingkat lanjut melalui satu gerbang terpadu (*All-In-One Launcher*).

## 2. Sasaran (Goals, Non-Goals, Anti-Goals)
- **Goals**:
  - Menyediakan 1 gerbang universal untuk Windows: `skill.bat` (yang dapat diklik dua kali dengan menu interaktif atau dijalankan via CLI: `skill install`, `skill sync`, `skill check`).
  - Menyediakan 1 gerbang universal untuk Linux & macOS: `skill.sh` (mendukung argumen `install`, `sync`, `check`, dan menu interaktif).
  - Memindahkan skrip engine internal ke subdirektori terorganisir: `scripts/` (`sync-skills.ps1`, `install-global-skills.ps1`, dll.).
  - Memperbarui dokumentasi [README.md](file:///c:/laragon/www/agent/README.md) agar instruksi penggunaan di ketiga OS mengarah ke launcher baru `skill.bat` dan `skill.sh`.
- **Non-Goals**:
  - Mengubah logika internal sinkronisasi atau pemetaan `SKILL_MAP` yang telah tervalidasi sebelumnya.
  - Menghapus fungsionalitas otomasi atau dual-source fallback yang sudah ada.
- **Anti-Goals**:
  - Membiarkan file `.bat` atau `.ps1` cadangan berserakan di root repositori.
  - Memutus alur kerja CI GitHub Actions `.github/workflows/sync-skills.yml` (jalur skrip yang dipanggil di CI akan disesuaikan ke `scripts/sync-skills.ps1`).

## 3. Batasan (Constraints)
- Tetap mempertahankan dukungan penuh Windows (CMD/PowerShell) serta macOS/Linux (Bash).
- Kompatibel dengan alur GitHub Actions yang memanggil skrip sinkronisasi.
- Menggunakan Bahasa Indonesia profesional untuk komunikasi dan menu terminal interaktif.

## 4. Pendekatan yang Dipertimbangkan (Approaches)
- **Opsi 1: Gerbang Tunggal Interaktif + Folder `scripts/` (Dipilih oleh Pengguna)**
  - Mengabstraksikan seluruh skrip engine ke dalam folder `scripts/`, menyediakan `skill.bat` dan `skill.sh` di root sebagai antarmuka tunggal.
  - *Alasan Dipilih*: Root direktori menjadi sangat bersih (hanya ada launcher dan dokumentasi), ramah bagi pengguna awam (menu interaktif dengan klik 2x), dan tetap tangguh untuk penggunaan CLI di berbagai OS.
- **Opsi 2: Konsolidasi Monolitik (Ditolak)**
  - Menggabungkan seluruh file menjadi satu skrip `sync-skills.ps1`.
  - *Alasan Ditolak*: Root masih memuat banyak file `.bat`, `.ps1`, `.sh` dan skrip monolitik menjadi terlalu panjang serta sulit dirawat.

## 5. Rincian Teknis Implementasi (The How)
1. **Struktur Folder Baru**:
   ```text
   c:\laragon\www\agent\
   ├── README.md
   ├── CATALOG_SKILLS_DAN_PLUGIN.md
   ├── skill.bat                 <-- Launcher Windows All-In-One (Menu + CLI)
   ├── skill.sh                  <-- Launcher Linux/macOS All-In-One (Menu + CLI)
   ├── scripts/
   │   ├── sync-skills.ps1       <-- Engine utama sinkronisasi
   │   ├── install-skills.ps1    <-- Engine utama instalasi (rename dari install-global-skills.ps1)
   │   └── install-skills.sh     <-- Engine Bash untuk instalasi macOS/Linux
   └── .github/
       └── workflows/
           └── sync-skills.yml   <-- Disesuaikan memanggil scripts/sync-skills.ps1
   ```
2. **Perilaku Launcher `skill.bat` & `skill.sh`**:
   - Jika dijalankan tanpa argumen (atau diklik ganda di Windows Explorer): menampilkan menu interaktif:
     - `[1] Install Skills (Pasang ke Google Antigravity global)`
     - `[2] Sync Skills (Sinkronkan upstream Git & push backup)`
     - `[3] Check Repos (Audit status repo & skill baru)`
   - Jika dipanggil via terminal dengan argumen:
     - `skill install [-Force] [-Clone]`
     - `skill sync [skill_name] [-DryRun] [-SkipPush]`
     - `skill check`
3. **Pembersihan Root**:
   - Menghapus skrip lama di root (`install-global-skills.ps1`, `install-skills.bat`, `install-skills.sh`, `sync-skills.bat`, `sync-skills.ps1`) setelah memindahkannya ke `scripts/`.
4. **Pembaruan CI & README**:
   - Menyesuaikan file `.github/workflows/sync-skills.yml` agar mengeksekusi `scripts/sync-skills.ps1`.
   - Memperbarui [README.md](file:///c:/laragon/www/agent/README.md) dengan panduan ringkas satu pintu `skill.bat` / `./skill.sh`.
5. **Verifikasi**:
   - Menguji eksekusi `skill.bat check` dari terminal.
   - Menguji sintaks dan integritas seluruh berkas.
