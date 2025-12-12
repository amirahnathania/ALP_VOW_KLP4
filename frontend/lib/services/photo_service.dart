// services/photo_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'camera_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'api_service.dart';

class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  // Langsung buka kamera tanpa dialog konfirmasi
  static Future<File?> captureDirectly() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (picked == null) return null;
        return File(picked.path);
      } else {
        // Desktop: use file picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (result == null || result.files.isEmpty) return null;
        final path = result.files.first.path;
        if (path == null) return null;
        return File(path);
      }
    } catch (e) {
      debugPrint('Error capturing photo directly: $e');
      return null;
    }
  }

  // Attempts to capture a photo from the camera. On desktop (like Windows),
  // falls back to picking an image file from disk.
  static Future<File?> captureOrPick(BuildContext context) async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Ask user before opening the system camera, provide explicit Exit
        final bool? proceed = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ambil Foto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Buka Kamera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF62903A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Keluar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );

        if (proceed != true) return null; // user chose to exit/cancel
        // Open native/system camera directly (reverted behavior)
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.camera,
        );
        if (picked == null) return null;
        return File(picked.path);
      }

      // Fallback (Windows/macOS/Linux/Web): pick existing image file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null || result.files.isEmpty) return null;
      final String? path = result.files.single.path;
      if (path == null) return null;
      return File(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
      return null;
    }
  }

  // Upload foto dengan umpan balik Snackbar terpusat
  static Future<Map<String, dynamic>?> uploadTaskPhotoWithFeedback({
    required BuildContext context,
    required String token,
    required String taskId,
    required String filePath,
  }) async {
    try {
      final result = await ApiService.uploadTaskPhoto(
        token: token,
        taskId: taskId,
        filePath: filePath,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto berhasil dikirim')));
      }

      return result;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal kirim foto: $e')));
      }
      return null;
    }
  }
}
