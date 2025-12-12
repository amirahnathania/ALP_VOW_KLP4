import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'services/camera_service.dart';

/// Helper function to open camera and get photo path
/// 
/// Usage example:
/// ```dart
/// String? imagePath = await openCamera(context);
/// if (imagePath != null) {
///   print('Photo saved at: $imagePath');
///   // Use the image path as needed
/// }
/// ```
Future<String?> openCamera(BuildContext context) async {
  if (globalCameras == null || globalCameras!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kamera tidak tersedia di perangkat ini'),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }

  try {
    final imagePath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => CameraScreen(cameras: globalCameras!),
      ),
    );
    return imagePath;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error membuka kamera: $e'),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }
}

/// Widget button to open camera
class CameraButton extends StatelessWidget {
  final Function(String)? onPhotoTaken;
  final String buttonText;
  final IconData icon;
  
  const CameraButton({
    Key? key,
    this.onPhotoTaken,
    this.buttonText = 'Ambil Foto',
    this.icon = Icons.camera_alt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final imagePath = await openCamera(context);
        if (imagePath != null && onPhotoTaken != null) {
          onPhotoTaken!(imagePath);
        }
      },
      icon: Icon(icon),
      label: Text(buttonText),
    );
  }
}
