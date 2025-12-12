# Panduan Penggunaan Kamera

Kamera sudah dikonfigurasi dan siap digunakan di aplikasi Flutter Anda.

## Konfigurasi yang Sudah Ditambahkan

### 1. **Permissions (Android)**
- `AndroidManifest.xml` sudah dikonfigurasi dengan permission kamera dan storage

### 2. **Permissions (iOS)**
- `Info.plist` sudah memiliki `NSCameraUsageDescription`

### 3. **Package**
- `camera: ^0.10.5` sudah ada di `pubspec.yaml`

## Cara Menggunakan

### Metode 1: Menggunakan Helper Function (Paling Mudah)

```dart
import 'package:frontend/camera_helper.dart';

// Di dalam fungsi async atau onPressed
String? imagePath = await openCamera(context);
if (imagePath != null) {
  print('Foto disimpan di: $imagePath');
  // Gunakan imagePath sesuai kebutuhan
}
```

### Metode 2: Menggunakan CameraButton Widget

```dart
import 'package:frontend/camera_helper.dart';

CameraButton(
  buttonText: 'Ambil Foto Bukti',
  icon: Icons.camera_alt,
  onPhotoTaken: (String imagePath) {
    print('Foto diambil: $imagePath');
    setState(() {
      _photoPath = imagePath;
    });
  },
)
```

### Metode 3: Membuka CameraScreen Langsung

```dart
import 'package:frontend/camera_screen.dart';
import 'package:frontend/services/camera_service.dart';

// Pastikan globalCameras tidak null
if (globalCameras != null && globalCameras!.isNotEmpty) {
  final imagePath = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (context) => CameraScreen(
        cameras: globalCameras!,
        onPictureTaken: (String path) {
          print('Photo taken: $path');
        },
      ),
    ),
  );
}
```

## Contoh Implementasi Lengkap

```dart
import 'package:flutter/material.dart';
import 'package:frontend/camera_helper.dart';
import 'dart:io';

class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  String? _imagePath;

  Future<void> _takePhoto() async {
    final imagePath = await openCamera(context);
    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imagePath != null)
              Image.file(
                File(_imagePath!),
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              )
            else
              Text('Belum ada foto'),
            SizedBox(height: 20),
            
            // Metode 1: Using button widget
            CameraButton(
              buttonText: 'Ambil Foto',
              onPhotoTaken: (path) {
                setState(() {
                  _imagePath = path;
                });
              },
            ),
            
            // Metode 2: Using helper function
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: Icon(Icons.camera),
              label: Text('Buka Kamera'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Fitur yang Tersedia

- ✅ Ambil foto dengan kamera depan/belakang
- ✅ Switch kamera (flip camera)
- ✅ Flash on/off
- ✅ Frame overlay untuk panduan pengambilan foto
- ✅ Return path foto yang diambil
- ✅ Callback function untuk handle foto
- ✅ UI yang sudah disesuaikan (Bahasa Indonesia)

## Troubleshooting

### Kamera tidak terbuka
- Pastikan permission kamera sudah diberikan
- Restart aplikasi setelah memberikan permission
- Test di perangkat fisik (emulator mungkin tidak support kamera)

### Error saat mengambil foto
- Pastikan ada ruang penyimpanan yang cukup
- Pastikan permission storage sudah diberikan (Android)

### Hot Reload Issues
- Jika ada perubahan pada camera initialization, lakukan hot restart (bukan hot reload)

## File yang Dibuat

1. `lib/camera_screen.dart` - Widget utama untuk camera
2. `lib/services/camera_service.dart` - Service untuk inisialisasi camera
3. `lib/camera_helper.dart` - Helper functions untuk kemudahan penggunaan
4. `lib/CAMERA_USAGE.md` - Dokumentasi ini
