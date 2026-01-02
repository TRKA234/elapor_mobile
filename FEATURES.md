# E-Lapor Mobile - Panduan Fitur Terbaru

Aplikasi E-Lapor telah ditingkatkan menjadi aplikasi **production-ready** dengan fitur-fitur yang siap digunakan oleh masyarakat untuk membuat laporan dengan mudah dan lengkap.

## 🎯 Fitur Utama

### 1. 📍 **Lokasi dengan Google Maps**

- **Auto-detect GPS**: Aplikasi secara otomatis mendeteksi lokasi pengguna
- **Location Picker Dialog**: Dialog interaktif untuk memilih/mengubah lokasi
- **Reverse Geocoding**: Menampilkan alamat lengkap berdasarkan koordinat GPS
- **Search Lokasi**: Cari dan pilih lokasi berdasarkan nama jalan/kota

**Cara Penggunaan:**

1. Di screen "Buat Laporan Baru", lokasi akan otomatis terdeteksi
2. Tap tombol lokasi untuk membuka location picker
3. Pilih "Gunakan Lokasi Sekarang" atau cari alamat manual
4. Lokasi akan ditampilkan dengan koordinat GPS dan alamat lengkap

### 2. 📸 **Photo Gallery & Upload**

- **Multiple Photo Upload**: Upload hingga 5 foto per laporan
- **Camera & Gallery**: Ambil foto langsung atau pilih dari galeri
- **Auto Compression**: Foto otomatis dikompresi untuk hemat kuota
- **Photo Preview**: Preview foto dengan klik untuk melihat full-size
- **Remove Photo**: Hapus foto yang tidak perlu

**Cara Penggunaan:**

1. Di form "Buat Laporan Baru", scroll ke bagian "Foto Laporan"
2. Klik "Kamera" untuk ambil foto langsung atau "Galeri" untuk pilih foto
3. Maksimal 5 foto per laporan
4. Klik 'X' di sudut foto untuk menghapus

### 3. 🏷️ **Kategori Laporan**

Pilih kategori yang sesuai dengan jenis laporan:

- **Umum** - Laporan umum
- **Keamanan** - Masalah keamanan
- **Jalan Rusak** - Infrastruktur jalan
- **Sanitasi** - Kebersihan & sanitasi
- **Sosial** - Masalah sosial
- **Infrastruktur** - Fasilitas publik
- **Lingkungan** - Isu lingkungan
- **Lainnya** - Kategori lainnya

### 4. 📝 **Deskripsi Detail**

- Tambahkan deskripsi lengkap (hingga 500 karakter)
- Jelaskan detail permasalahan
- Semakin detail semakin membantu pemerintah

### 5. 🔍 **Search & Filter**

Di Home Screen, Anda dapat:

- **Search**: Cari laporan berdasarkan judul atau deskripsi
- **Filter Kategori**: Filter laporan berdasarkan kategori
- **Filter Status**: Filter berdasarkan status (Pending, Diproses, Selesai)
- **Kombinasi**: Gunakan kombinasi search + filter untuk hasil yang lebih spesifik

### 6. 📊 **Status Tracking**

Setiap laporan memiliki status yang menunjukkan progres:

- 🟡 **PENDING** - Laporan baru, menunggu ditinjau
- 🔵 **DIPROSES** - Sedang ditangani
- 🟢 **SELESAI** - Sudah diselesaikan

### 7. 💬 **Comment & Diskusi**

- Baca komentar dari masyarakat lain
- Tambahkan komentar untuk mendiskusikan laporan
- Lihat jumlah komentar di setiap laporan

### 8. 📱 **Statistik Real-time**

- Total laporan ditampilkan di header dengan caching Redis
- Data update secara real-time dari backend

## 🚀 Cara Menggunakan Aplikasi

### **Membuat Laporan Baru:**

1. Tap tombol **+ (FAB)** di bawah kanan
2. Isi **Judul Laporan** (max 100 karakter)
3. Pilih **Kategori** yang sesuai
4. Tambahkan **Deskripsi Detail** (optional, max 500 karakter)
5. Tap lokasi untuk **Pilih/Edit Lokasi**
6. Tambahkan **Foto** (hingga 5 foto)
7. Tap **KIRIM LAPORAN**

### **Mencari Laporan:**

1. Di Home Screen, gunakan **Search Bar** untuk cari judul/deskripsi
2. Gunakan **Filter Kategori** untuk filter berdasarkan jenis laporan
3. Gunakan **Filter Status** untuk filter berdasarkan progres

### **Melihat Detail Laporan:**

1. Tap salah satu laporan di list
2. Lihat deskripsi lengkap, foto gallery, lokasi peta
3. Baca dan tambahkan komentar
4. Lihat status progres laporan

## 🔧 Teknologi & Dependencies

### Flutter Dependencies:

```yaml
- geolocator: 9.0.2 - Akses lokasi GPS
- google_maps_flutter: 2.5.0 - Google Maps integration
- image_picker: 1.0.4 - Pilih foto dari camera/galeri
- image: 4.0.17 - Kompresi & proses gambar
- permission_handler: 11.4.4 - Minta izin akses (camera, lokasi)
- uuid: 4.0.0 - Generate unique ID
- geocoding: 2.1.1 - Reverse geocoding (koordinat → alamat)
- file_picker: 5.3.1 - Pilih file
- path_provider: 2.1.1 - Path storage
- cached_network_image: 3.3.0 - Cache gambar dari network
```

### Backend:

- **PHP** (Report Service) - Handle upload file, CRUD laporan
- **Node.js** (Discussion Service) - Manage komentar
- **Python** (Stats Service) - Statistik real-time
- **MySQL** - Database laporan
- **Redis** - Caching statistik

## 🛠️ Setup & Instalasi

### Development Environment:

1. Clone repository
2. Install Flutter dependencies:

   ```bash
   cd elapor_mobile
   flutter pub get
   ```

3. Update Android Manifest untuk permissions:

   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   ```

4. Run aplikasi:
   ```bash
   flutter run
   ```

## 📋 API Endpoints

### Report Service (PHP - Port 8082):

**GET** `/index.php` - List semua laporan

```
Response:
[
  {
    "id": 1,
    "title": "Jalan Rusak",
    "description": "Jalan sangat rusak...",
    "category": "Jalan Rusak",
    "latitude": "-6.2000",
    "longitude": "106.8166",
    "address": "Jl. Sudirman, Jakarta",
    "status": "pending",
    "photos": ["/uploads/photo1.jpg"],
    "user_name": "User",
    "created_at": "2024-01-02 10:30:00",
    "comment_count": 5
  }
]
```

**POST** `/create.php` - Buat laporan baru

```
Fields:
- title (required)
- description
- category
- latitude
- longitude
- address
- user_id
- user_name
- photos[] (files)
```

**GET** `/index.php?id=1` - Detail laporan
**POST** `/upload.php` - Upload foto

## 🎨 UI/UX Improvements

### Home Screen:

- ✅ Modern gradient header dengan statistik
- ✅ Search bar yang responsive
- ✅ Chip filters untuk kategori & status
- ✅ Card design untuk setiap laporan
- ✅ Thumbnail foto di setiap laporan
- ✅ Pull-to-refresh functionality

### Add Report Screen:

- ✅ Step-by-step form yang user-friendly
- ✅ Real-time location picker
- ✅ Photo gallery dengan preview
- ✅ Category dropdown
- ✅ Character counter untuk input

### Detail Screen:

- ✅ Beautiful header dengan status badge
- ✅ Photo gallery dengan grid view
- ✅ Lokasi dengan Google Maps
- ✅ Comments section dengan user avatar
- ✅ Comment input dengan character limit

## 📊 Performance & Best Practices

- **Image Compression**: Semua foto otomatis dikompresi
- **Caching**: Network image di-cache untuk faster loading
- **Permission Handling**: Proper permission requests
- **Error Handling**: Comprehensive error messages
- **Loading States**: Loading indicators di setiap operasi async

## 🔐 Security Notes

- File upload validation (tipe & size)
- Permission checks sebelum akses GPS/Camera
- User input sanitization di backend
- CORS handling untuk API calls

## 📝 Catatan Pengembangan

Aplikasi ini sekarang **production-ready** dan dapat digunakan oleh masyarakat untuk:

- ✅ Membuat laporan dengan detail lengkap
- ✅ Menambahkan bukti visual (foto)
- ✅ Melacak status laporan mereka
- ✅ Berdiskusi dengan masyarakat lain

Fitur-fitur ini membuat aplikasi menjadi tools yang powerful untuk citizen reporting dan community engagement.

---

**Version**: 2.0 (Enhanced Edition)
**Last Updated**: 2024
