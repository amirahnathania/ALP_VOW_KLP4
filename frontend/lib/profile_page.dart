import 'package:flutter/material.dart';
import 'auth_page.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;
  final String token;
  
  ProfilePage({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Profile Photo dengan edit button
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7B5B18),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: user['photo'] != null && user['photo'].toString().isNotEmpty
                            ? Image.network(
                                user['photo'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFF7B5B18),
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: const Color(0xFF7B5B18),
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Color(0xFF7B5B18),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Info Cards
                _buildInfoCard(
                  label: 'Nama Pengguna',
                  value: user['name'] ?? 'Nama Pengguna',
                  icon: Icons.person_outline,
                  showEdit: true, // Hanya nama pengguna yang bisa diedit
                ),
                
                const SizedBox(height: 16),
                
                _buildInfoCard(
                  label: 'Email',
                  value: user['email'] ?? 'email@example.com',
                  icon: Icons.email_outlined,
                ),
                
                const SizedBox(height: 16),
                
                _buildInfoCard(
                  label: 'Jabatan',
                  value: user['jabatan'] ?? 'Ketua',
                  icon: Icons.work_outline,
                ),
                
                const SizedBox(height: 16),
                
                _buildInfoCard(
                  label: 'Awal Jabatan',
                  value: user['awal_jabatan'] ?? '-',
                  icon: Icons.calendar_today,
                ),
                
                const SizedBox(height: 16),
                
                _buildInfoCard(
                  label: 'Akhir Jabatan',
                  value: user['akhir_jabatan'] ?? '-',
                  icon: Icons.event,
                ),
                
                const SizedBox(height: 40),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Logout logic - kembali ke AuthPage
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC3545),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    bool showEdit = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7B5B18),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (showEdit)
            Icon(
              Icons.edit_outlined,
              color: Colors.grey.shade400,
              size: 20,
            ),
        ],
      ),
    );
  }
}