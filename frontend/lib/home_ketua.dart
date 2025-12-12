// home_ketua.dart
import 'package:flutter/material.dart';
import 'services/photo_service.dart';
import 'services/api_service.dart';

class HomeKetuaPage extends StatelessWidget {
  final Map<String, dynamic> user; // ← TAMBAHKAN INI
  final String token; // ← TAMBAHKAN INI

  HomeKetuaPage({
    super.key,
    required this.user, // ← TAMBAHKAN INI
    required this.token, // ← TAMBAHKAN INI
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120), // Space untuk navbar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
            // Greeting capsule header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: Row(
                  children: [
                    // Small avatar circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                        image: const DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Halo, ${user['name'] ?? 'Pengguna'}', // ← PAKAI NAMA USER
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Widget Prakiraan Cuaca dengan gambar drone
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/drone agri.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Perkiraan Cuaca',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Kabupaten Gowa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '29°C',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Daftar Kegiatan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 14, 13, 13),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTaskItem(
                    title: 'Pengolahan Tanah',
                    color: const Color(0xFF7B5B18),
                    location: '02 Desember 2024',
                    distance: '08:00 - 11:00',
                    detail:
                        'Membersihkan lahan, membajak, dan meratakan tanah untuk persiapan tanam.',
                    onCapturePhoto: () async {
                      final file = await PhotoService.captureDirectly();
                      if (file == null) return;
                      const taskId = 'task-1';
                      try {
                        await ApiService.uploadTaskPhoto(
                          token: token,
                          taskId: taskId,
                          filePath: file.path,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto berhasil dikirim'),
                            backgroundColor: Color(0xFF62903A),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal kirim foto: $e')),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildTaskItem(
                    title: 'Pananaman Bibit',
                    color: const Color(0xFF617F59),
                    location: '10 Desember 2025',
                    distance: '07:00 - 12:00',
                    detail:
                        'Menanam bibit padi, jagung, atau tanaman lain sesuai jadwal.',
                    onCapturePhoto: () async {
                      final file = await PhotoService.captureDirectly();
                      if (file == null) return;
                      const taskId = 'task-2';
                      try {
                        await ApiService.uploadTaskPhoto(
                          token: token,
                          taskId: taskId,
                          filePath: file.path,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto berhasil dikirim'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal kirim foto: $e')),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildTaskItem(
                    title: 'Pestisida',
                    color: const Color(0xFF7F7E79),
                    location: '28 Desember 2025',
                    distance: '07:00 - 10:00',
                    detail:
                        'Penyemprotan hama sesuai dosis anjuran dan pemantauan daun.',
                    onCapturePhoto: () async {
                      final file = await PhotoService.captureDirectly();
                      if (file == null) return;
                      const taskId = 'task-3';
                      try {
                        await ApiService.uploadTaskPhoto(
                          token: token,
                          taskId: taskId,
                          filePath: file.path,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto berhasil dikirim'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal kirim foto: $e')),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildTaskItem(
                    title: 'Pemupukan',
                    color: const Color(0xFFD9C36A),
                    location: '01 Januari 2026',
                    distance: '07:00 - 12:00',
                    detail:
                        'Pemberian pupuk dasar dan susulan sesuai kebutuhan tanaman.',
                    onCapturePhoto: () async {
                      final file = await PhotoService.captureDirectly();
                      if (file == null) return;
                      const taskId = 'task-4';
                      try {
                        await ApiService.uploadTaskPhoto(
                          token: token,
                          taskId: taskId,
                          filePath: file.path,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto berhasil dikirim'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal kirim foto: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// WIDGET TASK ITEM (Reusable)

Widget _buildTaskItem({
  required String title,
  required Color color,
  required String location,
  required String distance,
  required String detail,
  required VoidCallback onCapturePhoto,
}) {
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: Colors.white.withOpacity(0.98),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: onCapturePhoto,
              icon: const Icon(
                Icons.camera_alt_outlined,
                size: 16,
                color: Colors.black87,
              ),
              label: const Text(
                'KIRIM FOTO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFDFEEDB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Deskripsi singkat kegiatan: diberi sedikit indent dan spasi lebih
        Text(
          detail,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.white.withOpacity(0.92),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              location,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Icon(Icons.access_time, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              distance,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        // Bottom action removed per request
      ],
    ),
  );
}

/// Card khusus untuk aksi "Kirim Foto"
// ignore: unused_element
Widget _buildSendPhotoCard(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF62903A),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kirim Foto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final file = await PhotoService.captureDirectly();
                if (file == null) return;
                const token = 'YOUR_TOKEN_HERE';
                const taskId = 'quick-send';
                try {
                  await ApiService.uploadTaskPhoto(
                    token: token,
                    taskId: taskId,
                    filePath: file.path,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto berhasil dikirim')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal kirim foto: $e')),
                  );
                }
              },
              icon: const Icon(
                Icons.camera_alt_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Ambil & Kirim',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: Colors.white.withOpacity(0.85)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
