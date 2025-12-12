# SETUP DAN MENJALANKAN BACKEND + FRONTEND

## Setup Backend Laravel

### Opsi 1: Menggunakan Script Otomatis (Recommended)
```powershell
# Di PowerShell, jalankan:
cd "c:\Users\Rakha\Downloads\ALP Vispro\ALP_VOW_KLP4\backend"
.\setup.ps1
.\start-server.ps1
```

### Opsi 2: Manual Setup
```powershell
# 1. Masuk ke folder backend
cd "c:\Users\Rakha\Downloads\ALP Vispro\ALP_VOW_KLP4\backend"

# 2. Install dependencies
composer install

# 3. Copy .env file (jika belum ada)
copy .env.example .env

# 4. Generate app key
php artisan key:generate

# 5. Setup database di .env (edit file .env):
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nama_database
DB_USERNAME=root
DB_PASSWORD=

# 6. Run migrations
php artisan migrate

# 7. Start server
php artisan serve
```

Server akan berjalan di: `http://localhost:8000`

## Test API

```powershell
# Test apakah API berjalan
.\test-api.ps1

# Atau manual:
curl http://localhost:8000/api/test
```

## Setup Frontend Flutter

```powershell
# 1. Masuk ke folder frontend
cd "c:\Users\Rakha\Downloads\ALP Vispro\ALP_VOW_KLP4\frontend"

# 2. Install dependencies
flutter pub get

# 3. Run aplikasi
flutter run
```

## Konfigurasi URL Backend di Frontend

File: `frontend/lib/services/api_service.dart`

- **Android Emulator**: `http://10.0.2.2:8000/api` (sudah dikonfigurasi otomatis)
- **iOS Simulator**: `http://localhost:8000/api` (sudah dikonfigurasi otomatis)
- **Device Fisik**: Ganti dengan IP komputer Anda, misal `http://192.168.1.100:8000/api`

### Cara mendapatkan IP komputer:
```powershell
ipconfig
# Cari "IPv4 Address" di adapter yang aktif
```

## Testing Login

Setelah backend dan frontend berjalan:

1. **Backend harus sudah running** di `http://localhost:8000`
2. **Buat user test** via database atau API register
3. **Buka aplikasi Flutter** dan coba login dengan:
   - Email: `test@ketua.ac.id` atau `test@gapoktan.ac.id`
   - Password: sesuai yang didaftarkan

## Troubleshooting

### Error: Connection Refused
- Pastikan Laravel server sudah berjalan (`php artisan serve`)
- Cek port 8000 tidak digunakan aplikasi lain

### Error: CORS
- Sudah dikonfigurasi di `backend/config/cors.php`
- Pastikan middleware CORS aktif

### Error: 401 Unauthorized
- Cek kredensial login
- Pastikan user sudah terdaftar di database
- Email harus menggunakan domain `@ketua.ac.id` atau `@gapoktan.ac.id`

### Error di Android Emulator
- Gunakan `http://10.0.2.2:8000/api` bukan `localhost`

### Error di Device Fisik
- Ganti dengan IP address komputer
- Pastikan device dan komputer dalam 1 jaringan WiFi yang sama

## Struktur API Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | /api/test | Test API |
| POST | /api/login | Login user |
| POST | /api/users | Register user |
| POST | /api/logout | Logout user (auth required) |
| GET | /api/users | Get all users (auth required) |

## Format Request Login

```json
POST http://localhost:8000/api/login
Content-Type: application/json

{
  "email": "user@ketua.ac.id",
  "password": "Password123"
}
```

## Format Response Login (Success)

```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "id": 1,
    "nama": "Nama User",
    "email": "user@ketua.ac.id"
  },
  "token": "1|xxxxxxxxxxxxxxxxxxxxx",
  "token_type": "Bearer",
  "expires_in": 604800
}
```

## Format Response Login (Failed)

```json
{
  "success": false,
  "message": "email tidak ditemukan"
}
```
