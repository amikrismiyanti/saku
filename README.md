# Finance Tracker — Tahap 1 (Dasar)

Stack: Flutter Web + Supabase + PWA, sesuai spesifikasi.

## Yang sudah jadi di tahap ini

- Struktur folder lengkap (`lib/app`, `core`, `models`, `providers`, `repositories`, `screens`, `widgets`)
- Tema Material 3 (light & dark)
- Routing dengan `go_router` + bottom navigation 5 tab (Home, Transaksi, Tambah, Laporan, Pengaturan)
- Model data: `TransactionModel`, `WalletModel`, `CategoryModel`, `BudgetModel`, `SavingsGoalModel`
- Repository layer ke Supabase (transactions, wallets, budgets, savings_goals)
- Provider (state management): `WalletProvider`, `TransactionProvider`
- Dashboard fungsional: saldo total, pemasukan/pengeluaran bulan ini, transaksi terbaru
- Halaman lain (Transaksi, Budget, Target Tabungan, Laporan, Dompet, Kalender, Pengaturan) — masih placeholder, akan diisi di Tahap 2–4
- SQL schema Supabase siap pakai (`supabase/schema.sql`)

## Cara menjalankan

### 1. Setup Supabase

1. Buat project baru di https://supabase.com
2. Buka **SQL Editor**, jalankan isi file `supabase/schema.sql`
3. Ambil **Project URL** dan **anon public key** dari Settings → API

### 2. Setup Flutter

Pastikan Flutter SDK sudah terpasang di komputer kamu (`flutter --version`).

```bash
cd finance_tracker
flutter pub get
```

### 3. Jalankan dengan kredensial Supabase

Supaya key tidak ke-hardcode di source code, jalankan pakai `--dart-define`:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxxxxxxxxxxxxxxx
```

Untuk build production:

```bash
flutter build web \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxxxxxxxxxxxxxxx
```

### 4. Deploy

Upload folder `build/web` ke Vercel atau Netlify. Untuk PWA, `flutter build web` sudah otomatis generate `manifest.json` dan service worker — tinggal cek `web/manifest.json` untuk ubah nama/icon aplikasi.

## Kenapa belum saya jalankan/test langsung?

Environment saya di sini tidak punya Flutter SDK dan tidak ada akses internet, jadi saya tidak bisa `flutter pub get` / `flutter run` / build untuk memverifikasi. Semua kode di atas ditulis manual mengikuti API Flutter, `supabase_flutter`, `go_router`, dan `provider` yang saya tahu — tapi tetap sebaiknya kamu jalankan `flutter analyze` begitu pertama kali `pub get` untuk menangkap typo kecil (nama parameter versi package bisa berubah antar rilis).

## Lanjut ke Tahap 2

Sesuai roadmap kamu:
- Halaman Tambah Pemasukan & Tambah Pengeluaran (form lengkap)
- Riwayat transaksi (list, edit, hapus, search, filter)
- Update saldo dompet otomatis saat transaksi ditambah/edit/hapus

Bilang aja kalau mau saya lanjutkan ke bagian itu.
