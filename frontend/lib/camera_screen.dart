import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(String)? onPictureTaken;
  
  const CameraScreen({
    Key? key, 
    required this.cameras,
    this.onPictureTaken,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(_selectedCameraIndex);
  }

  void _initializeCamera(int cameraIndex) {
    // Create controller with selected camera
    _controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Initialize the controller
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchCamera() {
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    _controller.dispose();
    _initializeCamera(_selectedCameraIndex);
  }

  Future<void> _toggleFlash() async {
    try {
      await _initializeControllerFuture;
      _isFlashOn = !_isFlashOn;
      await _controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      
      if (!mounted) return;
      
      // Call callback if provided
      if (widget.onPictureTaken != null) {
        widget.onPictureTaken!(image.path);
        Navigator.of(context).pop(image.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto disimpan di ${image.path}')),
        );
        Navigator.of(context).pop(image.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ambil Foto'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
          if (widget.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_android),
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller),
                // Camera frame overlay
                CustomPaint(
                  painter: CameraFramePainter(),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        backgroundColor: Colors.white,
        child: const Icon(Icons.camera, color: Colors.black, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Custom painter for camera frame
class CameraFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw corner brackets
    final cornerLength = 40.0;
    final margin = 40.0;
    
    // Top-left
    canvas.drawLine(Offset(margin, margin), Offset(margin + cornerLength, margin), paint);
    canvas.drawLine(Offset(margin, margin), Offset(margin, margin + cornerLength), paint);
    
    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - cornerLength, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + cornerLength), paint);
    
    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + cornerLength, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - cornerLength), paint);
    
    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - cornerLength, size.height - margin), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
