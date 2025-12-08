// home_ketua.dart
import 'package:flutter/material.dart';
import 'kalender_ketua.dart';
import 'profile_page.dart';
import 'services/photo_service.dart';
import 'services/api_service.dart';

class HomeKetuaPage extends StatelessWidget {
  final Map<String, dynamic> user;  // ← TAMBAHKAN INI
  final String token;               // ← TAMBAHKAN INI
  
  HomeKetuaPage({
    super.key,
    required this.user,             // ← TAMBAHKAN INI
    required this.token,            // ← TAMBAHKAN INI
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      body: SafeArea(
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
                        'Halo, ${user['name'] ?? 'Pengguna'}',  // ← PAKAI NAMA USER
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

            const SizedBox(height: 16),

            // Hero image banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/BG_Desa_Sengka.jpeg',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Daftar Tugas ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 14, 13, 13),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildTaskItem(
                    title: 'Pengolahan Tanah',
                    color: const Color(0xFF7B5B18),
                    location: '02 Desember 2024',
                    distance: '08:00 - 11:00',
                    detail:
                        'Membersihkan lahan, membajak, dan meratakan tanah untuk persiapan tanam.',
                    onCapturePhoto: () async {
                      final file = await PhotoService.captureOrPick(context);
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
                        'Penanaman bibit sesuai jarak tanam, penyiraman awal dan pengecekan akar.',
                    onCapturePhoto: () async {
                      final file = await PhotoService.captureOrPick(context);
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
                      final file = await PhotoService.captureOrPick(context);
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
                      final file = await PhotoService.captureOrPick(context);
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

            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final int currentIndex = 1; // Home is active on this page

    Widget buildItem({
      required bool active,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return Expanded(
        flex: active ? 2 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 56,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF62903A) : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: active ? Colors.black87 : Colors.black26,
                width: active ? 2.0 : 1.0,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                icon,
                size: active ? 22 : 20,
                color: active ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    final Offset navOffset = currentIndex == 0
        ? const Offset(-0.02, 0)
        : currentIndex == 1
        ? Offset.zero
        : const Offset(0.02, 0);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF4),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
        offset: currentIndex == 0
            ? const Offset(-0.06, 0)
            : currentIndex == 1
            ? Offset.zero
            : const Offset(0.06, 0),
        child: Row(
          children: [
            // Calendar
            buildItem(
              active: currentIndex == 0,
              icon: Icons.calendar_today,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CalendarPage(
                      user: user,
                      token: token,
                    )),
                );
              },
            ),

            const SizedBox(width: 12),

            // Home (active)
            buildItem(
              active: currentIndex == 1,
              icon: Icons.home_outlined,
              onTap: () {},
            ),

            const SizedBox(width: 12),

            // Profile
            buildItem(
              active: currentIndex == 2,
              icon: Icons.person_outline,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                    user: user,
                    token: token,
                  )),
                );
              },
            ),
          ],
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
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
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
                final file = await PhotoService.captureOrPick(context);
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