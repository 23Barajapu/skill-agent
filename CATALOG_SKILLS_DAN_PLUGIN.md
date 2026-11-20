# 📚 Katalog Lengkap Skill & Plugin Antigravity

> Dokumentasi resmi dan panduan referensi seluruh **164+ Skill** dan **2 Plugin Antigravity** yang terpasang secara global di Google Antigravity (`~/.gemini/config/`), Kiro IDE, Claude Code, Cursor, Windsurf, dan VS Code / Cline.

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
   - [Paket 4: Agent Core Engineering (26 Skill)](#paket-4-agent-core-engineering-26-skill)
   - [Paket 5: Engineering & Productivity (39 Skill)](#paket-5-engineering--productivity-39-skill)
   - [Paket 6: RTK Specialist (13 Skill)](#paket-6-rtk-specialist-13-skill)
   - [Paket 7: REA - Reverse Engineering Anything (5 Skill)](#paket-7-rea---reverse-engineering-anything-5-skill)
   - [Paket 8: Apple Design, Motion & UI Polish (19 Skill)](#paket-8-apple-design-motion--ui-polish-19-skill)
   - [Paket 9: Security Audit & Pen-Testing (1 Skill)](#paket-9-security-audit--pen-testing-1-skill)
   - [Paket 10: Superpowers Agentic Workflow (15 Skill)](#paket-10-superpowers-agentic-workflow-15-skill)
   - [Paket 11: Chrome DevTools & Browser Automation (8 Skill)](#paket-11-chrome-devtools--browser-automation-8-skill)
   - [Paket 12: Mobile Automation & Testing - ARTEMIS (1 Skill)](#paket-12-mobile-automation--testing---artemis-1-skill)
4. [Cara Kerja & Panduan Penggunaan Skill](#-cara-kerja--panduan-penggunaan-skill)

---

## ⚙️ Arsitektur Customization Antigravity

Seluruh skill dan plugin pada dokumen ini dipasang pada direktori konfigurasi global yang bersifat universal bagi setiap pengguna:

- **Skills Root (Universal)**:
  - Format Universal / POSIX: `~/.gemini/config/skills/<nama-skill>/SKILL.md`
  - Format Lingkungan Windows: `%USERPROFILE%\.gemini\config\skills\<nama-skill>\SKILL.md`
- **Plugins Root (Universal)**:
  - Format Universal / POSIX: `~/.gemini/config/plugins/<nama-plugin>/`
  - Format Lingkungan Windows: `%USERPROFILE%\.gemini\config\plugins\<nama-plugin>\`
- **Rules Root (Universal)**:
  - Format Universal / POSIX: `~/.gemini/config/rules/`
  - Format Lingkungan Windows: `%USERPROFILE%\.gemini\config\rules\`

### Karakteristik Kunci Sistem:
1. **Progressive Disclosure (Hemat Token)**: Konten instruksi penuh dalam `SKILL.md` hanya dimuat secara *on-demand* saat tugas relevan dengan kapabilitas skill tersebut.
2. **Transparent Lifecycle Hooks**: Mencegat perintah sebelum dieksekusi (`PreToolUse`), seperti pada RTK untuk memangkas log terminal.
3. **Deduplikasi Otomatis**: Mencegah pemanggilan atau injeksi ganda dalam satu sesi percakapan.

---

## 🔌 Plugin Antigravity

### 1. RTK Plugin (CLI Proxy & Token Optimizer)
- **Lokasi Direktori**: `~/.gemini/config/plugins/rtk/`
- **File Konfigurasi**: `plugin.json`, `hooks.json`, `rules/AGENTS.md`
- **Status Operasional**: ✅ **Aktif Otomatis**
- **Mekanisme**: Setiap pemanggilan tool terminal `run_command` dicegat oleh lifecycle hook `PreToolUse`. Perintah diubah menjadi `rtk <cmd>` secara transparan, memangkas keluaran teks redundan hingga **60% - 90%** guna menghemat kuota konteks model.

### 2. Superpowers Plugin (Agentic Workflow Methodology)
- **Lokasi Direktori**: `~/.gemini/config/plugins/superpowers/`
- **File Konfigurasi**: `plugin.json` (versi 7.0.1)
- **Status Operasional**: ✅ **Aktif Otomatis**
- **Mekanisme**: Memandu agen menerapkan disiplin rekayasa perangkat lunak modern: brainstorming terstruktur, *spec-driven development*, TDD ketat, sub-agen mandiri, dan verifikasi empiris sebelum mengklaim pekerjaan selesai.

---

## 📦 Katalog Skill Berdasarkan Kategori

### Paket 1: Anti-Slop (6 Skill)

Filter khusus untuk mencegah keluaran AI generik (*slop*) dalam perancangan antarmuka visual (UI), penulisan narasi/copywriting, tata letak mobile/responsif, dan komentar kode.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `antislop` | Filter inti pencegah keluaran AI generik (*slop*) untuk antarmuka visual, teks, dan kode. | Digunakan setiap saat sebagai filter dasar agar desain dan kode tidak terlihat kaku atau klise khas AI. |
| `antislop-code` | Membersihkan komentar kode generik AI dan mempertahankan penjelasan penting tanpa mengubah logika kode. | Digunakan saat merapikan komentar kode dari penjelasan basa-basi yang redundan. |
| `antislop-copywriting` | Menyempurnakan prosa, judul utama, nada bicara (*tone*), dan tombol CTA agar alami dan bebas gaya klise AI. | Digunakan saat menulis atau mengedit teks, copywriting produk, landing page, atau antarmuka. |
| `antislop-human` | Menjaga standar aksesibilitas manusia: rasio kontras warna, navigasi keyboard, status fokus, dan affordance interaksi riil. | Digunakan saat menguji antarmuka agar ramah pengguna disabilitas dan memenuhi standar kontras WCAG. |
| `antislop-layoutmobile` | Mengatur tata letak responsif, grid fleksibel, pencegahan overflow teks/elemen, dan target sentuhan mobile yang nyaman. | Digunakan saat mendesain layout yang harus reflow di berbagai ukuran layar dari ponsel hingga desktop. |
| `antislop-ui` | Menerapkan panduan estetika visual antarmuka: harmoni warna, proporsi komponen, dan kehalusan animasi. | Digunakan saat membangun atau merevisi antarmuka visual agar tampak modern dan berstandar produksi. |

---

### Paket 2: Caveman, Token Efficiency & Observability (26 Skill)

Rangkaian skill efisiensi token ekstrem, mode komunikasi terkompresi tanpa basa-basi, investigasi masalah sistematis, pemetaan basis data graph, dan refactoring kode yang aman.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `cavecrew` | Mendelegasikan tugas ke sub-agen terfokus (`cavecrew-investigator`, `cavecrew-builder`, `cavecrew-reviewer`) dengan output terkompresi. | Digunakan saat ingin melokalisasi kode atau merevisi 1-2 berkas tanpa membebani memori konteks utama. |
| `caveman` | Mode komunikasi ultra-ringkas yang memangkas token keluaran ke titik terendah dengan mempertahankan fakta teknis secara presisi. | Digunakan saat pengguna mengaktifkan mode `/caveman` atau meminta respon padat dan hemat token. |
| `caveman-commit` | Menulis pesan Conventional Commits yang padat dan terfokus langsung pada niat/perubahan esensial. | Digunakan saat menyusun pesan commit atau menyiapkan perubahan untuk di-push ke remote. |
| `caveman-compress` | Memadatkan file memori atau instruksi panjang (seperti CLAUDE.md atau daftar tugas) ke format ultra-padat. | Digunakan saat ingin memangkas konsumsi token masukan dari file aturan proyek yang membengkak. |
| `caveman-discover` | Menemukan dan melabeli setiap alur kerja LLM di repositori agar konsumsi token terpantau secara terukur. | Digunakan saat ingin membedah alur kerja LLM dan mengelompokkan pengeluaran token per workflow. |
| `caveman-evidence-review` | Memeriksa data metrik LLM (biaya, Cave Score, alur kerja, jejak panggilan, latensi, galat, dan efisiensi). | Digunakan saat menganalisis laporan pengeluaran token dan performa inferensi model. |
| `caveman-explore` | Penjelajah repositori mode baca-saja (*read-only*) untuk orientasi awal atau pelacakan lintas-file yang luas. | Digunakan saat orientasi proyek baru atau pelacakan simbol luas tanpa membebani memori utama. |
| `caveman-help` | Panduan referensi cepat untuk seluruh perintah, mode, dan fitur pada ekosistem Caveman. | Digunakan saat pengguna mengetik `/caveman-help` atau memerlukan bantuan penggunaan perintah Caveman. |
| `caveman-learn` | Meninjau laporan konsumsi token, menerapkan perbaikan pemborosan token, dan melaporkan efisiensi yang diperoleh. | Digunakan saat ingin memangkas konsumsi token agen atau memindahkan konteks berulang ke memori ringkas. |
| `caveman-manage` | Memeriksa siklus eksperimen dan memblokir eksekusi yang tidak aman pada lingkungan agen. | Digunakan saat mengelola, menyetujui, membatalkan, atau mempromosikan eksperimen optimasi. |
| `caveman-optimize` | Mengubah hasil observasi optimasi menjadi kandidat evaluasi terukur dibandingkan dengan baseline performa awal. | Digunakan saat mengevaluasi laporan optimasi model sebelum menerapkan konfigurasi permanen. |
| `caveman-review` | Tinjauan kode padat: satu baris per temuan mencakup lokasi file, masalah yang ditemukan, dan solusi perbaikan langsung. | Digunakan saat melakukan review cepat terhadap diff kode atau pull request. |
| `caveman-setup` | Menghubungkan repositori ke gateway observabilitas LLM untuk mengukur penggunaan token tanpa mengubah kode aplikasi. | Digunakan saat ingin menyiapkan pemantauan biaya dan konsumsi token LLM pada proyek. |
| `caveman-stats` | Menampilkan statistik penggunaan token, pembacaan cache, dan atribusi mode sesi percakapan yang sedang berjalan. | Digunakan saat ingin mengetahui jumlah token output dan cache-read yang telah dihabiskan. |
| `investigate-first` | Mendiagnosis kegagalan yang ambigu sebelum mengubah kode melalui pengumpulan bukti dan hipotesis terurut. | Digunakan saat menghadapi bug yang penyebabnya belum jelas, perilaku intermiten, atau regresi performa. |
| `lean-build` | Membangun fitur baru dengan kendali ketat terhadap risiko *overbuilding* dan kondisi henti (*stop condition*) yang tegas. | Digunakan saat mengimplementasikan fitur baru di mana pemanfaatan ulang kode dan batas ruang lingkup sangat penting. |
| `migration` | Menerapkan transisi kompatibilitas yang aman dan dapat dibatalkan (*reversible*) untuk skema data, API, protokol, dan dependensi. | Digunakan saat melakukan migrasi skema database di produksi, update protokol, atau perombakan dependensi. |
| `safe-refactor` | Merestrukturisasi kode sambil menjaga perilaku fungsional tetap utuh dengan verifikasi sebelum dan sesudah edit. | Digunakan saat melakukan ekstraksi fungsi, konsolidasi modul, atau pembersihan kode tanpa mengubah fungsionalitas. |
| `surgical-patch` | Memperbaiki bug atau perubahan perilaku kecil pada lapisan kode paling spesifik (*narrowest layer*) dengan bukti regresi. | Digunakan saat perbaikan kecil harus terlokalisasi rapi tanpa memicu efek samping pada modul sekitarnya. |
| `verify-and-stop` | Membuktikan bahwa pekerjaan yang ada telah memenuhi kriteria penerimaan tanpa memperlebar ruang lingkup tugas (*scope creep*). | Digunakan saat melakukan validasi akhir, completion check, atau pengujian gerbang sebelum rilis. |
| `bahasa-indonesia` | Memaksa seluruh respons, analisis, dan komunikasi AI selalu menggunakan Bahasa Indonesia yang fasih, ringkas, dan profesional. | Digunakan otomatis saat pengguna berbahasa Indonesia atau memanggil instruksi `/bahasa`. |
| `graphify` | Menganalisis arsitektur repositori dan memetakan relasi dependensi berkas/simbol menjadi visual knowledge graph interaktif. | Digunakan saat ingin memahami relasi antar-file, arsitektur sistem kompleks, atau menavigasi codebase besar. |
| `megacave` | Mode kompresi token tingkat mega untuk efisiensi token ekstrem pada alur pemanggilan instruksi berulang. | Digunakan saat batas konteks token sangat kritis dan dibutuhkan respons minimalis. |
| `ultracave` | Mode komunikasi ultra-padat (satu kata bila satu kata sudah cukup) guna memangkas konsumsi token ke titik terendah. | Digunakan saat pengguna menginginkan kompresi teks maksimal tanpa narasi pengantar. |
| `cave` | Utilitas kompresi kilat untuk meringkas teks panjang atau file memori menjadi format padat. | Digunakan saat ingin memadatkan blok teks besar ke format ringkas sekali jalan. |
| `quality-control` | Audit kendali mutu *end-to-end* komprehensif lintas proyek (kode, pengujian, build, keamanan, dan integritas runtime). | Digunakan sebelum melakukan penggabungan cabang besar (*merge*) atau peluncuran ke produksi. |

---

### Paket 3: Ponytail (6 Skill)

Prinsip rekayasa perangkat lunak *Lazy Senior Developer* yang mengedepankan solusi paling sederhana, pencegahan kode berlebih (YAGNI), serta pemanfaatan library bawaan sebelum menambah dependensi baru.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `ponytail` | Mendorong solusi paling sederhana dan minimal yang terbukti berhasil (*Lazy Senior Developer*), mematuhi prinsip YAGNI. | Digunakan pada setiap tugas koding saat pengguna menginginkan solusi paling ringkas dan anti-bloatware. |
| `ponytail-audit` | Mengaudit seluruh repositori untuk mendeteksi *over-engineering*, redundansi library, dan kode yang layak dihapus. | Digunakan saat ingin merampingkan proyek, mencari bagian kode yang mubazir, atau audit kualitas komprehensif. |
| `ponytail-debt` | Mengumpulkan semua catatan utang teknis (`shortcut:` atau `ponytail:`) di codebase menjadi buku catatan terstruktur (*debt ledger*). | Digunakan saat meninjau kembali kompromi teknis yang sempat ditunda agar dapat dijadwalkan perbaikannya. |
| `ponytail-gain` | Menampilkan metrik dampak penghematan kode: pengurangan baris kode, penurunan biaya token, dan peningkatan performa. | Digunakan saat ingin melihat bukti terukur dari hasil refactoring minimalis yang telah dilakukan. |
| `ponytail-help` | Kartu referensi cepat untuk tingkatan mode (*lite*, *full*, *ultra*), perintah, dan skill pada paket Ponytail. | Digunakan saat membutuhkan panduan cepat perintah dan opsi konfigurasi Ponytail. |
| `ponytail-review` | Tinjauan kode yang difokuskan secara eksklusif untuk memangkas *over-engineering*, abstraksi berlebihan, dan kompleksitas spekulatif. | Digunakan saat mereview commit, pull request, atau modul baru yang dicurigai terlalu rumit. |

---

### Paket 4: Agent Core Engineering (26 Skill)

Standar industri rekayasa perangkat lunak profesional: pengembangan berbasis pengujian (TDD), perancangan berbasis spesifikasi, arsitektur modul, keamanan OWASP, aksesibilitas WCAG, dan optimasi performa tinggi.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `accessibility-engineering` | Mengaudit antarmuka yang ada terhadap standar WCAG 2.2 AA dan langsung memperbaiki pelanggaran aksesibilitas yang ditemukan. | Digunakan saat mengaudit halaman web dengan axe-core/pa11y, mengatasi kontras warna, atau memperbaiki navigasi screen reader. |
| `api-and-interface-design` | Panduan merancang API dan kontrak antarmuka modul yang stabil, modular, dan memisahkan batasan frontend/backend secara tegas. | Digunakan saat merancang endpoint REST/GraphQL, mendefinisikan tipe data antar-modul, atau arsitektur boundary. |
| `browser-testing-with-devtools` | Melakukan pengujian browser nyata menggunakan Chrome DevTools Protocol untuk inspeksi DOM, log konsol, dan analisis jaringan. | Digunakan saat memverifikasi bug tampilan, memantau error konsol, atau menguji alur pengguna di browser nyata. |
| `ci-cd-and-automation` | Mengotomatisasi konfigurasi pipeline CI/CD, menetapkan gerbang kendali mutu (*quality gates*), dan strategi deployment bertahap. | Digunakan saat menyiapkan alur build otomatis di GitHub Actions, GitLab CI, atau mengonfigurasi test runner otomatis. |
| `code-review-and-quality` | Melakukan tinjauan kualitas kode multi-dimensi (standar gaya, kesesuaian spesifikasi, keamanan, dan maintainability). | Digunakan sebelum menggabungkan pull request atau menyelesaikan implementasi fitur penting. |
| `code-simplification` | Menyederhanakan struktur kode yang terlalu berbelit-belit agar mudah dibaca dan dirawat tanpa mengubah perilaku aplikasinya. | Digunakan saat kode bekerja dengan baik namun sulit dipahami, memiliki nesting terlalu dalam, atau over-complex. |
| `constraint-driven-development` | Menetapkan standar mutu proyek sebagai kontrak tertulis dalam `CONSTRAINTS.md` agar agen tidak melemahkan batas pengujian. | Digunakan saat memulai proyek baru untuk mengunci batas toleransi performa dan standar kualitas minimum. |
| `context-engineering` | Mengoptimalkan penyiapan konteks agen, menata berkas aturan (*rules*), dan membuang instruksi berlebih yang membingungkan. | Digunakan saat memulai sesi baru atau ketika kualitas keluaran agen mulai menurun akibat konteks yang terlalu padat. |
| `debugging-and-error-recovery` | Menuntun pelacakan akar masalah (*root-cause debugging*) secara metodis saat build gagal atau pengujian rusak. | Digunakan saat menghadapi error runtime tak terduga, exception fatal, atau kegagalan kompilasi. |
| `deprecation-and-migration` | Mengelola proses penonaktifan sistem lama (deprekasi) dan migrasi pengguna ke implementasi baru tanpa gangguan layanan. | Digunakan saat memensiunkan endpoint API lama, menghapus modul usang, atau migrasi skema database produksi. |
| `documentation-and-adrs` | Mendokumentasikan keputusan arsitektur (ADR), mencatat rasionalitas desain teknis, dan mencegah dokumentasi usang (*drift*). | Digunakan saat mengambil keputusan teknis mendasar, merilis fitur besar, atau merapikan arsip ADR proyek. |
| `doubt-driven-development` | Menguji setiap keputusan arsitektural penting melalui tinjauan kritis (*adversarial review*) guna mengungkap kelemahan tersembunyi. | Digunakan sebelum berkomitmen pada desain sistem yang berisiko tinggi atau arsitektur yang sulit diubah. |
| `frontend-ui-engineering` | Membangun antarmuka pengguna (UI) modern, responsif, aksesibel (WCAG), dan mengelola status state secara efisien. | Digunakan saat membuat komponen UI baru, menata layout responsif, atau menyempurnakan interaksi pengguna. |
| `git-workflow-and-versioning` | Menstandarisasi alur kerja Git: commit atomik, strategi percabangan, resolusi konflik, pull request, dan rilis semantik. | Digunakan saat mengatur branching model tim, menyiapkan rilis versi, atau merapikan riwayat commit. |
| `idea-refine` | Mempertajam ide mentah menjadi konsep teknis yang terstruktur melalui eksplorasi divergen dan konvergen. | Digunakan saat ide fitur masih kabur atau memerlukan pengujian asumsi sebelum menyusun rencana kerja. |
| `incremental-implementation` | Menerapkan perubahan besar dalam irisan tipis (*thin slices*) yang dapat diuji dan diverifikasi secara bertahap. | Digunakan saat membangun fitur besar yang menyentuh banyak berkas atau di balik feature flag. |
| `interview-me` | Menggali kebutuhan teknis pengguna melalui wawancara terarah satu per satu pertanyaan saat arahan awal masih ambigu. | Digunakan di awal percakapan ketika kebutuhan proyek belum terdefinisi secara spesifik. |
| `observability-and-instrumentation` | Menambahkan instrumentasi logging, metrik, jejak (*tracing*), dan alert agar perilaku sistem di produksi terpantau jelas. | Digunakan saat merilis fitur ke produksi atau saat terjadi insiden di mana log yang ada kurang informatif. |
| `performance-optimization` | Mengoptimalkan performa aplikasi secara menyeluruh: Core Web Vitals, eliminasi kueri N+1, dan profiling memori/CPU. | Digunakan saat aplikasi mengalami lag, waktu muat halaman lambat, atau konsumsi memori berlebih. |
| `planning-and-task-breakdown` | Memecah spesifikasi atau proyek besar menjadi urutan tugas implementasi yang terstruktur dan terukur. | Digunakan saat spesifikasi teknis sudah jelas dan ingin memecahnya menjadi daftar langkah pengerjaan berurutan. |
| `security-and-hardening` | Memperkuat keamanan aplikasi terhadap celah OWASP Top 10, validasi input, sanitasi data, dan audit dependensi eksternal. | Digunakan saat membangun endpoint sensitif (autentikasi, pembayaran) atau sebelum audit keamanan. |
| `shipping-and-launch` | Mempersiapkan peluncuran ke produksi: daftar periksa pra-rilis (*pre-launch checklist*), monitoring, dan rencana rollback. | Digunakan menjelang rilis aplikasi ke lingkungan produksi guna memastikan kesiapan operasional. |
| `source-driven-development` | Mendasarkan setiap keputusan implementasi langsung pada dokumentasi resmi dan sumber otoritatif terkini. | Digunakan saat membangun fitur menggunakan framework baru atau ingin kode bebas dari pola usang. |
| `spec-driven-development` | Menyusun spesifikasi dan dokumen kebutuhan produk (PRD/spec) secara tuntas sebelum menulis baris kode pertama. | Digunakan saat memulai fitur baru yang kompleks agar arsitektur dan perilakunya disepakati terlebih dahulu. |
| `test-driven-development` | Menerapkan siklus pengembangan Red-Green-Refactor yang ketat untuk memastikan seluruh kode teruji secara otomatis. | Digunakan saat membangun logika bisnis penting atau memperbaiki bug secara test-first. |
| `using-agent-skills` | Menemukan, memilih, dan memanggil skill yang paling relevan dengan kebutuhan tugas yang sedang dikerjakan. | Digunakan di awal sesi kerja untuk menentukan alur kerja atau skill terbaik yang harus diaktifkan. |

---

### Paket 5: Engineering & Productivity (39 Skill)

Koleksi skill tingkat lanjut (Matt Pocock dkk.) untuk wawancara teknis intensif (*grilling*), pemecahan tugas ke tiket spesifikasi, pemodelan domain, dan refactoring modularitas tinggi.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `ask-matt` | Memetakan dan merekomendasikan skill atau alur kerja paling tepat untuk kebutuhan masalah tertentu di repositori. | Digunakan saat bingung menentukan alur kerja atau skill engineering mana yang harus dipilih. |
| `chief-of-staff` | Koordinasi tingkat eksekutif, orkestrasi meta-level, dan penyelarasan prioritas strategis lintas tugas. | Digunakan saat mengelola proyek multi-fase yang membutuhkan pengawasan strategi dan alokasi prioritas. |
| `claude-handoff` | Menyerahkan percakapan aktif ke agen latar belakang baru agar pekerjaan dapat dilanjutkan secara mandiri. | Digunakan saat percakapan sudah terlalu panjang dan perlu didelegasikan ke sesi agen yang segar. |
| `codebase-design` | Panduan kosakata dan perancangan modul mendalam (*deep modules*), antarmuka ramping, dan modularitas tinggi. | Digunakan saat merancang antarmuka modul baru atau mencari peluang memperdalam modul yang dangkal. |
| `code-review` | Tinjauan komparatif sejak titik tertentu (commit/branch) berdasarkan standar kode repositori dan kesesuaian spesifikasi. | Digunakan saat memeriksa pekerjaan pada cabang pengembangan (*feature branch*) atau pull request. |
| `diagnosing-bugs` | Siklus diagnosis sistematis untuk bug kompleks, kegagalan intermiten, dan regresi performa sebelum menulis perbaikan. | Digunakan saat menghadapi bug sulit atau ketika sistem melempar error yang belum diketahui penyebabnya. |
| `domain-modeling` | Membangun dan menyelaraskan model domain bisnis dalam repositori, merapikan `GLOSSARY.md`, dan merekam ADR. | Digunakan saat mendiskusikan terminologi domain bisnis atau merancang struktur entitas data utama. |
| `git-guardrails-claude-code` | Menyiapkan hook pencegah eksekusi perintah Git yang berpotensi destruktif (seperti `push`, `reset --hard`, `clean`). | Digunakan saat ingin memblokir operasi git berbahaya agar tidak dieksekusi secara tidak sengaja oleh AI. |
| `grilling` | Melakukan wawancara kritis tanpa kompromi untuk menguji ketahanan rencana, keputusan arsitektur, atau ide baru. | Digunakan saat ingin menguji ketangguhan asumsi desain teknis sebelum mulai mengeksekusi rencana. |
| `grill-me` | Sesi wawancara intensif terfokus untuk mematangkan dan menguji logika rencana desain teknis. | Digunakan saat pengguna meminta diuji pemikirannya melalui tanya jawab kritis. |
| `grill-with-docs` | Wawancara kritis untuk mematangkan desain teknis yang sekaligus otomatis mendokumentasikan hasilnya ke ADR dan glosarium. | Digunakan saat ingin menguji rencana sekaligus menghasilkan dokumentasi arsitektur resmi. |
| `handoff` | Memadatkan riwayat percakapan saat ini menjadi dokumen ringkasan estafet (*handoff document*) untuk sesi berikutnya. | Digunakan saat hendak berganti sesi atau mengalihkan pekerjaan ke rekan tim/agen lain. |
| `implement` | Mengimplementasikan pekerjaan teknis berdasarkan dokumen spesifikasi atau daftar tiket yang telah disepakati. | Digunakan saat spesifikasi sudah final dan siap dieksekusi menjadi baris kode nyata. |
| `implement-spec` | Menulis kode program langsung berdasarkan hasil sintesis spesifikasi `/to-spec` dan tiket `/to-tickets`. | Digunakan saat mengeksekusi rencana kerja yang bersumber dari issue tracker atau spesifikasi formal. |
| `improve-codebase-architecture` | Memindai arsitektur kode untuk menemukan peluang pembuatan *deep modules* dan menyajikannya dalam laporan perbaikan. | Digunakan saat ingin melakukan audit arsitektur kode atau menyusun roadmap perbaikan modularitas. |
| `loop-me` | Menggali spesifikasi alur kerja yang ingin dibangun secara mendalam dan berulang di lingkungan workspace. | Digunakan saat merumuskan alur kerja otomasi yang spesifik pada proyek lokal saat ini. |
| `migrate-to-shoehorn` | Memigrasikan file pengujian dari *type assertion* `as` yang rapuh ke utilitas `@total-typescript/shoehorn`. | Digunakan saat membersihkan type assertion palsu pada pengujian TypeScript demi keakuratan data tes. |
| `pr` | Membantu merumuskan deskripsi dan ringkasan perubahan Pull Request yang jelas, padat, dan informatif bagi reviewer. | Digunakan saat menulis deskripsi body PR sebelum mengajukan code review ke tim. |
| `prototype` | Membangun prototipe kilat (*throwaway prototype*) untuk memvalidasi alur antarmuka, model state, atau kelayakan teknis. | Digunakan saat ingin memastikan kelayakan suatu ide desain sebelum berinvestasi pada kode produksi. |
| `research` | Melakukan investigasi mendalam terhadap pertanyaan teknis berdasarkan dokumentasi resmi dan mencatatnya ke repositori. | Digunakan saat membutuhkan riset mendalam terhadap library baru, dokumentasi API, atau standar teknis. |
| `retro` | Mengadakan sesi retrospektif evaluasi terhadap sesi pengkodean yang baru selesai untuk mencatat pembelajaran. | Digunakan setelah menyelesaikan milestone besar untuk mengevaluasi apa yang berjalan lancar dan apa yang perlu ditingkatkan. |
| `scaffold-exercises` | Menyusun kerangka direktori latihan pemrograman terstruktur (masalah, solusi, dan penjelasan konsep) yang lolos linting. | Digunakan saat menyusun materi edukasi koding, latihan teknis tim, atau kurikulum pembelajaran. |
| `setup-matt-pocock-skills` | Mengonfigurasi lingkungan repositori untuk ekosistem engineering skills (issue tracker, label triage, docs layout). | Digunakan saat menyiapkan repositori baru agar terintegrasi penuh dengan seluruh alur kerja Matt Pocock. |
| `setup-pre-commit` | Menyiapkan hook pre-commit Husky dengan lint-staged (Prettier), type check, dan pengujian otomatis sebelum commit. | Digunakan saat ingin menambahkan pengecekan kualitas kode otomatis sebelum perubahan di-commit ke Git. |
| `setup-ts-deep-modules` | Mengonfigurasi `dependency-cruiser` agar setiap paket bertindak sebagai *deep module* yang terisolasi rapi. | Digunakan pada proyek TypeScript monorepo/modular agar dependensi antar-paket tidak saling bocor. |
| `software-factory` | Menjalankan siklus otomatisasi pabrikasi perangkat lunak berstandar industri dengan loop verifikasi mandiri. | Digunakan saat ingin mengotomatisasi pipeline pembuatan dan verifikasi komponen perangkat lunak skala besar. |
| `tdd` | Menerapkan metodologi Test-Driven Development (TDD) untuk membangun fitur baru atau perbaikan bug secara test-first. | Digunakan saat ingin menulis tes sebelum kode implementasi pada proyek non-Rust. |
| `teach` | Membimbing dan mengajarkan konsep pemrograman atau keterampilan teknis baru secara interaktif kepada pengguna. | Digunakan saat pengguna ingin memahami cara kerja suatu pola arsitektur, algoritma, atau fitur bahasa. |
| `to-questionnaire` | Mengubah keputusan teknis yang belum memiliki jawaban pasti menjadi kuesioner terstruktur untuk pemangku kepentingan. | Digunakan saat membutuhkan klarifikasi keputusan teknis dari klien atau tim arsitektur. |
| `to-spec` | Menyintesis hasil diskusi percakapan saat ini menjadi dokumen spesifikasi teknis formal di issue tracker. | Digunakan saat diskusi rancangan fitur selesai dan siap diformalkan menjadi dokumen spesifikasi. |
| `to-tickets` | Memecah spesifikasi menjadi serangkaian tiket pekerjaan mandiri (*tracer-bullet tickets*) beserta pemblokir dependensinya. | Digunakan setelah dokumen spesifikasi disetujui dan siap dibagi ke dalam tiket implementasi. |
| `triage` | Memproses antrean isu dan PR eksternal melalui *state machine*, memverifikasi masalah, dan menyusun ringkasan kerja. | Digunakan saat mengelola antrean issue tracker open-source atau backlog proyek tim. |
| `wait-what` | Berhenti sejenak ketika pesan sebelumnya menyimpang, lalu merumuskan kembali penjelasan dengan pendekatan yang lebih jernih. | Digunakan saat ada kebingungan konseptual dan perlu mengulang penjelasan dari sudut pandang mendasar. |
| `wayfinder` | Merencanakan proyek skala besar yang melampaui kapasitas satu sesi percakapan sebagai peta tiket keputusan terkoordinasi. | Digunakan saat mengelola inisiatif rekayasa besar yang memerlukan navigasi peta jalan bertahap. |
| `wizard` | Menghasilkan skrip pemandu interaktif (*wizard*) untuk langkah-langkah yang membutuhkan otorisasi manual manusia. | Digunakan saat memandu konfigurasi cloud, input kredensial rahasia, atau migrasi data sensitif. |
| `writing-beats` | Mengembangkan tulisan teknis dengan merangkai poin-poin mentah menjadi alur gagasan terurut (*beats*) yang logis. | Digunakan saat menyusun kerangka tulisan artikel teknis, RFC, atau panduan arsitektur. |
| `writing-for-agents` | Menyusun dokumen instruksi khusus untuk agen AI (seperti skill baru, `AGENTS.md`, atau `CLAUDE.md`). | Digunakan saat membuat atau memperbarui aturan instruksi yang ditujukan untuk dipatuhi oleh agen AI. |
| `writing-fragments` | Menggali ide-ide mentah dan poin-poin kunci bebas tanpa memaksakan struktur formal terlebih dahulu. | Digunakan saat proses brainstorming tulisan teknis di tahap paling awal. |
| `writing-shape` | Membentuk fragmen materi mentah menjadi draf artikel atau dokumentasi utuh yang tertata paragraf demi paragraf. | Digunakan saat merangkai kumpulan catatan mentah menjadi draf dokumen teknis yang kohesif. |

---

### Paket 6: RTK Specialist (13 Skill)

Skill audit, triage PR/isu GitHub, penyederhanaan kode Rust secara idiomatis, dan manajemen pengujian filter CLI token optimizer.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `code-simplifier` | Meninjau kode Rust pada RTK untuk penyederhanaan idiomatis: memangkas alokasi mubazir dan menyederhanakan pattern. | Digunakan saat merawat atau merefactor basis kode Rust pada filter RTK agar lebih efisien. |
| `design-patterns` | Panduan pola desain Rust untuk modul filter RTK (Newtype, Builder, RAII, Trait Objects, State Machine). | Digunakan saat mendesain modul filter baru atau merestrukturisasi modul CLI yang sudah ada. |
| `issue-triage` | Mengaudit isu terbuka di GitHub: kategorisasi, deteksi duplikat, penilaian risiko keamanan, dan draf komentar. | Digunakan saat melakukan audit dan pemilahan backlog issue pada repositori open-source. |
| `performance` | Menganalisis dan mengoptimalkan performa CLI RTK (startup time <10ms, memory footprint <5MB, benchmark token). | Digunakan saat menguji benchmark kecepatan CLI atau menyelidiki peningkatan penggunaan memori. |
| `pr-review` | Tinjauan bertahap terhadap Pull Request berdasarkan tingkat kompleksitas (XS hingga L) dan analisis konteks diff. | Digunakan saat memeriksa usulan perubahan kode pull request yang masuk dari kontributor. |
| `pr-triage` | Mengaudit dan men-triage Pull Request terbuka, inspeksi mendalam pada PR terpilih, dan menyusun draf ulasan. | Digunakan saat mengelola antrean PR yang menumpuk untuk dipilah berdasarkan prioritas review. |
| `repo-recap` | Menghasilkan ringkasan komprehensif status repositori (PR, isu, rilis, changelog) yang siap dibagikan ke tim. | Digunakan saat menyiapkan laporan mingguan atau ringkasan status perkembangan proyek untuk tim. |
| `rtk-tdd` | Menerapkan siklus TDD (Red-Green-Refactor) berbasis idiom Rust dengan pustaka `anyhow`/`thiserror` dan `cfg(test)`. | Digunakan saat mengimplementasikan fitur, modul, atau perbaikan bug pada aplikasi Rust. |
| `rtk-triage` | Triage lengkap RTK yang memadukan audit isu dan PR secara paralel untuk mendeteksi tumpang tindih penanganan. | Digunakan saat sinkronisasi berkala backlog GitHub untuk menjaga kualitas repositori. |
| `security-guardian` | Analisis keamanan CLI untuk RTK: proteksi terhadap command injection, sanitasi shell escaping, dan keamanan hook. | Digunakan saat meninjau kode CLI yang mengeksekusi shell atau menangani masukan perintah pengguna. |
| `ship` | Alur kerja otomatisasi rilis: verifikasi build, version bump semantik, pembaruan changelog, git tag, dan trigger CI/CD. | Digunakan saat mempublikasikan versi rilis baru dari paket perangkat lunak ke produksi. |
| `tdd-rust` | Alur kerja TDD khusus untuk pengembangan filter RTK: uji snapshot dengan `insta` dan validasi batas hemat token. | Digunakan saat membuat modul filter baru untuk memvalidasi rasio pemangkasan teks output terminal. |
| `rtk` | Meta-skill integrasi proxy CLI RTK untuk memotong keluaran terminal redundan secara transparan hingga 90%. | Digunakan otomatis saat agen menjalankan perintah shell, build proyek, atau pengujian otomatis. |

---

### Paket 7: REA - Reverse Engineering Anything (5 Skill)

Alat rekayasa balik (*reverse engineering*) tingkat lanjut untuk target biner native, aplikasi Electron/JavaScript terkompilasi, firmware, dan browser, serta perancangan lingkungan runtime agen.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `rea-analysis-optimization` | Menganalisis dan mengoptimalkan alur kerja investigasi rekayasa balik target biner atau bundel aplikasi. | Digunakan saat proses dekompilasi atau analisis biner mengalami bottleneck performa atau latensi. |
| `rea-changelog-update` | Mengelola pembaruan changelog dan sinkronisasi versi rilis pada perkakas REA berdasarkan riwayat Git. | Digunakan saat menyiapkan catatan rilis dan dokumentasi perubahan versi pada proyek REA. |
| `rea-ci-tests-audit` | Mengaudit pengujian CI/CD dan memverifikasi kelayakan runtime paket analisis REA dari false-pass. | Digunakan saat mengaudit integritas test suite atau alur continuous integration pada REA. |
| `rea-tool-design` | Panduan perancangan antarmuka tool agen REA, skema input, dan penanganan bukti eksekusi (*evidence*). | Digunakan saat merancang kontrak MCP baru, menambah provider analisis, atau merombak kapabilitas tool. |
| `reverse-engineer-anything` | Rekayasa balik target biner native, aplikasi Electron, runtime browser, dan pembuatan lingkungan agen (AgentEnv). | Digunakan saat menganalisis biner tertutup, mengekstrak logika aplikasi terkompilasi, atau investigasi runtime. |

---

### Paket 8: Apple Design, Motion & UI Polish (19 Skill)

Filosofi perancangan antarmuka visual kelas dunia Apple dan Emil Kowalski: fisika gerak fluida, mikro-animasi berperforma tinggi (60/120 FPS), interaksi sentuh mobile native, dan arsitektur Swift modern.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `animate` | Merancang animasi antarmuka dari awal: menentukan kurva easing, timing spring, durasi, dan transisi keluar. | Digunakan saat ingin membangun animasi komponen baru, transisi halaman, atau membuat UI terasa hidup. |
| `animate-expo` | Membangun animasi di React Native dan Expo menggunakan Reanimated, Gesture Handler, dan haptics perangkat. | Digunakan saat mengembangkan aplikasi mobile React Native/Expo yang membutuhkan animasi 60fps mulus. |
| `animation-performance` | Menjaga animasi web tetap mulus di dalam batas frame budget (60/120fps) dengan animasi composite-only. | Digunakan saat animasi terasa patah-patah (*jank*) atau membebani CPU main-thread browser. |
| `animation-vocabulary` | Glosarium pencarian terbalik untuk menerjemahkan deskripsi efek visual menjadi istilah teknis motion yang presisi. | Digunakan saat mengetahui efek visual yang diinginkan namun tidak tahu nama teknisnya untuk diprompt. |
| `apple-design` | Menerapkan filosofi desain antarmuka Apple: gerak fluida fisik, pegas kenyal, gestur swipe, dan material translusen. | Digunakan saat membangun antarmuka web bergaya Apple dengan nuansa interaksi fisik yang halus dan responsif. |
| `ask-emil` | Panduan filosofi desain dan *craftsmanship* UI Emil Kowalski untuk detail mikro antarmuka perangkat lunak. | Digunakan saat ingin mengkonsultasikan keputusan desain antarmuka, hover states, atau popover origin. |
| `ask-sonner` | Panduan lengkap pustaka toast React Sonner: Toaster setup, promise toast, custom theme, posisi, dan modal layering. | Digunakan saat memasang, menata gaya, atau memecahkan kendala notifikasi toast Sonner pada React. |
| `break-ui` | Menguji ketahanan komponen UI terhadap data kasus terburuk (*stress test*): string panjang, angka ekstrim, zero-items. | Digunakan saat melakukan audit ketahanan tampilan sebelum merilis komponen UI ke publik. |
| `choreograph` | Mengoordinasikan koreografi animasi multi-elemen yang berurutan (*staggered entrance/exit*) secara harmonis. | Digunakan saat menganimasikan daftar item kartu, menu dropdown, atau elemen hero yang masuk bertahap. |
| `emil-design-eng` | Filosofi rekayasa antarmuka Emil Kowalski: detail mikro, press states, origin popover, dan sentuhan visual tak kasat mata. | Digunakan saat memoles komponen UI agar terasa seperti software kelas dunia dan tidak kaku. |
| `find-animation-opportunities` | Memindai antarmuka atau kode untuk menemukan elemen-elemen statis yang layak diberi sentuhan mikro-animasi. | Digunakan saat aplikasi terasa terlalu datar/kaku dan ingin mencari peluang menambahkan transisi yang bermakna. |
| `gestures` | Mengimplementasikan interaksi berbasis gestur sentuh (drag, swipe, pinch, sheet pull) dengan pegas fisik kenyal. | Digunakan saat membuat komponen bottom sheet, swipeable card, atau navigasi gestur mobile. |
| `improve-animations` | Mengaudit kode animasi di seluruh repositori dan menyusun rencana peningkatan kualitas gerak secara terstruktur. | Digunakan saat ingin melakukan audit menyeluruh terhadap performa dan rasa animasi di seluruh aplikasi. |
| `learn-taste` | Menumbuhkan intuisi estetika, kepekaan visual, dan standar selera desain antarmuka modern. | Digunakan saat mengevaluasi nilai estetika antarmuka atau mempertajam penilaian kualitas visual produk. |
| `mobile-native` | Teknik CSS dan meta-tag agar aplikasi web terasa seperti aplikasi native smartphone (anti zoom glitch, no touch lag). | Digunakan saat mengoptimalkan PWA atau web app agar memiliki kenyamanan sentuh setara aplikasi native. |
| `pick-ui-library` | Merekomendasikan pustaka komponen frontend terbaik, teringan, dan paling tepat untuk kebutuhan spesifik. | Digunakan saat memilih komponen pustaka UI (misal headless UI, popover, date picker) tanpa membebani bundle. |
| `remove-animations` | Menghapus animasi yang tidak perlu, berlebihan, atau mengganggu performa dan menggantinya dengan transisi bersih. | Digunakan saat antarmuka terasa lambat, animasi terlalu lama, atau mengganggu aksesibilitas pengguna. |
| `review-animations` | Tinjauan kritis terhadap implementasi kode animasi berdasarkan standar fisika gerak, frame rate, dan interupsi gestur. | Digunakan saat mereview pull request yang menambahkan animasi untuk memastikan kehalusan gerak. |
| `write-swift` | Rekayasa modern Swift: pemodelan value types, keamanan data-race Swift 6 (@concurrent, actors), dan optimasi alokasi ARC. | Digunakan saat menulis, mereview, atau memigrasikan kode Swift native ke standar Swift 6 terkini. |

---

### Paket 9: Security Audit & Pen-Testing (1 Skill)

Audit keamanan mendalam, deteksi kerentanan OWASP, analisis API, sanitasi masukan tidak tepercaya, dan pengujian penetrasi menyeluruh.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `security-audit` | Panduan audit keamanan dan tinjauan kerentanan untuk basis kode, API, layanan background, CLI, dan dependensi pihak ketiga. | Digunakan saat melakukan audit keamanan berkala, pen-testing internal, atau sebelum audit kepatuhan resmi. |

---

### Paket 10: Superpowers Agentic Workflow (15 Skill)

Metodologi rekayasa perangkat lunak agentik komprehensif oleh Jesse Vincent (`obra/superpowers`). Mengarahkan agen untuk bekerja dengan disiplin rekayasa tingkat tinggi: brainstorming terstruktur sebelum coding, perencanaan implementasi bertahap (*spec-driven*), TDD ketat, isolasi git worktrees, eksekusi sub-agen paralel, tinjauan kode adversarial, dan verifikasi bukti sebelum menyelesaikan tugas.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `brainstorming` | Menuntun eksplorasi kreatif terstruktur sebelum pekerjaan coding dimulai guna mematangkan spesifikasi dan tujuan. | Wajib digunakan sebelum membuat fitur baru, membangun komponen, memodifikasi perilaku, atau merancang arsitektur. |
| `diagnosing-superpowers` | Mendiagnosis kendala atau kegagalan pada sesi superpowers (kerja berulang, rencana diabaikan, atau konsumsi token). | Digunakan saat alur kerja agen mengalami kendala, instruksi tidak dipatuhi, atau sesi terasa lambat. |
| `dispatching-parallel-agents` | Mendelegasikan 2 atau lebih tugas independen ke sub-agen paralel tanpa status bersama (*shared state*). | Digunakan saat menghadapi beberapa pekerjaan mandiri yang dapat diselesaikan bersamaan secara efisien. |
| `executing-plans` | Mengeksekusi rencana implementasi secara terstruktur langkah demi langkah dalam sesi aktif saat ini. | Digunakan saat mengeksekusi rencana kerja yang telah disetujui secara bertahap di sesi lokal. |
| `finishing-a-development-branch` | Panduan mengintegrasikan cabang pengembangan setelah implementasi selesai dan seluruh pengujian lolos. | Digunakan saat implementasi tuntas dan perlu memutuskan strategi integrasi cabang (merge, rebase, PR). |
| `receiving-code-review` | Menanggapi masukan tinjauan kode secara kritis dan terverifikasi secara teknis sebelum menerapkan saran. | Digunakan saat menerima saran review kode agar tidak menerapkan perubahan secara membabi buta. |
| `requesting-code-review` | Mengajukan permohonan tinjauan kode setelah menyelesaikan tugas besar atau sebelum melakukan merge. | Digunakan saat menyelesaikan tugas besar guna memastikan kode memenuhi seluruh kriteria spesifikasi. |
| `subagent-driven-development` | Mengeksekusi rencana implementasi modular dengan mendelegasikan tugas-tugas mandiri ke sub-agen khusus. | Digunakan saat mengeksekusi rencana implementasi yang memiliki tugas-tugas independen terpisah. |
| `systematic-debugging` | Investigasi sistematis untuk menemukan akar masalah (*root cause*) sebelum mengajukan perbaikan bug. | Digunakan saat menghadapi bug, kegagalan tes, atau perilaku sistem tak terduga sebelum menyentuh kode. |
| `test-driven-development` | Menggerakkan pengembangan dengan siklus Red-Green-Refactor yang ketat sebelum menulis baris kode implementasi. | Digunakan saat membangun fitur atau memperbaiki bug berbasis pengujian otomatis yang andal. |
| `using-git-worktrees` | Menyiapkan isolasi lingkungan kerja menggunakan git worktree sebelum mengeksekusi rencana atau fitur berisiko. | Digunakan sebelum memulai pekerjaan fitur baru yang membutuhkan isolasi ketat dari cabang kerja saat ini. |
| `using-superpowers` | Menetapkan protokol penemuan dan aktivasi skill superpowers di awal percakapan sebelum memberikan respon. | Digunakan di awal setiap sesi percakapan untuk memastikan kesiapan metodologi agen. |
| `verification-before-completion` | Mengharuskan verifikasi bukti empiris (*evidence*) melalui perintah terminal sebelum mengklaim pekerjaan selesai. | Wajib digunakan sebelum menyatakan pekerjaan selesai, bug diperbaiki, atau sebelum membuat commit/PR. |
| `writing-plans` | Menyusun rencana implementasi detail berbasis spesifikasi lengkap dengan langkah verifikasi sebelum coding. | Digunakan saat memiliki spesifikasi kebutuhan dan ingin memecahnya ke rencana implementasi konkret. |
| `writing-skills` | Merancang, menulis, memvalidasi sintaks frontmatter, dan menguji coba skill agen baru sebelum didistribusikan. | Digunakan saat membuat skill baru, mengedit skill yang ada, atau memverifikasi kompatibilitas skill. |

---

### Paket 11: Chrome DevTools & Browser Automation (8 Skill)

Perkakas resmi dari tim Chrome DevTools (`ChromeDevTools/chrome-devtools-mcp`) untuk inspeksi browser mendalam, otomatisasi pengujian antarmuka, profil performa Core Web Vitals, audit aksesibilitas, dan diagnosis memori runtime melalui protokol Chrome DevTools MCP.

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `a11y-debugging` | Audit dan debugging aksesibilitas (a11y) sesuai standar WCAG & web.dev: semantik HTML, ARIA label, fokus, dan kontras. | Digunakan saat menguji kepatuhan aksesibilitas, navigasi keyboard, dan kenyamanan pengguna disabilitas. |
| `chrome-devtools` | Mengoperasikan Chrome DevTools via MCP untuk otomasi browser, evaluasi DOM, inspeksi jaringan, dan interaksi web. | Digunakan saat mengotomatisasi interaksi web, menelusuri elemen DOM, atau menganalisis lalu lintas jaringan. |
| `chrome-devtools-cli` | Panduan menulis skrip shell dan otomasi CLI untuk berinteraksi langsung dengan Chrome DevTools. | Digunakan saat ingin menjalankan perintah otomatisasi browser langsung dari terminal command-line. |
| `cookie-debugging` | Inspeksi, debugging, dan pengujian cookies, status sesi, otentikasi (401/403), SameSite, dan banner privasi. | Digunakan saat mendiagnosis kendala sesi login kedaluwarsa, cookie pihak ketiga, atau otentikasi gagal. |
| `debug-optimize-lcp` | Diagnosis dan optimasi Largest Contentful Paint (LCP) dan Core Web Vitals untuk mempercepat rendering konten utama. | Digunakan saat halaman web memuat lambat atau metrik Largest Contentful Paint (LCP) perlu ditingkatkan. |
| `inspect-in-devtools` | Menghubungkan agen ke antarmuka Chrome DevTools untuk inspeksi visual interaktif dan Q&A elemen halaman. | Digunakan saat ingin melihat panel DevTools secara visual atau meninjau elemen DOM yang dipilih pengguna. |
| `memory-leak-debugging` | Diagnosis dan perbaikan kebocoran memori (*memory leaks*) aplikasi JavaScript/Node.js melalui heap snapshot. | Digunakan saat aplikasi mengalami lonjakan penggunaan RAM berlebih, OOM error, atau memory leak. |
| `troubleshooting` | Panduan penanganan kendala koneksi tab browser, inisialisasi server MCP, dan troubleshooting DevTools target. | Digunakan saat pemanggilan tool DevTools gagal terhubung atau halaman target tidak merespons. |

---

### Paket 12: Mobile Automation & Testing — ARTEMIS (1 Skill)

Framework multimodal resmi dari tim Google (`google/artemis`) untuk otomatisasi pengujian Android otonom, eksplorasi antarmuka aplikasi seluler secara interaktif, diagnostik Logcat/trace, dan orkestrasi perintah ADB melalui Model Context Protocol (MCP).

| Skill | Apa yang Dilakukan | Kapan Digunakan |
| :--- | :--- | :--- |
| `artemis` | Pengujian aplikasi Android otonom, eksplorasi UI lintas aplikasi, diagnostik Logcat/crash/ANR, dan otomasi ADB & MCP. | Digunakan saat mengotomasi pengujian aplikasi Android, menelusuri UI seluler, atau mendiagnosis crash native. |

---

## 💡 Cara Kerja & Panduan Penggunaan Skill

### 1. Pemanggilan Otomatis oleh Model (*Model-Invoked*)
Anda tidak perlu menghafal atau mengetikkan nama skill secara manual. Berikan instruksi dengan maksud yang jelas, agen akan secara cerdas mengenali skill yang relevan berdasarkan deskripsinya:
- *Contoh*: `"Tolong review PR ini apakah ada over-engineering dan kode yang bisa dihapus"` -> Agen otomatis mengaktifkan skill `ponytail-review` atau `code-simplification`.
- *Contoh*: `"Buatkan animasi pembuka halaman login yang smooth ala Apple"` -> Agen otomatis mengaktifkan skill `apple-design` atau `animate`.
- *Contoh*: `"Audit keamanan endpoint pembayaran ini terhadap OWASP"` -> Agen otomatis mengaktifkan skill `security-audit` atau `security-and-hardening`.
- *Contoh*: `"Stress-test form input ini dengan worst-case data"` -> Agen otomatis mengaktifkan skill `break-ui`.
- *Contoh*: `"Tolong eksplorasi dan buat skenario testing Android untuk alur checkout"` -> Agen otomatis mengaktifkan skill `artemis`.

### 2. Pemanggilan Eksplisit (*Explicit Invocation*)
Anda juga dapat secara langsung menyebutkan nama skill dalam pesan Anda:
- *Contoh*: `"Gunakan skill apple-design untuk memoles antarmuka modal ini."`
- *Contoh*: `"Jalankan caveman mode untuk respon kali ini agar hemat token."`
- *Contoh*: `"Gunakan skill security-audit untuk menguji kerentanan API."`
- *Contoh*: `"Gunakan skill artemis untuk mendiagnosis crash dan memeriksa Logcat perangkat Android."`

---
*Dokumen ini diperbarui secara berkala dan memetakan seluruh 164+ skill terpasang di ekosistem Google Antigravity dan multi-agent.*
