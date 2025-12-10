// splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'auth_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _triangleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleSmallAnimation;
  late Animation<double> _logoScaleLargeAnimation;
  late Animation<double> _screenFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Single AnimationController for the entire sequence
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Phase 1: Triangle outward movement (0.0 - 0.35)
    // Starts immediately and moves triangles outward
    _triangleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
    );

    // Phase 2: Logo fade in (0.2 - 0.4)
    // Logo starts appearing when X is visible
    _logoFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.4, curve: Curves.easeIn),
    );

    // Phase 2: Logo small scale (0.2 - 0.45)
    // Logo grows to small size
    _logoScaleSmallAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.45, curve: Curves.easeOut),
    );

    // Phase 3: Logo large scale (0.5 - 0.8)
    // Logo grows to large size as triangles move off screen
    _logoScaleLargeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
    );

    // Phase 4: Screen fade out (0.8 - 1.0)
    _screenFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );

    // Start animation
    _controller.forward();

    // Navigate to AuthPage when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Custom Painter for 4 Triangles
              CustomPaint(
                painter: TrianglePainter(
                  animationValue: _triangleAnimation.value,
                  color: const Color(0xFF4F8513),
                ),
                size: Size.infinite,
              ),
              // Logo in the center
              Center(
                child: Opacity(
                  opacity: _logoFadeAnimation.value,
                  child: Transform.scale(
                    scale: _calculateLogoScale(),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateLogoScale() {
    // Start at 0, grow to 1.0 (small), then to 2.5 (large)
    if (_logoScaleSmallAnimation.value < 1.0) {
      // Phase 2: 0 -> 1.0
      return _logoScaleSmallAnimation.value * 1.0;
    } else {
      // Phase 3: 1.0 -> 2.5
      return 1.0 + (_logoScaleLargeAnimation.value * 1.5);
    }
  }
}

class TrianglePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  TrianglePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Calculate offset based on animation
    // At 0: triangles meet at center (full screen covered)
    // At 1: triangles are off screen (full X visible)
    final double offsetDistance = math.max(size.width, size.height) * 1.5;
    final double currentOffset = offsetDistance * animationValue;

    // Top Triangle
    // Vertices: Top-Left, Top-Right, Center
    final topPath = Path();
    topPath.moveTo(0, 0 - currentOffset); // Top-Left
    topPath.lineTo(size.width, 0 - currentOffset); // Top-Right
    topPath.lineTo(centerX, centerY - currentOffset); // Center
    topPath.close();
    canvas.drawPath(topPath, paint);

    // Bottom Triangle
    // Vertices: Bottom-Left, Bottom-Right, Center
    final bottomPath = Path();
    bottomPath.moveTo(0, size.height + currentOffset); // Bottom-Left
    bottomPath.lineTo(size.width, size.height + currentOffset); // Bottom-Right
    bottomPath.lineTo(centerX, centerY + currentOffset); // Center
    topPath.close();
    canvas.drawPath(bottomPath, paint);

    // Left Triangle
    // Vertices: Top-Left, Bottom-Left, Center
    final leftPath = Path();
    leftPath.moveTo(0 - currentOffset, 0); // Top-Left
    leftPath.lineTo(0 - currentOffset, size.height); // Bottom-Left
    leftPath.lineTo(centerX - currentOffset, centerY); // Center
    leftPath.close();
    canvas.drawPath(leftPath, paint);

    // Right Triangle
    // Vertices: Top-Right, Bottom-Right, Center
    final rightPath = Path();
    rightPath.moveTo(size.width + currentOffset, 0); // Top-Right
    rightPath.lineTo(size.width + currentOffset, size.height); // Bottom-Right
    rightPath.lineTo(centerX + currentOffset, centerY); // Center
    rightPath.close();
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
