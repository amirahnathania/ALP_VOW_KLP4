// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'home_gapoktan.dart';
import 'main_layout.dart';
import 'splash_screen.dart';
import 'services/camera_service.dart';

/// Set ke `true` jika ingin langsung membuka versi mock Gapoktan
/// tanpa melewati Splash/Auth (berguna untuk debugging offline).
const bool kUseGapoktanMock = false;

/// Set ke `true` jika ingin langsung membuka versi mock Ketua
/// tanpa melewati Splash/Auth.
const bool kUseKetuaMock = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id');
  await initializeDateFormatting('id_ID');
  await initializeCameras(); // Initialize cameras
  runApp(const BelajarTaniApp());
}

class BelajarTaniApp extends StatelessWidget {
  const BelajarTaniApp({super.key});

  static const Map<String, dynamic> _gapoktanUser = <String, dynamic>{
    'name': 'Gapoktan Demo',
    'email': 'gapoktan.demo@belajartani.local',
    'jabatan': 'Gapoktan',
    'role': 'gapoktan',
    'awal_jabatan': '2024-01-01',
    'akhir_jabatan': '2028-01-01',
    'photo':
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=600&q=60',
  };

  static const String _gapoktanToken = 'gapoktan-offline-token';

  static const Map<String, dynamic> _ketuaUser = <String, dynamic>{
    'name': 'Ketua Demo',
    'email': 'ketua.demo@belajartani.local',
    'jabatan': 'Ketua',
    'role': 'ketua',
  };

  static const String _ketuaToken = 'ketua-offline-token';

  @override
  Widget build(BuildContext context) {
    final bool useMockGapoktan = kUseGapoktanMock;
    final bool useMockKetua = kUseKetuaMock && !useMockGapoktan;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BelajarTani',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
      ],
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        primaryColor: const Color(0xFF8BC784),
        scaffoldBackgroundColor: useMockGapoktan
            ? const Color(0xFFFFFDF4)
            : Colors.white,
      ),
      home: useMockGapoktan
          ? HomePage(user: _gapoktanUser, token: _gapoktanToken)
          : useMockKetua
          ? MainLayoutScreen(user: _ketuaUser, token: _ketuaToken)
          : const SplashScreen(),
    );
  }
}
