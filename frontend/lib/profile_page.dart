// profile_page.dart
import 'package:flutter/material.dart';
import 'kalender_ketua.dart';
import 'home_ketua.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            const Icon(Icons.person_outline, size: 96, color: Colors.black54),
            const SizedBox(height: 12),
            const Text(
              'Halaman Profil (placeholder)',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const Spacer(),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    const int currentIndex = 2; // Profile is active on this page

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

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF4),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          buildItem(
            active: currentIndex == 0,
            icon: Icons.calendar_today,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CalendarPage()),
              );
            },
          ),
          const SizedBox(width: 12),
          buildItem(
            active: currentIndex == 1,
            icon: Icons.home_outlined,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeKetuaPage()),
              );
            },
          ),
          const SizedBox(width: 12),
          buildItem(
            active: currentIndex == 2,
            icon: Icons.person_outline,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
