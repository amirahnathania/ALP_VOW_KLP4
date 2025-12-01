import 'package:flutter/material.dart';
import 'auth_page.dart';

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
        useMaterial3: true,
      ),
      home: const AuthPage(),   // pastikan ini benar
    );
  }
}
