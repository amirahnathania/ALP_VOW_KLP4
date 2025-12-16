import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import 'auth_page.dart';
import 'services/api_service.dart';

// NOTE: This page now fetches the latest user data (including profil/jabatan)
// and sends updates back to the API so changes persist to the database.

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final String token;

  const ProfilePage({super.key, required this.user, required this.token});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _profileName;
  late String _profileEmail;
  String? _profilePhotoPath;
  final ImagePicker _picker = ImagePicker();

  static const Color _primaryGreen = Color(0xFF4C7B0F);
  static const Color _primaryBrown = Color(0xFF7B5B18);

  @override
  void initState() {
    super.initState();
    _profileName = widget.user['name'] ?? 'Nama Pengguna';
    _profileEmail = widget.user['email'] ?? 'email@example.com';
    _profilePhotoPath = widget.user['photo'];

    // Load latest user data (to populate profil/jabatan fields)
    _loadLatestUser();
  }

  Future<void> _loadLatestUser() async {
    try {
      final id = widget.user['id'] as int? ?? widget.user['Id'] as int?;
      if (id == null) return;

      final res = await ApiService.getUserById(id, widget.token);
      debugPrint('getUserById response: $res');
      if (res['success'] == true && res['data'] != null) {
        final user = Map<String, dynamic>.from(res['data']);
        debugPrint('user data: $user');

        // Prepare jabatan data; fetch separately if not nested
        Map<String, dynamic>? jab;
        dynamic profil = user['profil'];
        debugPrint('profil (raw): $profil');
        debugPrint('profil runtimeType: ${profil.runtimeType}');

        // Some API responses may return profil as a list with one element
        if (profil is List && profil.isNotEmpty) {
          debugPrint('profil is a List — taking first element');
          profil = profil.first;
        }

        // Try to extract nested jabatan in multiple shapes
        try {
          if (profil != null && profil is Map) {
            final nested = profil['jabatan'];
            debugPrint('nested raw value: $nested');

            if (nested != null) {
              if (nested is List && nested.isNotEmpty) {
                jab = Map<String, dynamic>.from(nested.first);
              } else if (nested is Map) {
                jab = Map<String, dynamic>.from(nested);
              } else {
                debugPrint('Unexpected nested jabatan type: ${nested.runtimeType}');
              }
            }
          }
        } catch (e) {
          debugPrint('Error while normalizing nested jabatan: $e');
        }

        // If still missing, try fetching by id fields
        if (jab == null && profil != null && profil is Map) {
          final jid = profil['idJabatan'] ?? profil['id_jabatan'] ?? profil['id_jabatan'];
          if (jid != null) {
            debugPrint('found id_jabatan: $jid');
            try {
              final jabResp = await ApiService.getJabatanById(int.parse(jid.toString()), widget.token);
              debugPrint('getJabatanById response: $jabResp');
              if (jabResp['success'] == true && jabResp['data'] != null) {
                jab = Map<String, dynamic>.from(jabResp['data']);
              } else if (jabResp['data'] != null && jabResp['data'] is Map) {
                jab = Map<String, dynamic>.from(jabResp['data']);
              }
            } catch (e) {
              debugPrint('Failed to fetch jabatan separately: $e');
            }
          } else {
            debugPrint('No id_jabatan found in profil');
          }
        }

        // Update state once with whatever data we have
        setState(() {
          _profileName = user['name'] ?? _profileName;
          _profileEmail = user['email'] ?? _profileEmail;
          _profilePhotoPath = user['photo'] ?? user['avatar'] ?? _profilePhotoPath;

          if (jab != null) {
            debugPrint('Assigning jabatan to state: $jab');
            _jabatanAwal = _formatDateString(jab['awalJabatan'] ?? jab['awal_jabatan']);
            _jabatanAkhir = _formatDateString(jab['akhirJabatan'] ?? jab['akhir_jabatan']);
            _jabatanName = (jab['jabatan'] ?? jab['name'] ?? '').toString();
          }
        });
      }
    } catch (e) {
      debugPrint('Load latest user failed: $e');
    }
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return parts
          .take(2)
          .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
          .join();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Jabatan fields loaded from API
  String _jabatanName = '';
  String _jabatanAwal = '-';
  String _jabatanAkhir = '-';

  String _formatDateString(dynamic raw) {
    if (raw == null) return '-';
    try {
      final s = raw.toString();
      // Try parse ISO timestamps like 2025-12-16T00:00:00.000000Z
      final dt = DateTime.parse(s);
      return DateFormat('dd MMM yyyy').format(dt.toLocal());
    } catch (_) {
      try {
        // Fallback: if contains 'T', strip time portion
        final s = raw.toString();
        if (s.contains('T')) return s.split('T').first;
        return s;
      } catch (_) {
        return '-';
      }
    }
  }

  ImageProvider? _imageProviderFor(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  Future<void> _showProfilePhotoActions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: _primaryGreen),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: _primaryGreen),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profilePhotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Hapus Foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _profilePhotoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _profilePhotoPath = image.path);
    }
  }

  Future<void> _editProfileName() async {
    final controller = TextEditingController(text: _profileName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Pengguna',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final newName = result.trim();
      // Optimistically update UI
      setState(() => _profileName = newName);

      // Persist to backend
      try {
        final id = widget.user['id'] as int? ?? widget.user['Id'] as int?;
        if (id != null) {
          final resp = await ApiService.updateUser(
            id: id,
            data: {'name': newName},
          );

          // If backend returned structured response with success flag
          if (resp['success'] == true) {
            debugPrint('Profile name updated successfully');
          } else {
            final message = resp['message'] ?? 'Gagal menyimpan nama ke server';
            String details = message;
            if (resp['errors'] != null) {
              try {
                if (resp['errors'] is Map) {
                  details = (resp['errors'] as Map).values
                      .map((v) => (v is List ? v.join(', ') : v.toString()))
                      .join('; ');
                } else if (resp['errors'] is List) {
                  details = (resp['errors'] as List).join('; ');
                }
              } catch (_) {}
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(details), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        debugPrint('Failed to save profile name: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan nama ke server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // Navbar dihandle oleh MainLayout
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Profil',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _showProfilePhotoActions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: _primaryBrown,
                          backgroundImage: _profilePhotoPath != null
                              ? _imageProviderFor(_profilePhotoPath!)
                              : null,
                          child: _profilePhotoPath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: _primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildEditableInfoCard(
                    icon: Icons.person_outline,
                    title: 'Nama Pengguna',
                    value: _profileName,
                    onEdit: _editProfileName,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.badge_outlined,
                    title: 'Jabatan',
                    value: _jabatanName.isNotEmpty
                        ? _jabatanName
                        : (widget.user['role'] ?? 'Ketua Kelompok'),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: _profileEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'Awal Masa Jabatan',
                    value: _jabatanAwal ?? '-',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.event_outlined,
                    title: 'Akhir Masa Jabatan',
                    value: _jabatanAkhir ?? '-',
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthPage(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primaryGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, size: 16, color: _primaryBrown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
