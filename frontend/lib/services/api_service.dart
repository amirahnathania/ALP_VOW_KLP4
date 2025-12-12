import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Gunakan 10.0.2.2 untuk Android Emulator
  // Gunakan localhost atau 127.0.0.1 untuk iOS Simulator atau web
  // Gunakan IP address komputer untuk device fisik
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/api';
    }
    return 'http://localhost:8000/api';
  }
  
  // Headers untuk semua request
  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ========== REGISTRASI BIASA ==========
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: headers,
        body: jsonEncode({
          'Nama_Pengguna': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? error['errors']?.toString() ?? 'Registrasi gagal');
      }
    } catch (error) {
      debugPrint('Register API Error: $error');
      rethrow;
    }
  }

  // ========== LOGIN BIASA ==========
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    debugPrint('=== LOGIN REQUEST ===');
    debugPrint('URL: $baseUrl/login');
    debugPrint('Email: $email');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Koneksi timeout. Pastikan backend Laravel sudah berjalan di port 8000');
        },
      );

      debugPrint('=== LOGIN RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login gagal');
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server. Pastikan:\n1. Backend Laravel sudah berjalan (php artisan serve)\n2. Gunakan IP yang tepat untuk device fisik');
    } on http.ClientException {
      throw Exception('Koneksi gagal. Periksa URL server');
    } catch (error) {
      debugPrint('Login API Error: $error');
      rethrow;
    }
  }

  // ========== GOOGLE LOGIN ==========
  static Future<Map<String, dynamic>> loginWithGoogle(
      Map<String, dynamic> googleData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: headers,
        body: jsonEncode({
          'google_data': googleData,
          'device_name': 'flutter_app',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Google login failed: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Google Login API Error: $error');
      rethrow;
    }
  }

  // ========== GET USER DATA ==========
  static Future<Map<String, dynamic>> getUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (error) {
      debugPrint('Get User API Error: $error');
      rethrow;
    }
  }

  // ========== UPLOAD FOTO TUGAS ==========
  static Future<Map<String, dynamic>> uploadTaskPhoto({
    required String token,
    required String taskId,
    required String filePath,
  }) async {
    final uri = Uri.parse('$baseUrl/tasks/$taskId/photo');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..files.add(await http.MultipartFile.fromPath('photo', filePath));

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Upload gagal: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      debugPrint('Upload Photo API Error: $error');
      rethrow;
    }
  }
}