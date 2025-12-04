// services/camera_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  // Revert to simple UI: no fallback options

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _initializeFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      // ignore and show error UI
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_initializeFuture != null)
              FutureBuilder(
                future: _initializeFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  return CameraPreview(_controller!);
                },
              )
            else
              const Center(
                child: Text(
                  'Kamera tidak tersedia',
                  style: TextStyle(color: Colors.white),
                ),
              ),

            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ),

            // Shutter button
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (_controller == null ||
                          !_controller!.value.isInitialized)
                        return;
                      final file = await _controller!.takePicture();
                      if (!mounted) return;
                      Navigator.of(context).pop(file.path);
                    } catch (_) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
