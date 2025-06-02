# Bulk Finder

Aplikasi Flutter untuk membantu mencari toko-toko yang menjual barang dalam jumlah besar (bulk) dengan peta interaktif dan fitur komunitas.

## 🚀 Fitur Utama

- **Peta Interaktif**: Menampilkan lokasi toko-toko dengan marker yang bisa diklik
- **Authentication**: Sistem login/register untuk customer dan seller
- **Manajemen Toko**: Seller bisa mengelola toko mereka
- **Komunitas**: Fitur posting dan berbagi informasi
- **Search**: Pencarian toko dan produk
- **Profile Management**: Kelola profil pengguna

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Backend**: Supabase (Database, Auth, Storage)
- **State Management**: Provider
- **Maps**: Flutter Map dengan OpenStreetMap
- **Storage**: Supabase Storage untuk gambar

## 📋 Prerequisites

- Flutter SDK (versi 3.6.2 atau lebih baru)
- Dart SDK
- Akun Supabase
- Android Studio / VS Code
- Git

## 🔧 Installation & Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-username/bulk-finder.git
cd bulk-finder
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Supabase

1. Buat project baru di [Supabase](https://supabase.com)
2. Jalankan SQL script untuk membuat tabel (lihat file `SETUP_DATABASE.md`)
3. Buat storage buckets:
   - `profile_pictures`
   - `ktp`
   - `store_pictures`

### 4. Konfigurasi Environment

1. Buat file `.env` di root project:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

2. Dapatkan credentials dari Supabase Dashboard > Settings > API

### 5. Run Application

```bash
flutter run
```

## 📁 Struktur Project

```
lib/
├── components/          # Widget komponen reusable
├── layout/             # Layout wrapper
├── models/             # Data models
├── pages/              # Halaman aplikasi
│   ├── auth/          # Halaman authentication
│   ├── customer/      # Halaman untuk customer
│   └── seller/        # Halaman untuk seller
├── providers/          # State management
├── services/           # Service layer untuk API
├── theme/             # Theme dan styling
└── main.dart          # Entry point
```

## 🗄️ Database Schema

### Tables

- `users` - Data pengguna (customer & seller)
- `sellers` - Data tambahan seller
- `stores` - Data toko
- `item_categories` - Kategori barang
- `items` - Data barang
- `reviews` - Review toko
- `community_posts` - Postingan komunitas
- `notifications` - Notifikasi

Lihat detail schema di `SETUP_DATABASE.md`

## 🔐 Authentication Flow

1. **Register**: Customer/Seller bisa mendaftar dengan email
2. **Login**: Autentikasi menggunakan email/password
3. **Role-based Navigation**: Redirect berdasarkan role (customer/seller)
4. **Session Management**: Otomatis maintain session dengan Supabase Auth

## 🗺️ Maps Integration

- Menggunakan OpenStreetMap untuk peta
- Marker dinamis dari database stores
- Current location detection
- Interactive store information popup

## 📱 Fitur per Role

### Customer
- Browse toko di peta
- Search toko dan produk
- Baca postingan komunitas
- Kelola profil

### Seller
- Manajemen toko
- Upload foto toko
- Kelola inventory
- Posting di komunitas
- Analytics (planned)

## 🐛 Troubleshooting

### Supabase Connection Issues
- Pastikan file `.env` sudah dibuat dengan credentials yang benar
- Check console untuk pesan "Supabase initialized successfully"
- Verify project URL dan anon key di Supabase dashboard

### Map Not Loading
- Check internet connection
- Verify location permissions
- Clear app cache

### Upload Images Failed
- Pastikan storage buckets sudah dibuat di Supabase
- Check storage policies
- Verify file format dan size

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

Jika ada masalah atau pertanyaan:
1. Check dokumentasi di `SETUP_DATABASE.md`
2. Buka issue di GitHub
3. Contact developer

## 🔮 Roadmap

- [ ] Push notifications
- [ ] Real-time chat
- [ ] Advanced analytics
- [ ] Inventory management
- [ ] Payment integration
- [ ] Order tracking
- [ ] Multi-language support

## 📊 Status Project

✅ **Completed:**
- Basic authentication
- Database integration
- Map with store markers
- Provider setup
- File upload

🚧 **In Progress:**
- Community features
- Enhanced search
- Complete seller dashboard

⏳ **Planned:**
- Order management
- Payment system
- Push notifications
