import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // For iOS Simulator use 127.0.0.1 or localhost
  // For Android Emulator use 10.0.2.2
  // For physical devices, use the actual IP address of your machine
  static const String baseUrl = 'http://10.136.159.10:8001/api';

  // Headers untuk semua request
  static Map<String, String> get headers {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
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
        throw Exception(
          error['message'] ?? error['errors']?.toString() ?? 'Registrasi gagal',
        );
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
    print('LOGIN_DEBUG: email=$email, password=$password');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('LOGIN_RESPONSE: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ??
              error['errors']?.toString() ??
              'Login gagal (${response.statusCode})',
        );
      }
    } catch (error) {
      debugPrint('Login API Error: $error');
      rethrow;
    }
  }

  // ========== GOOGLE LOGIN ==========
  static Future<Map<String, dynamic>> loginWithGoogle(
    Map<String, dynamic> googleData,
  ) async {
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
        headers: {...headers, 'Authorization': 'Bearer $token'},
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
        throw Exception(
          'Upload gagal: ${response.statusCode} ${response.body}',
        );
      }
    } catch (error) {
      debugPrint('Upload Photo API Error: $error');
      rethrow;
    }
  }
}
