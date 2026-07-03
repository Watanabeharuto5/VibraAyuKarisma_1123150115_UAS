 — Aplikasi Dompet Digital Kampus

| Identitas       | Detail                                      |
| --------------- | ------------------------------------------- |
| **Nama**        | Vibra Ayu Karisma                           |
| **NIM**         | 1123150115                                  |
| **Kelas**       | TI SE P1                                    |
| **Mata Kuliah** | Pemrograman Aplikasi Mobile Lanjutan        |
| **Dosen**       | I Ketut Gunawan, S.Kom, M.T.I              |
| **Institusi**   | Global Institut                             |

Aplikasi dompet digital kampus yang terintegrasi dengan sistem pembayaran antar-aplikasi melalui **Deep Link**. Pengguna dapat melakukan **top up**, **transfer** ke sesama pengguna, dan membayar transaksi dari aplikasi toko (`koreanpop_album`) secara langsung.

---

## 🏛️ Arsitektur: Clean Architecture

Proyek **Emoney_** menggunakan pola **Clean Architecture** dengan pemisahan tanggung jawab yang tegas antara tiga lapisan utama, ditambah lapisan `core` untuk utilitas bersama.

### Prinsip Utama

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│         (UI: Pages, Widgets, BLoC State Manager)         │
├─────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER                          │
│       (Business Logic: Entities, Use Cases, Repo IF)     │
├─────────────────────────────────────────────────────────┤
│                     DATA LAYER                           │
│   (Data Source: API, Firebase, Model, Repo Implementation│
└─────────────────────────────────────────────────────────┘
```

> **Aturan Ketergantungan:** Lapisan dalam (Domain) **tidak boleh** bergantung pada lapisan luar (Data/Presentation). Data dan Presentation bergantung ke dalam, bukan ke luar.

---

### 📐 Penjelasan Tiap Lapisan

| Lapisan          | Tanggung Jawab                                                                                                  |
| ---------------- | --------------------------------------------------------------------------------------------------------------- |
| **Presentation** | Menampilkan UI kepada pengguna. Mengelola *state* menggunakan **BLoC (Business Logic Component)**. Tidak boleh mengandung logika bisnis apapun. |
| **Domain**       | Pusat logika bisnis murni. Berisi **Entity** (model murni tanpa anotasi), **Use Case** (satu fungsi bisnis per kelas), dan **Repository Interface** (kontrak abstrak). |
| **Data**         | Implementasi nyata dari kontrak di Domain. Berisi **Model** (dengan `fromJson/toJson`), **Data Source** (akses ke API/Firebase), dan **Repository Impl** (mengimplementasikan interface dari Domain). |
| **Core**         | Utilitas bersama yang tidak milik fitur manapun: konstanta, tema warna, *router*, *network client*, *error handling*. |
| **Injection**    | *Dependency Injection* menggunakan `get_it`. Mendaftarkan semua dependensi (Bloc, Use Case, Repository, Data Source) agar bisa diinjeksi ke mana saja. |

---

## 📁 Struktur Folder

```
kantong_saya/
├── lib/
│   ├── main.dart                          # Entry point aplikasi, inisialisasi DI & Firebase
│   ├── firebase_options.dart              # Konfigurasi Firebase
│   │
│   ├── core/                             # ⚙️ Utilitas & Konfigurasi Global
│   │   ├── constants/                    # Konstanta (string, URL, key)
│   │   ├── error/                        # Penanganan error terpusat (Failure, Exception)
│   │   ├── network/                      # HTTP client (Dio), interceptor token
│   │   ├── router/                       # Routing & navigasi (GoRouter)
│   │   ├── services/                     # Layanan global (DeeplinkCallbackService, NotifService)
│   │   ├── theme/
│   │   │   ├── app_colors.dart           # Palet warna (Hijau Emerald → Amber/Kuning)
│   │   │   ├── app_text_styles.dart      # Tipografi terpusat
│   │   │   └── app_theme.dart            # ThemeData Material 3
│   │   └── utils/                        # Fungsi utilitas (format angka, tanggal, dsb.)
│   │
│   ├── domain/                           # 🧠 Lapisan Domain (Logika Bisnis)
│   │   ├── entities/                     # Model murni tanpa serialisasi
│   │   │   └── user.dart                 # Entity User
│   │   ├── repositories/                 # Kontrak abstrak (interface)
│   │   │   └── auth_repository.dart      # Interface untuk AuthRepository
│   │   └── usecases/                     # Satu Use Case = satu fungsi bisnis
│   │       ├── auth/
│   │       │   ├── login_usecase.dart     # Login dengan email & password
│   │       │   ├── logout_usecase.dart    # Logout sesi
│   │       │   └── register_usecase.dart  # Registrasi akun baru
│   │       ├── account/                  # Use case manajemen akun
│   │       └── payment/                  # Use case pembayaran & transfer
│   │
│   ├── data/                             # 🗄️ Lapisan Data (Implementasi)
│   │   ├── datasources/                  # Sumber data nyata
│   │   │   ├── auth/
│   │   │   │   └── auth_remote_datasource.dart   # Akses Firebase Auth & Firestore
│   │   │   ├── account/                  # Datasource data akun & saldo
│   │   │   └── payment/                  # Datasource transaksi & histori
│   │   ├── models/                       # DTO (Data Transfer Object) dengan fromJson/toJson
│   │   │   ├── user_model.dart
│   │   │   └── transaction_model.dart
│   │   └── repositories/                 # Implementasi konkret dari interface Domain
│   │       └── auth_repository_impl.dart
│   │
│   ├── presentation/                     # 🖥️ Lapisan Presentasi (UI)
│   │   ├── blocs/                        # State Manager menggunakan BLoC
│   │   │   ├── auth/
│   │   │   │   ├── auth_bloc.dart        # Mengelola state login/logout/register
│   │   │   │   ├── auth_event.dart       # Event: LoginRequested, LogoutRequested, dll.
│   │   │   │   └── auth_state.dart       # State: AuthInitial, AuthLoading, AuthSuccess, dll.
│   │   │   ├── home/                     # BLoC untuk data saldo & histori di halaman utama
│   │   │   ├── payment/                  # BLoC untuk alur pembayaran merchant
│   │   │   └── account/                  # BLoC untuk data profil pengguna
│   │   ├── pages/                        # Halaman-halaman UI
│   │   │   ├── splash/                   # Splash screen (animasi loading)
│   │   │   ├── auth/
│   │   │   │   ├── login_page.dart       # Halaman login (Email/Password & Google)
│   │   │   │   └── register_page.dart    # Halaman registrasi akun
│   │   │   ├── home/
│   │   │   │   └── home_page.dart        # Dashboard utama (saldo, fitur, histori singkat)
│   │   │   ├── topup/                    # Alur top up saldo
│   │   │   ├── transfer/                 # Alur transfer ke pengguna lain
│   │   │   ├── payment/                  # Konfirmasi pembayaran umum
│   │   │   ├── merchant/
│   │   │   │   └── merchant_checkout_page.dart  # Halaman pembayaran dari deep link merchant
│   │   │   ├── history/                  # Riwayat seluruh transaksi
│   │   │   ├── account/                  # Profil & pengaturan akun
│   │   │   └── success/                  # Halaman konfirmasi transaksi berhasil
│   │   └── widgets/                      # Widget reusable
│   │       ├── app_logo.dart             # Logo Kantong Ku
│   │       └── feature_icon.dart         # Ikon fitur (Top Up, Transfer, dll.)
│   │
│   └── injection/
│       └── injection_container.dart      # 💉 Registrasi semua dependensi (get_it)
│
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml           # Intent Filter: dompetkampus://pay (Deep Link)
└── pubspec.yaml
```

---

## 🔄 Flow Aplikasi

### 1. Flow Autentikasi

```
Buka App
    │
    ▼
SplashPage (Cek sesi Firebase)
    │
    ├── Sudah Login ──────────────────▶ HomePage (Dashboard)
    │
    └── Belum Login ──────────────────▶ LoginPage
                                            │
                                  ┌─────────┴──────────┐
                                  │                    │
                            Email/Password       Google Sign-In
                                  │                    │
                                  └─────────┬──────────┘
                                            │
                                       Firebase Auth
                                            │
                                       AuthBloc emits
                                       AuthSuccess
                                            │
                                            ▼
                                        HomePage
```

### 2. Flow Pembayaran Merchant (Deep Link dari KoreanPop Store)

```
Aplikasi KoreanPop → Checkout → Pilih "Kantong Saya"
    │
    │  launchUrl("dompetkampus://pay?merchant_id=...&amount=...&callback=koreanpop://payment-callback")
    ▼
Android OS membuka Kantong Ku berdasarkan Intent Filter
    │
    ▼
MerchantCheckoutPage
    ├── Tampilkan detail merchant, nominal, & deskripsi
    ├── Pengguna input PIN konfirmasi
    │
    ├── Saldo cukup & PIN benar
    │       │
    │       ▼
    │   Backend memproses transaksi (debit saldo)
    │       │
    │       ▼
    │   DeeplinkCallbackService.notifySuccess()
    │       │
    │       ▼
    │   launchUrl("koreanpop://payment-callback?status=success&reference=INV-xxx")
    │       │
    │       ▼
    │   KoreanPop app: CartProvider menerima callback
    │   → POST /transactions/confirm ke backend toko
    │   → Status transaksi: "Selesai" ✅
    │
    └── Saldo tidak cukup / PIN salah / Batal
            │
            ▼
        DeeplinkCallbackService.notifyCancelled() / notifyFailed()
            │
            ▼
        launchUrl("koreanpop://payment-callback?status=cancelled&reference=INV-xxx")
            │
            ▼
        KoreanPop app: Status transaksi tetap "Pending"
        Tombol "Bayar Sekarang" tetap muncul di History ⏳
```

### 3. Flow Transfer Antar Pengguna

```
HomePage → Klik "Transfer"
    │
    ▼
Input Nomor Rekening Tujuan
    │
    ▼
Backend validasi: apakah penerima terdaftar?
    │
    ├── Tidak ditemukan → Tampilkan error
    │
    └── Ditemukan → TransferConfirmPage
                        │
                        ▼
                    Input Nominal & Keterangan
                        │
                        ▼
                    Input PIN Konfirmasi
                        │
                        ▼
                    Backend: debit pengirim, kredit penerima (atomic)
                        │
                        ▼
                    SuccessPage: Transaksi berhasil ✅
```

---

## 🛠️ Tech Stack

| Kategori            | Teknologi                              |
| ------------------- | -------------------------------------- |
| **Framework**       | Flutter (Dart)                         |
| **State Management**| BLoC (flutter_bloc)                   |
| **Backend**         | Go (Gin Framework) — `be-kantong-ku`   |
| **Autentikasi**     | Firebase Auth (Email/Password & Google)|
| **Database**        | Firestore + MySQL (via Go Backend)     |
| **HTTP Client**     | Dio                                    |
| **DI Container**    | get_it                                 |
| **Deep Link**       | app_links + Custom URI Scheme (`dompetkampus://`) |
| **Notifikasi**      | flutter_local_notifications            |
| **Routing**         | GoRouter                               |

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK ≥ 3.x
- Go ≥ 1.21
- MySQL Server berjalan
- Android Emulator / Perangkat fisik

### Backend (`be-kantong-ku`)
```bash
cd be-kantong-ku
go run main.go
# Server berjalan di http://localhost:8081
```

### Aplikasi Flutter
```bash
cd kantong_saya
flutter pub get
flutter run
```

---

## 🔗 Proyek Terkait

- **[koreanpop_album](https://github.com/Watanabeharuto5/UTS_VibraAyuKarisma_1123150115.git)** — Aplikasi toko K-Pop yang terintegrasi sebagai merchant dengan Kantong Ku

- **[backendkantongsaya](https://github.com/Watanabeharuto5/VibraAyuKarisma_1123150115_UAS_BeEmoney.git)** — Backend untuk aplikasi Kantong Ku

- **[Backend K-Pop](https://github.com/Watanabeharuto5/gin-firebase-backend-w5.git)** — Backend & Database untuk aplikasi K-Pop

- **[Aplikasi Kantong Ku](https://github.com/Watanabeharuto5/VibraAyuKarisma_1123150115_UAS.git)** — Aplikasi Emoney Kantong Ku


- **[Link Presentasi Youtube]([https://youtube.com/](https://www.youtube.com/watch?v=rwtJSPoUn_Q))** — Presentasi Youtube Fibra Cuantek _ 

- **[Link Presentasi Youtube](https://www.youtube.com/watch?v=rwtJSPoUn_Q)** — Presentasi Youtube Fibra Cuantek _ 


# UI Aplikasi Dompet ku & K-Pop Albums

* Tampilan ketika aplikasi berjalan

 Tampilan 1
<p align="center">

  <img src="assets/images/kantongku1_.png" width="200"/>
  <img src="assets/images/kantongku2_.png" width="200"/>
  <img src="assets/images/kantongku3_.png" width="200"/>
  <img src="assets/images/kantongku4_.png" width="200"/>
  <img src="assets/images/kantongku5_.png" width="200"/>
  <img src="assets/images/kantongku6_.png" width="200"/>
  <img src="assets/images/kantongku7_.png" width="200"/>
  <img src="assets/images/kantongku8_.png" width="200"/>
  <img src="assets/images/kantongku9_.png" width="200"/>
  <img src="assets/images/kantongku10_.png" width="200"/>

</p>
