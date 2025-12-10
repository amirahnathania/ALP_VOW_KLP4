import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;  // ← TAMBAH INI
  final String token;               // ← TAMBAH INI
  
  ProfilePage({
    super.key,
    required this.user,             // ← TAMBAH INI
    required this.token,            // ← TAMBAH INI
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Profil',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 32),
            
            // Profile Icon/Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF7B5B18),
              child: user['photo'] != null
                  ? ClipOval(
                      child: Image.network(
                        user['photo'],
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // User Name
            Text(
              user['name'] ?? 'Nama Pengguna',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // User Email
            Text(
              user['email'] ?? 'email@example.com',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            ElevatedButton(
              onPressed: () {
                // Logout logic - kembali ke AuthPage
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
}