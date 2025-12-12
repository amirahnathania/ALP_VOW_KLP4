import 'package:camera/camera.dart';

/// Global variable to store available cameras
List<CameraDescription>? globalCameras;

/// Initialize cameras at app startup
Future<void> initializeCameras() async {
  try {
    globalCameras = await availableCameras();
  } catch (e) {
    print('Error initializing cameras: $e');
    globalCameras = [];
  }
}
