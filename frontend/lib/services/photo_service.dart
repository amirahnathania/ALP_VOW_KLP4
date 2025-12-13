// services/photo_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'api_service.dart';

class PhotoService {
  // Attempts to capture a photo from the camera. On desktop (like Windows),
  // falls back to picking an image file from disk.
  static Future<File?> captureOrPick(BuildContext context) async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Buka custom camera screen dengan tombol back yang jelas
        final String? path = await Navigator.of(context).push<String>(
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
        if (path == null) return null;
        return File(path);
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
