import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // GANTI DENGAN IP LARAVEL ANDA
  static const String baseUrl = 'http://192.168.1.100:8000/api';
  
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
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: jsonEncode({
          'name': name,
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
      print('Register API Error: $error');
      rethrow;
    }
  }

  // ========== LOGIN BIASA ==========
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': 'flutter_app',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login gagal');
      }
    } catch (error) {
      print('Login API Error: $error');
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
      print('Google Login API Error: $error');
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
      print('Get User API Error: $error');
      rethrow;
    }
  }
}