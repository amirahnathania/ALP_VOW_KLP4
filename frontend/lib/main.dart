// main.dart
import 'package:flutter/material.dart';
import 'package:frontend/auth_page.dart';
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
      // To run the Ketua home page, set the home to CalendarPage.
      // Switch back to AuthPage if needed.
      home: const AuthPage(),
    );
  }
}
