// main.dart
import 'package:flutter/material.dart';
import 'package:frontend/splash_screen.dart';
void main() {
  runApp(const BelajarTaniApp());
}

class BelajarTaniApp extends StatelessWidget {
  const BelajarTaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BelajarTani',
      theme: ThemeData(
        primaryColor: const Color(0xFF8BC784),
        scaffoldBackgroundColor: Colors.white,
      ),
      // Start with SplashScreen, which will transition to AuthPage
      home: const SplashScreen(),
    );
  }
}
