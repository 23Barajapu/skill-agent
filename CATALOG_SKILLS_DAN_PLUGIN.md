# 📚 Katalog Lengkap Skill & Plugin Antigravity

> Dokumentasi resmi dan panduan referensi seluruh **155 Skill** dan **2 Plugin Antigravity** yang terpasang secara global di Google Antigravity (`~/.gemini/config/`).

---

## 📑 Daftar Isi
1. [Arsitektur Customization Antigravity](#-arsitektur-customization-antigravity)
2. [Plugin Antigravity](#-plugin-antigravity)
   - [1. RTK Plugin (CLI Proxy & Token Optimizer)](#1-rtk-plugin-cli-proxy--token-optimizer)
   - [2. Superpowers Plugin (Agentic Workflow Methodology)](#2-superpowers-plugin-agentic-workflow-methodology)
3. [Katalog Skill Berdasarkan Kategori](#-katalog-skill-berdasarkan-kategori)
   - [Paket 1: Anti-Slop (6 Skill)](#paket-1-anti-slop-6-skill)
   - [Paket 2: Caveman, Token Efficiency & Observability (26 Skill)](#paket-2-caveman-token-efficiency--observability-26-skill)
   - [Paket 3: Ponytail (6 Skill)](#paket-3-ponytail-6-skill)
   - [Paket 4: Agent Core Engineering (25 Skill)](#paket-4-agent-core-engineering-25-skill)
   - [Paket 5: Engineering & Productivity (37 Skill)](#paket-5-engineering--productivity-37-skill)
   - [Paket 6: RTK Specialist (13 Skill)](#paket-6-rtk-specialist-13-skill)
   - [Paket 7: REA - Reverse Engineering Anything (5 Skill)](#paket-7-rea---reverse-engineering-anything-5-skill)
   - [Paket 8: Apple Design, Motion & UI Polish (14 Skill)](#paket-8-apple-design-motion--ui-polish-14-skill)
   - [Paket 9: Security Audit & Pen-Testing (1 Skill)](#paket-9-security-audit--pen-testing-1-skill)
   - [Paket 10: Multi-Agent & Orchestration (1 Skill)](#paket-10-multi-agent--orchestration-1-skill)
   - [Paket 11: Superpowers Agentic Workflow (15 Skill)](#paket-11-superpowers-agentic-workflow-15-skill)
   - [Paket 12: Chrome DevTools & Browser Automation (7 Skill)](#paket-12-chrome-devtools--browser-automation-7-skill)
4. [Cara Kerja & Panduan Penggunaan Skill](#-cara-kerja--panduan-penggunaan-skill)

---

## ⚙️ Arsitektur Customization Antigravity

Seluruh skill dan plugin pada dokumen ini dipasang pada direktori konfigurasi global Antigravity yang bersifat universal bagi setiap pengguna:

- **Skills Root (Universal)**:
  - Format Universal / POSIX: `~/.gemini/config/skills/<nama-skill>/SKILL.md`
  - Format Lingkungan Windows: `%USERPROFILE%\.gemini\config\skills\<nama-skill>\SKILL.md`
  - Contoh di mesin lokal: `C:\Users\<NamaUser>\.gemini\config\skills\<nama-skill>\SKILL.md`
- **Plugins Root (Universal)**:
  - Format Universal / POSIX: `~/.gemini/config/plugins/<nama-plugin>/`
  - Format Lingkungan Windows: `%USERPROFILE%\.gemini\config\plugins\<nama-plugin>\`
- **Rules Root (Universal)**:
  - Format Universal / POSIX: `~/.gemini/config/rules/`
  - Format Lingkungan Windows: `%USERPROFILE%\.gemini\config\rules\`

### Karakteristik Kunci Sistem:
1. **Progressive Disclosure (Hemat Token)**:
   Konten instruksi penuh dalam `SKILL.md` tidak dimuat sekaligus ke memori LLM saat percakapan baru dimulai. Agen hanya membaca indeks nama dan deskripsi singkat. Konten prosedural penuh hanya diaktifkan secara *on-demand* ketika tugas yang diberikan pengguna relevan dengan kapabilitas skill tersebut.
2. **Transparent Lifecycle Hooks**:
   Plugin Antigravity memiliki kemampuan untuk mencegat dan mengubah input tool sebelum dieksekusi (`PreToolUse`), contohnya pada RTK yang secara otomatis menulis ulang perintah terminal.
3. **Deduplikasi Otomatis**:
   Sistem secara otomatis mendeteksi dan mencegah injeksi aturan atau skill ganda dalam satu sesi percakapan.

---

## 🔌 Plugin Antigravity

### 1. RTK Plugin (CLI Proxy & Token Optimizer)
- **Lokasi Direktori**: `~/.gemini/config/plugins/rtk/` (atau `%USERPROFILE%\.gemini\config\plugins\rtk\`)
- **File Konfigurasi**: `plugin.json`, `hooks.json`, `rules/AGENTS.md`
- **Status Operasional**: ✅ **Aktif Otomatis**

#### Mekanisme Kerja:
1. Setiap kali agen memanggil tool terminal `run_command` (misalnya menjalankan: `git status`, `cargo test`, `npm test`, `docker ps`), lifecycle hook `PreToolUse` pada file `hooks.json` mencegat perintah tersebut.
2. Hook mengeksekusi binary `rtk hook antigravity` yang membaca muatan perintah melalui stdin.
3. Perintah secara transparan ditulis ulang menjadi `rtk <perintah>` melalui mutasi `overwrite.CommandLine`.
4. Binary `rtk.exe` mengeksekusi perintah asli di latar belakang dan memangkas keluaran teks yang redundan (seperti progres bar, baris kosong berulang, atau daftar tes sukses yang panjang) hingga **60% - 90%**, menghemat kuota konteks token model secara signifikan.
5. Aturan kesadaran pada `rules/AGENTS.md` memberi tahu agen bahwa teks terminal yang diterimanya adalah hasil kompresi yang padat dan akurat.

### 2. Superpowers Plugin (Agentic Workflow Methodology)
- **Lokasi Direktori**: `~/.gemini/config/plugins/superpowers/` (atau `%USERPROFILE%\.gemini\config\plugins\superpowers\`)
- **File Konfigurasi**: `plugin.json` (versi 7.0.1 oleh Jesse Vincent)
- **Status Operasional**: ✅ **Aktif Otomatis**

#### Mekanisme Kerja:
1. Menyediakan bundel 15 skill alur kerja tingkat lanjut yang memandu agen untuk mempraktikkan metodologi rekayasa perangkat lunak modern.
2. Memprioritaskan brainstorming dan spesifikasi sebelum menulis kode (`brainstorming`, `writing-plans`).
3. Menjalankan TDD ketat (`test-driven-development`) dan delegasi sub-agen mandiri (`subagent-driven-development`, `dispatching-parallel-agents`).
4. Mewajibkan verifikasi empiris berbasis perintah terminal (`verification-before-completion`) sebelum mengklaim pekerjaan selesai.

---

## 📦 Katalog Skill Berdasarkan Kategori

### Paket 1: Anti-Slop (6 Skill)

Filter khusus untuk mencegah keluaran AI generik (*slop*) dalam perancangan antarmuka visual (UI), penulisan narasi/copywriting, tata letak mobile/responsif, dan komentar kode.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `antislop` | Filter inti anti-slop untuk agen AI koding. Mencegah keluaran AI generik pada UI, tulisan, dan kode tanpa membatasi estetika yang diinginkan. |
| 2 | `antislop-code` | Kebersihan komentar kode untuk agen AI: menghapus komentar generik AI yang tidak berguna, mempertahankan penjelasan penting, dan tidak mengubah logika kode. |
| 3 | `antislop-copywriting` | Penulisan teks dan narasi anti-slop. Digunakan saat menulis atau menyunting prosa: judul utama, nada bicara, tombol CTA, dan menghindari pola penulisan klise khas AI. |
| 4 | `antislop-human` | Standar aksesibilitas dan pengalaman pengguna riil. Menjaga kontras warna (termasuk pemeriksa kontras), navigasi keyboard, status fokus, dan kebutuhan pengguna manusia sebenarnya. |
| 5 | `antislop-layoutmobile` | Desain tata letak responsif dan mobile. Mengatur grid yang fleksibel di berbagai ukuran layar (ponsel hingga desktop), mencegah overflow teks/elemen, dan memastikan target sentuhan nyaman. |
| 6 | `antislop-ui` | Rekayasa visual dan UI anti-slop. Digunakan saat membangun atau mengedit antarmuka apa pun: harmoni warna, layout, komponen, dan mikro-animasi modern. |

---

### Paket 2: Caveman, Token Efficiency & Observability (26 Skill)

Rangkaian skill efisiensi token ekstrem, mode komunikasi terkompresi tanpa basa-basi, investigasi masalah secara sistematis, pemetaan basis data graph, dan refactoring kode yang aman.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `cavecrew` | Mendelegasikan tugas ke sub-agen terfokus (`cavecrew-investigator` untuk pencarian kode, `cavecrew-builder` untuk edit 1-2 file, `cavecrew-reviewer` untuk review diff) agar output terkompresi dan konteks utama tetap hemat. |
| 2 | `caveman` | Mode komunikasi ultra-ringkas yang memangkas token keluaran hingga batas maksimal dengan tetap mempertahankan seluruh fakta dan instruksi teknis secara akurat. |
| 3 | `caveman-commit` | Menulis pesan Conventional Commits padat dan terkompresi langsung pada niat/perubahan tanpa basa-basi. |
| 4 | `caveman-compress` | Memadatkan file memori atau instruksi panjang (seperti CLAUDE.md atau daftar tugas) ke format ultra-padat untuk menghemat token masukan. |
| 5 | `caveman-discover` | Menemukan dan melabeli setiap alur kerja LLM di repositori agar konsumsi token dapat dipantau dan dikelompokkan secara terukur. |
| 6 | `caveman-evidence-review` | Memeriksa data metrik LLM (biaya, Cave Score, alur kerja, jejak panggilan/trace, latensi, galat, dan penghematan). |
| 7 | `caveman-explore` | Penjelajah repositori mode baca-saja (*read-only*) untuk orientasi awal atau pelacakan lintas-file yang luas; hanya mengembalikan sitasi path:line ringkas tanpa membebani memori utama. |
| 8 | `caveman-help` | Panduan referensi cepat untuk seluruh perintah, mode, dan fitur pada paket Caveman. |
| 9 | `caveman-learn` | Meninjau laporan konsumsi token, menerapkan perbaikan pemborosan token secara terukur, dan melaporkan efisiensi yang diperoleh. |
| 10 | `caveman-manage` | Memeriksa siklus eksperimen dan memblokir eksekusi yang tidak aman pada lingkungan agen. |
| 11 | `caveman-optimize` | Mengubah hasil observasi optimasi menjadi kandidat evaluasi terukur dibandingkan dengan baseline performa awal. |
| 12 | `caveman-review` | Tinjauan kode padat: satu baris per temuan mencakup lokasi file, masalah yang ditemukan, dan solusi perbaikan langsung. |
| 13 | `caveman-setup` | Menghubungkan repositori ke gateway observabilitas LLM untuk mengukur penggunaan token tanpa mengubah perilaku fungsional aplikasi. |
| 14 | `caveman-stats` | Menampilkan statistik penggunaan token, pembacaan cache, dan atribusi mode sesi percakapan yang sedang berjalan. |
| 15 | `investigate-first` | Mendiagnosis kegagalan yang ambigu sebelum mengubah kode. Mengumpulkan bukti dan hipotesis terurut untuk masalah intermiten, regresi performa, atau galat tak terduga. |
| 16 | `lean-build` | Membangun fitur baru dengan kendali ketat terhadap risiko *overbuilding*; mengutamakan pemanfaatan ulang komponen yang ada dan kondisi henti (*stop condition*) yang tegas. |
| 17 | `migration` | Menerapkan transisi kompatibilitas yang aman dan dapat dibatalkan (*reversible*); mencakup migrasi skema database, API, protokol, dan dependensi. |
| 18 | `safe-refactor` | Merestrukturisasi kode sambil menjaga perilaku fungsional tetap utuh; memverifikasi sebelum dan sesudah perubahan struktural. |
| 19 | `surgical-patch` | Memperbaiki bug atau perubahan perilaku kecil pada lapisan kode paling spesifik (*narrowest layer*) dengan bukti regresi dan pengujian yang tepat. |
| 20 | `verify-and-stop` | Membuktikan bahwa pekerjaan yang ada telah memenuhi kriteria penerimaan tanpa memperlebar ruang lingkup tugas (*scope creep*). |
| 21 | `bahasa-indonesia` | Memaksa seluruh respons, analisis, dan komunikasi AI selalu menggunakan Bahasa Indonesia yang fasih, ringkas, dan profesional secara konsisten. |
| 22 | `graphify` | Menganalisis arsitektur repositori dan memetakan relasi dependensi berkas/simbol menjadi visual knowledge graph interaktif dan persisten. |
| 23 | `megacave` | Mode kompresi token tingkat mega (register karakter ultra-minim) untuk efisiensi token ekstrem pada alur pemanggilan instruksi berulang. |
| 24 | `ultracave` | Mode komunikasi ultra-padat (satu kata bila satu kata sudah cukup) guna memangkas konsumsi token keluaran ke titik terendah. |
| 25 | `cave` | Utilitas kompresi caveman kilat untuk meringkas teks panjang atau file memori menjadi instruksi padat. |
| 26 | `quality-control` | Audit kendali mutu *end-to-end* komprehensif lintas proyek (kode, pengujian, build, keamanan, dan integritas runtime) sebelum rilis atau merge. |

---

### Paket 3: Ponytail (6 Skill)

Prinsip rekayasa perangkat lunak *Lazy Senior Developer* yang mengedepankan solusi paling sederhana, pencegahan kode berlebih (YAGNI), serta pemanfaatan library bawaan sebelum menambah dependensi baru.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `ponytail` | Mendorong solusi paling sederhana dan minimal yang terbukti berhasil (*Lazy Senior Developer*). Menguji apakah fitur perlu dibuat (YAGNI), mengutamakan standard library dan platform bawaan sebelum menambah dependensi. |
| 2 | `ponytail-audit` | Audit seluruh repositori untuk mendeteksi *over-engineering*: daftar terurut berisi kode yang bisa dihapus, diabstraksi ulang, atau diganti dengan modul bawaan. |
| 3 | `ponytail-debt` | Mengumpulkan semua catatan `ponytail:` di codebase menjadi buku catatan utang teknis (*debt ledger*) agar kompromi yang disengaja tetap terlacak. |
| 4 | `ponytail-gain` | Menampilkan papan skor dampak penghematan kode: pengurangan baris kode, penurunan biaya token, dan peningkatan kecepatan kerja. |
| 5 | `ponytail-help` | Kartu referensi cepat untuk seluruh tingkatan mode (*lite*, *full*, *ultra*), perintah, dan skill pada paket Ponytail. |
| 6 | `ponytail-review` | Tinjauan kode yang difokuskan secara eksklusif untuk memangkas *over-engineering*, redundansi library, dan fleksibilitas spekulatif yang tidak dibutuhkan. |

---

### Paket 4: Agent Core Engineering (25 Skill)

Standar industri rekayasa perangkat lunak profesional: pengembangan berbasis pengujian (TDD), perancangan berbasis spesifikasi, arsitektur modul, keamanan OWASP, dan optimasi performa tinggi.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `api-and-interface-design` | Panduan merancang API dan kontrak antarmuka modul yang stabil, baik REST, GraphQL, maupun pemisahan batas antara frontend dan backend. |
| 2 | `browser-testing-with-devtools` | Pengujian aplikasi web pada browser asli menggunakan Chrome DevTools Protocol; memeriksa DOM, log konsol, permintaan jaringan, dan performa riil. |
| 3 | `ci-cd-and-automation` | Otomasi dan konfigurasi alur pipeline CI/CD, penetapan batas kendali mutu (*quality gates*), dan strategi deployment terstruktur. |
| 4 | `code-review-and-quality` | Tinjauan kualitas kode multi-dimensi (standar gaya, spesifikasi, keamanan, dan maintainability) sebelum digabungkan ke cabang utama (*main*). |
| 5 | `code-simplification` | Menyederhanakan kode yang terlalu rumit agar mudah dibaca dan dirawat tanpa mengubah perilaku fungsional aplikasi. |
| 6 | `constraint-driven-development` | Menetapkan standar kualitas proyek sebagai kontrak tertulis dalam `CONSTRAINTS.md` dan mencegah agen mengabaikan/melemahkan pengujian atau ambang batas performa. |
| 7 | `context-engineering` | Mengoptimalkan penyiapan konteks agen, membersihkan instruksi berlebih, dan mengonfigurasi aturan kerja agar kualitas pemikiran agen tetap tajam. |
| 8 | `debugging-and-error-recovery` | Panduan sistematis pelacakan akar masalah (*root-cause debugging*) saat build gagal, tes rusak, atau perilaku sistem menyimpang dari ekspektasi. |
| 9 | `deprecation-and-migration` | Mengelola proses penghapusan sistem lama (deprekasi), migrasi pengguna ke implementasi baru, serta migrasi skema database tanpa *downtime*. |
| 10 | `documentation-and-adrs` | Mendokumentasikan keputusan arsitektur (ADR), mencatat rasionalitas desain teknis, dan menyediakan panduan yang mudah dipahami manusia maupun agen di masa depan. |
| 11 | `doubt-driven-development` | Menguji setiap keputusan arsitektural penting melalui tinjauan kritis (*adversarial review*) untuk menyingkap kegagalan tersembunyi sebelum kode dieksekusi. |
| 12 | `frontend-ui-engineering` | Membangun antarmuka pengguna (UI) berstandar produksi yang modern, responsif, aksesibel (WCAG), dan mengelola state aplikasi secara efisien. |
| 13 | `git-workflow-and-versioning` | Menstandarisasi alur kerja Git: commit atomik, strategi percabangan (*branching*), resolusi konflik, pull request, dan rilis semantik (*semver*). |
| 14 | `idea-refine` | Mempertajam ide mentah menjadi konsep teknis yang terstruktur melalui eksplorasi divergen dan konvergen sebelum berkomitmen pada rencana implementasi. |
| 15 | `incremental-implementation` | Menerapkan perubahan besar dalam irisan-irisan tipis (*thin slices*) yang dapat diuji dan diverifikasi secara bertahap (misal di balik feature flag). |
| 16 | `interview-me` | Wawancara mendalam bertahap (satu per satu pertanyaan) untuk menggali kebutuhan sejati pengguna saat instruksi masih bersifat ambigu atau terlalu umum. |
| 17 | `observability-and-instrumentation` | Menambahkan instrumentasi logging, metrik, jejak (*tracing*), dan peringatan (*alerting*) agar perilaku sistem di lingkungan produksi terpantau jelas. |
| 18 | `performance-optimization` | Mengoptimalkan performa aplikasi secara menyeluruh: perbaikan Core Web Vitals di frontend, eliminasi kueri N+1 di backend, dan profiling bottleneck memori/CPU. |
| 19 | `planning-and-task-breakdown` | Memecah spesifikasi atau proyek besar menjadi urutan tugas yang jelas, terstruktur, dan dapat diimplementasikan secara berurutan atau paralel. |
| 20 | `security-and-hardening` | Memperkuat keamanan aplikasi terhadap kerentanan OWASP Top 10, validasi input pengguna, proteksi autentikasi/sesi, dan audit keamanan dependensi pihak ketiga. |
| 21 | `shipping-and-launch` | Mempersiapkan peluncuran ke produksi: daftar periksa pra-rilis (*pre-launch checklist*), monitoring aktif, peluncuran bertahap (*staged rollout*), dan strategi *rollback*. |
| 22 | `source-driven-development` | Mendasarkan setiap keputusan implementasi langsung pada dokumentasi resmi dan sumber otoritatif untuk menghindari pola kode usang. |
| 23 | `spec-driven-development` | Membuat spesifikasi dan kebutuhan produk (PRD/spec) secara komprehensif sebelum penulisan baris kode pertama dimulai. |
| 24 | `test-driven-development` | Mengarahkan pengembangan fitur dan perbaikan bug melalui siklus TDD (Red-Green-Refactor) yang ketat untuk menjamin keandalan kode. |
| 25 | `using-agent-skills` | Meta-skill yang mengatur bagaimana agen menemukan, memilih, dan memanggil skill yang paling relevan dengan kebutuhan tugas yang sedang dikerjakan. |

---

### Paket 5: Engineering & Productivity (37 Skill)

Koleksi skill tingkat lanjut (Matt Pocock dkk.) untuk wawancara teknis intensif (*grilling*), pemecahan tugas ke tiket spesifikasi, pemodelan domain, dan refactoring modularitas tinggi.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `ask-matt` | Pemandu pemilihan skill atau alur kerja yang paling tepat untuk situasi atau masalah tertentu dalam repositori. |
| 2 | `claude-handoff` | Menyerahkan percakapan yang sedang berjalan ke agen latar belakang (*background agent*) baru agar pekerjaan dapat dilanjutkan secara mandiri. |
| 3 | `codebase-design` | Panduan kosakata dan prinsip perancangan modul mendalam (*deep modules*), antarmuka bersih, dan modularitas yang mudah diuji. |
| 4 | `code-review` | Tinjauan komparatif sejak titik tertentu (commit, branch, tag) berdasarkan dua dimensi: kepatuhan standar kode dan kesesisuaian spesifikasi tugas. |
| 5 | `diagnosing-bugs` | Siklus diagnosis sistematis untuk bug kompleks, galat tersembunyi, dan regresi performa sebelum mencoba menulis perbaikan. |
| 6 | `domain-modeling` | Membangun dan menyelaraskan model domain bisnis dalam repositori, merapikan istilah pada `GLOSSARY.md`, dan merekamnya dalam ADR. |
| 7 | `git-guardrails-claude-code` | Menyiapkan hook pelindung untuk memblokir perintah Git yang berbahaya dan berpotensi destruktif (seperti `push`, `reset --hard`, `clean`). |
| 8 | `grilling` | Wawancara kritis dan tanpa kompromi untuk menguji ketahanan rencana, keputusan arsitektur, atau ide sebelum dieksekusi. |
| 9 | `grill-me` | Sesi wawancara intensif untuk mematangkan dan menguji logika rencana desain teknis. |
| 10 | `grill-with-docs` | Wawancara kritis untuk mematangkan desain teknis yang sekaligus otomatis mendokumentasikan hasilnya ke dalam ADR dan glosarium. |
| 11 | `handoff` | Memadatkan riwayat percakapan saat ini menjadi dokumen ringkasan estafet (*handoff document*) untuk dilanjutkan oleh sesi agen berikutnya. |
| 12 | `implement` | Mengimplementasikan pekerjaan teknis berdasarkan dokumen spesifikasi atau daftar tiket yang telah disepakati. |
| 13 | `implement-spec` | Menulis kode program langsung berdasarkan hasil sintesis `/to-spec` dan `/to-tickets`. |
| 14 | `improve-codebase-architecture` | Memindai arsitektur kode untuk menemukan peluang pembuatan *deep modules*, menyajikannya dalam laporan visual, dan mematangkannya bersama pengguna. |
| 15 | `loop-me` | Menggali spesifikasi alur kerja yang ingin dibangun secara mendalam dalam lingkungan workspace saat ini. |
| 16 | `migrate-to-shoehorn` | Memigrasikan file pengujian dari *type assertion* `as` yang rapuh ke utilitas `@total-typescript/shoehorn` demi keamanan tipe data tes. |
| 17 | `pr` | Membantu merumuskan deskripsi dan ringkasan perubahan Pull Request (PR) yang jelas, padat, dan informatif bagi *reviewer*. |
| 18 | `prototype` | Membangun prototipe cepat (*throwaway prototype*) untuk memvalidasi model state, alur antarmuka pengguna, atau kelayakan teknis sebelum implementasi final. |
| 19 | `research` | Melakukan investigasi mendalam terhadap pertanyaan teknis berdasarkan dokumentasi resmi dan mencatat temuannya dalam file Markdown di repositori. |
| 20 | `retro` | Mengadakan sesi retrospektif evaluasi terhadap sesi pengkodean yang baru selesai untuk mencatat pembelajaran dan perbaikan. |
| 21 | `scaffold-exercises` | Menyusun kerangka direktori latihan pemrograman terstruktur (masalah, solusi, dan penjelasan konsep) yang lolos uji linting. |
| 22 | `setup-matt-pocock-skills` | Mengonfigurasi lingkungan repositori untuk ekosistem engineering skills: issue tracker, vocabulary label triage, dan tata letak domain docs. |
| 23 | `setup-pre-commit` | Menyiapkan hook pre-commit Husky dengan lint-staged (Prettier), pengecekan tipe data, dan uji otomatis sebelum kode di-commit. |
| 24 | `setup-ts-deep-modules` | Mengonfigurasi `dependency-cruiser` pada proyek TypeScript agar setiap paket bertindak sebagai *deep module* yang hanya dapat diakses melalui titik masuk resminya. |
| 25 | `tdd` | Menerapkan metodologi Test-Driven Development (TDD) untuk membangun fitur baru atau memperbaiki bug secara *test-first*. |
| 26 | `teach` | Membimbing dan mengajarkan konsep pemrograman atau keterampilan teknis baru kepada pengguna langsung di dalam workspace. |
| 27 | `to-questionnaire` | Mengubah keputusan teknis yang belum memiliki jawaban pasti menjadi kuesioner terstruktur agar dapat dijawab oleh pihak berkepentingan. |
| 28 | `to-spec` | Menyintesis hasil diskusi percakapan saat ini menjadi dokumen spesifikasi teknis formal dan mempublikasikannya ke issue tracker proyek. |
| 29 | `to-tickets` | Memecah rencana atau spesifikasi menjadi serangkaian tiket pekerjaan (*tracer-bullet tickets*) yang mencantumkan dependensi pemblokir antar-tiket. |
| 30 | `triage` | Memproses antrean isu dan PR eksternal melalui *state machine*, memverifikasi masalah, mengkategorikan label, dan menulis ringkasan yang siap dikerjakan. |
| 31 | `wait-what` | Berhenti sejenak ketika pesan atau arahan sebelumnya kurang tepat sasaran, lalu merumuskan kembali penjelasan dengan pendekatan yang lebih jelas. |
| 32 | `wayfinder` | Merencanakan proyek skala besar (yang melampaui kapasitas satu sesi percakapan) sebagai peta tiket keputusan terkoordinasi hingga tujuan akhir tercapai. |
| 33 | `wizard` | Menghasilkan skrip pemandu interaktif (*wizard*) untuk langkah-langkah yang memerlukan otorisasi atau tindakan manual manusia (misal provisioning cloud, setup kredensial). |
| 34 | `writing-beats` | Mengembangkan tulisan teknis dengan merangkai materi mentah menjadi alur gagasan terurut (*beats*) yang logis. |
| 35 | `writing-for-agents` | Menyusun dokumen instruksi khusus untuk agen AI (seperti pembuatan skill baru, `AGENTS.md`, atau `CLAUDE.md`) agar instruksi dipatuhi secara efektif. |
| 36 | `writing-fragments` | Menggali ide-ide mentah dan poin-poin kunci bebas tanpa memaksakan struktur terlebih dahulu. |
| 37 | `writing-shape` | Membentuk fragmen materi mentah menjadi draf artikel atau dokumentasi utuh yang tertata paragraf demi paragraf. |

---

### Paket 6: RTK Specialist (13 Skill)

Skill audit, triage PR/isu GitHub, penyederhanaan kode Rust secara idiomatis, dan manajemen pengujian filter CLI token optimizer.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `code-simplifier` | Meninjau kode Rust pada RTK untuk penyederhanaan yang idiomatis: menghapus alokasi memori yang tidak perlu, memangkas over-engineering, dan menerapkan idiom Rust. |
| 2 | `design-patterns` | Panduan pola desain Rust untuk modul filter RTK (Newtype, Builder, RAII, Trait Objects, State Machine). |
| 3 | `issue-triage` | Audit komprehensif terhadap isu terbuka: kategorisasi, deteksi duplikat, penilaian risiko keamanan, dan penyusunan draf komentar. |
| 4 | `performance` | Analisis dan optimasi performa CLI RTK: waktu startup (<10ms), penggunaan memori resident (<5MB), dan benchmark rasio penghematan token. |
| 5 | `pr-review` | Tinjauan bertahap (*batch review*) terhadap Pull Request berdasarkan tingkat kompleksitas (XS ke L), verifikasi status konflik, dan analisis konteks diff. |
| 6 | `pr-triage` | Audit dan triage Pull Request terbuka, inspeksi mendalam pada PR terpilih, dan penyusunan draf review terstruktur. |
| 7 | `repo-recap` | Menghasilkan ringkasan komprehensif status repositori (PR terbuka, isu, rilis terbaru, dan kesimpulan eksekutif) yang siap dibagikan ke tim. |
| 8 | `rtk-tdd` | Menerapkan siklus TDD (Red-Green-Refactor) berbasis idiom Rust dengan pustaka `anyhow`/`thiserror`, `cfg(test)`, dan pola Arrange-Act-Assert. |
| 9 | `rtk-triage` | Triage lengkap RTK yang memadukan audit isu dan PR secara paralel untuk mendeteksi tumpang tindih penanganan dan celah keamanan. |
| 10 | `security-guardian` | Analisis keamanan CLI untuk RTK: proteksi terhadap command injection, sanitasi shell escaping, dan pengamanan eksekusi lifecycle hook. |
| 11 | `ship` | Alur kerja otomatisasi rilis: verifikasi build, pembaruan versi semantik (*version bump*), update changelog, git tagging, dan trigger pipeline CI/CD. |
| 12 | `tdd-rust` | Alur kerja TDD khusus untuk pengembangan filter RTK: uji snapshot dengan `insta`, validasi batas penghematan token, dan pengujian regresi. |
| 13 | `rtk` | Meta-skill integrasi proxy CLI RTK (Rust Token Killer) untuk memotong kuota token terminal secara transparan hingga 90%. |

---

### Paket 7: REA - Reverse Engineering Anything (5 Skill)

Alat rekayasa balik (*reverse engineering*) tingkat lanjut untuk target biner native, aplikasi Electron/JavaScript terkompilasi, firmware, dan browser, serta perancangan lingkungan runtime agen.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `rea-analysis-optimization` | Menganalisis dan mengoptimalkan alur kerja investigasi rekayasa balik target biner atau bundel aplikasi. |
| 2 | `rea-changelog-update` | Mengelola pembaruan changelog dan sinkronisasi versi rilis pada perkakas REA. |
| 3 | `rea-ci-tests-audit` | Mengaudit pengujian CI/CD dan memverifikasi kelayakan runtime paket analisis REA. |
| 4 | `rea-tool-design` | Panduan perancangan antarmuka tool agen REA, skema input, dan penanganan bukti eksekusi (*evidence*). |
| 5 | `reverse-engineer-anything` | Rekayasa balik target biner native, aplikasi Electron, runtime browser, dan pembuatan lingkungan agen (AgentEnv). |

---

### Paket 8: Apple Design, Motion & UI Polish (14 Skill)

Filosofi perancangan antarmuka visual kelas dunia Apple dan Emil Kowalski: fisika gerak fluida, mikro-animasi berperforma tinggi (60/120 FPS), interaksi sentuh mobile native, dan arsitektur Swift modern.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `animate` | Merancang animasi antarmuka dari awal: menentukan kurva easing, timing spring, durasi, interupsi transisi, dan animasi keluar (*exit*). |
| 2 | `animate-expo` | Membangun animasi di React Native dan Expo menggunakan Reanimated, Gesture Handler, dan haptics perangkat. |
| 3 | `animation-performance` | Menjaga animasi web tetap mulus di dalam batas frame budget (60/120fps) dengan menganimasikan properti composite-only dan meminimalkan main-thread jank. |
| 4 | `animation-vocabulary` | Glosarium pencarian terbalik (*reverse-lookup*) untuk menerjemahkan deskripsi efek visual menjadi istilah teknis motion yang presisi. |
| 5 | `apple-design` | Pendekatan desain antarmuka Apple: gerak fluida fisik, pegas kenyal, gestur sentuh/swipe, translusensi material, dan hierarki tipografi mendalam. |
| 6 | `ask-sonner` | Panduan lengkap pustaka toast React Sonner: instalasi, konfigurasi Toaster, promise/loading toast, tema kustom, posisi, dan penanganan modal. |
| 7 | `break-ui` | Menguji ketahanan komponen UI terhadap data kasus terburuk (*stress test*): nama sangat panjang, email tanpa spasi, angka ekstrim, dan zero-items. |
| 8 | `emil-design-eng` | Filosofi rekayasa antarmuka Emil Kowalski: *UI polish*, perancangan komponen detail, animasi tak kasat mata, dan nuansa mikro yang membuat software terasa hidup. |
| 9 | `find-animation-opportunities` | Memindai antarmuka atau kode untuk mengidentifikasi elemen-elemen statis yang layak diberi mikro-animasi guna meningkatkan interaktivitas. |
| 10 | `improve-animations` | Audit komprehensif terhadap kode animasi dan transisi di seluruh repositori untuk menyusun rencana peningkatan kualitas gerak. |
| 11 | `mobile-native` | Teknik CSS dan konfigurasi meta-tag agar aplikasi web terasa seperti aplikasi native di smartphone (mencegah double-tap zoom, pull-to-refresh glitch, dan lag sentuhan). |
| 12 | `pick-ui-library` | Rekomendasi kurasi pustaka frontend terbaik dan teringan untuk kebutuhan spesifik tanpa membebani ukuran bundle aplikasi. |
| 13 | `review-animations` | Tinjauan kritis terhadap implementasi kode animasi berdasarkan standar tinggi fisika gerak, kehalusan frame, dan interupsi gestur. |
| 14 | `write-swift` | Rekayasa modern Swift: pemodelan value types, keamanan data-race Swift 6 (@concurrent, actors), protocol generics, dan performa alokasi ARC. |

---

### Paket 9: Security Audit & Pen-Testing (1 Skill)

Audit keamanan mendalam, deteksi kerentanan OWASP, analisis API, sanitasi masukan tidak tepercaya, dan pengujian penetrasi menyeluruh.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `security-audit` | Panduan audit keamanan dan tinjauan kerentanan untuk basis kode, API, layanan latar belakang, CLI tools, dan manajemen dependensi pihak ketiga. |

---

### Paket 10: Multi-Agent & Orchestration (1 Skill)

Integrasi ekosistem orkestrasi agen eksternal dan delegasi tugas otonom.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `hermes` | Integrasi dan orkestrasi komunikasi agen asisten Hermes ke dalam alur kerja Google Antigravity. |

---

### Paket 11: Superpowers Agentic Workflow (15 Skill)

Metodologi rekayasa perangkat lunak agentik komprehensif oleh Jesse Vincent (`obra/superpowers`). Mengarahkan agen untuk bekerja dengan disiplin rekayasa tingkat tinggi: brainstorming terstruktur sebelum coding, perencanaan implementasi bertahap (*spec-driven*), TDD ketat, isolasi git worktrees, eksekusi sub-agen paralel, tinjauan kode adversarial, dan verifikasi bukti sebelum menyelesaikan tugas.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `brainstorming` | Wajib digunakan sebelum pekerjaan kreatif apa pun — merancang fitur, membuat komponen, menambah fungsi, memodifikasi perilaku, atau merencanakan sistem baru. |
| 2 | `diagnosing-superpowers` | Mendiagnosis kendala atau kegagalan pada sesi superpowers (kerja berulang, rencana diabaikan, skill tidak aktif, overhead token, atau analisis performa sesi). |
| 3 | `dispatching-parallel-agents` | Mendelegasikan 2 atau lebih tugas independen ke sub-agen paralel tanpa shared state atau dependensi sekuensial. |
| 4 | `executing-plans` | Menjalankan rencana implementasi secara terstruktur langkah demi langkah dalam sesi aktif saat ini sebagai pelaksana utama. |
| 5 | `finishing-a-development-branch` | Panduan integrasi cabang pengembangan setelah implementasi selesai dan seluruh pengujian lolos (merge, rebase, PR). |
| 6 | `receiving-code-review` | Menanggapi masukan review kode secara kritis dan terverifikasi secara teknis sebelum menerapkan saran, bukan sekadar persetujuan buta. |
| 7 | `requesting-code-review` | Mengajukan permohonan tinjauan kode setelah menyelesaikan tugas besar atau sebelum merge untuk memastikan kesesuaian dengan spesifikasi. |
| 8 | `subagent-driven-development` | Pola eksekusi implementasi modular dengan mendelegasikan tugas-tugas mandiri ke sub-agen khusus. |
| 9 | `systematic-debugging` | Investigasi sistematis untuk menemukan akar masalah (*root cause*) sebelum mengajukan perbaikan saat terjadi bug atau kegagalan tes. |
| 10 | `test-driven-development` | Menggerakkan pengembangan dengan siklus Red-Green-Refactor yang ketat sebelum menulis kode implementasi. *(Shared dengan Paket 4)* |
| 11 | `using-git-worktrees` | Menyiapkan isolasi workspace menggunakan git worktree sebelum mengeksekusi rencana atau fitur berisiko. |
| 12 | `using-superpowers` | Menetapkan protokol penemuan dan aktivasi skill superpowers di awal percakapan sebelum memberikan respon. |
| 13 | `verification-before-completion` | Mengharuskan verifikasi bukti empiris (*evidence*) melalui perintah terminal sebelum mengklaim pekerjaan selesai atau passing. |
| 14 | `writing-plans` | Menyusun rencana implementasi detail berbasis spesifikasi sebelum menyentuh atau memodifikasi kode. |
| 15 | `writing-skills` | Merancang, menulis, memvalidasi sintaks frontmatter, dan menguji coba skill agen baru sebelum didistribusikan. |

---

### Paket 12: Chrome DevTools & Browser Automation (7 Skill)

Perkakas resmi dari tim Chrome DevTools (`ChromeDevTools/chrome-devtools-mcp`) untuk inspeksi browser mendalam, otomatisasi pengujian antarmuka, profil performa Core Web Vitals, audit aksesibilitas, dan diagnosis memori runtime melalui protokol Chrome DevTools MCP.

| No | Nama Skill | Deskripsi & Kapan Digunakan |
| :---: | :--- | :--- |
| 1 | `a11y-debugging` | Audit dan debugging aksesibilitas (a11y) sesuai standar WCAG & web.dev: pengujian HTML semantik, ARIA label, fokus keyboard, target sentuh, dan kontras warna. |
| 2 | `chrome-devtools` | Penggunaan Chrome DevTools via MCP untuk otomasi browser, evaluasi DOM, inspeksi jaringan, dan interaksi halaman web secara cerdas. |
| 3 | `chrome-devtools-cli` | Panduan menulis skrip shell dan otomasi CLI untuk berinteraksi langsung dengan Chrome DevTools. |
| 4 | `cookie-debugging` | Inspeksi, debugging, dan pengujian cookies, status sesi, otentikasi (401/403), SameSite, Partitioned cookies, dan kepatuhan banner persetujuan privasi. |
| 5 | `debug-optimize-lcp` | Diagnosis dan optimasi Largest Contentful Paint (LCP) dan Core Web Vitals untuk mempercepat rendering hero image dan konten utama halaman web. |
| 6 | `memory-leak-debugging` | Diagnosis dan perbaikan kebocoran memori (*memory leaks*) aplikasi JavaScript/Node.js melalui inspeksi dan perbandingan heap snapshot. |
| 7 | `troubleshooting` | Panduan penanganan kendala koneksi tab browser, inisialisasi server MCP, dan troubleshooting target DevTools. |

---

## 💡 Cara Kerja & Panduan Penggunaan Skill

### 1. Pemanggilan Otomatis oleh Model (*Model-Invoked*)
Anda tidak perlu menghafal atau mengetikkan nama skill secara manual. Berikan instruksi dengan maksud yang jelas, agen akan secara cerdas mengenali skill yang relevan berdasarkan deskripsinya:
- *Contoh*: `"Tolong review PR ini apakah ada over-engineering dan kode yang bisa dihapus"` -> Agen otomatis mengaktifkan skill ``ponytail-review`` atau ``code-simplification``.
- *Contoh*: `"Buatkan animasi pembuka halaman login yang smooth ala Apple"` -> Agen otomatis mengaktifkan skill ``apple-design`` atau ``animate``.
- *Contoh*: `"Audit keamanan endpoint pembayaran ini terhadap OWASP"` -> Agen otomatis mengaktifkan skill ``security-audit`` atau ``security-and-hardening``.
- *Contoh*: `"Stress-test form input ini dengan worst-case data"` -> Agen otomatis mengaktifkan skill ``break-ui``.

### 2. Pemanggilan Eksplisit (*Explicit Invocation*)
Anda juga dapat secara langsung menyebutkan nama skill dalam pesan Anda:
- *Contoh*: `"Gunakan skill apple-design untuk memoles antarmuka modal ini."`
- *Contoh*: `"Jalankan caveman mode untuk respon kali ini agar hemat token."`
- *Contoh*: `"Gunakan skill security-audit untuk menguji kerentanan API."`

---
*Dokumen ini diperbarui secara berkala dan memetakan seluruh 155 skill terpasang di Google Antigravity.*
