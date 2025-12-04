// main.dart
import 'package:flutter/material.dart';
import 'home_ketua.dart';

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
      // Start the app on the Ketua Home page UI
      home: const HomeKetuaPage(),
    );
  }
}
