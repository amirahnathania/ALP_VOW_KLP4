import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // Base host without the `/api` suffix, useful for building public asset URLs
  static String get baseHost {
    final u = baseUrl;
    if (u.endsWith('/api')) return u.substring(0, u.length - 4);
    if (u.endsWith('/api/')) return u.substring(0, u.length - 5);
    return u;
  }

  static String imageUrlFromName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return '';
    // backend serves images under /images/<filename>
    return '${baseHost.replaceAll(RegExp(r'/api$'), '')}/images/$fileName';
  }

  // Headers untuk semua request
  static Map<String, String> get headers {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // Build headers with optional token (will be added if provided)
  static Map<String, String> authHeaders(String? token) {
    if (token == null) return headers;
    final t = token.trim();
    if (t.isEmpty) return headers;
    return {...headers, 'Authorization': 'Bearer $t'};
  }

  // Token persistence helpers
  static const String _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
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
          'name': name, // Backend akan transform ke nama_pengguna
          'email': email,
          'password': password,
          'passwordConfirmation':
              password, // Backend akan transform ke password_confirmation
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Response sudah dalam camelCase dari backend Resource
        return data;
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
    debugPrint('=== LOGIN REQUEST ===');
    debugPrint('URL: $baseUrl/login');
    debugPrint('Email: $email');

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Koneksi timeout. Pastikan backend Laravel sudah berjalan di port 8000',
              );
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
      throw Exception(
        'Tidak dapat terhubung ke server. Pastikan:\n1. Backend Laravel sudah berjalan (php artisan serve)\n2. Gunakan IP yang tepat untuk device fisik',
      );
    } on http.ClientException {
      throw Exception('Koneksi gagal. Periksa URL server');
    } catch (error) {
      debugPrint('Login API Error: $error');
      rethrow;
    }
  }

  // ========== GOOGLE LOGIN (TEMPORARILY DISABLED) ==========
  // Google Sign-In not yet implemented on backend
  static Future<Map<String, dynamic>> loginWithGoogle(
    Map<String, dynamic> googleData,
  ) async {
    throw UnimplementedError(
      'Google Sign-In belum diimplementasikan di backend',
    );
  }

  // ========== GET USER DATA ==========
  static Future<Map<String, dynamic>> getUserData([String? token]) async {
    try {
      token ??= await getStoredToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users'), // Get list of users
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        // Response dalam camelCase dari backend Resource
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (error) {
      debugPrint('Get User API Error: $error');
      rethrow;
    }
  }

  // Get single user by ID (includes profil if available)
  static Future<Map<String, dynamic>> getUserById(
    int id, [
    String? token,
  ]) async {
    try {
      token ??= await getStoredToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch user');
      }
    } catch (error) {
      debugPrint('Get User By ID API Error: $error');
      rethrow;
    }
  }

  // Ensure profil exists for a user (creates profil if missing) and return the user
  static Future<Map<String, dynamic>> ensureProfilForUser(
    int id, [
    String? token,
  ]) async {
    try {
      token ??= await getStoredToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id/ensure-profil'),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': error['success'] ?? false,
          'message': error['message'] ?? 'Failed to ensure profil',
          'data': error['data'] ?? null,
          'statusCode': response.statusCode,
        };
      }
    } catch (error) {
      debugPrint('Ensure Profil API Error: $error');
      rethrow;
    }
  }

  // Update user (accepts camelCase keys like 'name' and maps them to backend fields)
  static Future<Map<String, dynamic>> updateUser({
    required int id,
    String? token,
    required Map<String, dynamic> data,
  }) async {
    try {
      token ??= await getStoredToken();

      // map common camelCase front-end keys to backend snake_case fields
      final payload = <String, dynamic>{};
      if (data.containsKey('name')) payload['nama_pengguna'] = data['name'];
      if (data.containsKey('email')) payload['email'] = data['email'];
      if (data.containsKey('password')) payload['password'] = data['password'];

      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: authHeaders(token),
        body: jsonEncode(payload),
      );

      // Always attempt to decode the response body and return structured data
      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        return decoded;
      }

      // Return error details from backend (validation errors, messages, etc.)
      return {
        'success': decoded['success'] ?? false,
        'message': decoded['message'] ?? 'Failed to update user',
        'errors': decoded['errors'] ?? null,
        'statusCode': response.statusCode,
      };
    } catch (error) {
      debugPrint('Update User API Error: $error');
      rethrow;
    }
  }

  // ========== UPLOAD BUKTI KEGIATAN ==========
  static Future<Map<String, dynamic>> uploadBuktiKegiatan({
    required String token,
    required int idKegiatan,
    required int idProfil,
    required String filePath,
  }) async {
    final uri = Uri.parse('$baseUrl/bukti-kegiatan');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..fields['idKegiatan'] = idKegiatan
          .toString() // Backend will transform to id_kegiatan
      ..fields['idProfil'] = idProfil
          .toString() // Backend will transform to id_profil
      ..files.add(await http.MultipartFile.fromPath('foto', filePath));

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Response dalam camelCase dari backend Resource
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Upload gagal: ${response.statusCode}',
        );
      }
    } catch (error) {
      debugPrint('Upload Photo API Error: $error');
      rethrow;
    }
  }

  // ========== GET BUKTI KEGIATAN BY ID ==========
  static Future<Map<String, dynamic>> getBuktiKegiatan({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bukti-kegiatan/$id'),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get bukti kegiatan');
      }
    } catch (error) {
      debugPrint('Get Bukti Kegiatan API Error: $error');
      rethrow;
    }
  }

  // Get single jabatan by ID
  static Future<Map<String, dynamic>> getJabatanById(
    int id, [
    String? token,
  ]) async {
    try {
      token ??= await getStoredToken();
      final response = await http.get(
        Uri.parse('$baseUrl/jabatan/$id'),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final decoded = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {};
        return {
          'success': decoded['success'] ?? false,
          'message': decoded['message'] ?? 'Failed to fetch jabatan',
          'data': decoded['data'] ?? null,
          'statusCode': response.statusCode,
        };
      }
    } catch (error) {
      debugPrint('Get Jabatan By ID Error: $error');
      rethrow;
    }
  }

  // ========== CREATE KEGIATAN ==========
  static Future<Map<String, dynamic>> createKegiatan({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kegiatan'),
        headers: authHeaders(token),
        body: jsonEncode(data), // Send camelCase, backend will transform
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create kegiatan');
      }
    } catch (error) {
      debugPrint('Create Kegiatan API Error: $error');
      rethrow;
    }
  }

  // ========== UPDATE KEGIATAN ==========
  static Future<Map<String, dynamic>> updateKegiatan({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/kegiatan/$id'),
        headers: authHeaders(token),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update kegiatan');
      }
    } catch (error) {
      debugPrint('Update Kegiatan API Error: $error');
      rethrow;
    }
  }

  // ========== DELETE KEGIATAN ==========
  static Future<Map<String, dynamic>> deleteKegiatan({
    required String token,
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/kegiatan/$id'),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        throw Exception(error['message'] ?? 'Failed to delete kegiatan');
      }
    } catch (error) {
      debugPrint('Delete Kegiatan API Error: $error');
      rethrow;
    }
  }

  // ========== GET KEGIATAN LIST ==========
  static Future<Map<String, dynamic>> getKegiatanList({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kegiatan'),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get kegiatan list');
      }
    } catch (error) {
      debugPrint('Get Kegiatan List API Error: $error');
      rethrow;
    }
  }

  // ========== GET BUKTI KEGIATAN LIST ==========
  static Future<Map<String, dynamic>> getBuktiList({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bukti-kegiatan'),
        headers: authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to get bukti kegiatan list',
        );
      }
    } catch (error) {
      debugPrint('Get Bukti Kegiatan List API Error: $error');
      rethrow;
    }
  }
}
