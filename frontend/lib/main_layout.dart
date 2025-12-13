// main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Haptic Feedback
import 'home_ketua.dart';
import 'kalender_ketua.dart';
import 'profile_page.dart';

class MainLayoutScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String token;

  const MainLayoutScreen({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 1; // Default ke "Rumah" (Index 1)

  @override
  Widget build(BuildContext context) {
    // Pages dengan data user dan token
    final List<Widget> pages = [
      CalendarPage(user: widget.user, token: widget.token),
      HomeKetuaPage(user: widget.user, token: widget.token),
      ProfilePage(user: widget.user, token: widget.token),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4), // Background sesuai desain
      body: Stack(
        children: [
          // 1. Konten Halaman
          Positioned.fill(
            child: pages[_selectedIndex],
          ),
          
          // 2. Custom Navbar (Posisi di bawah)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: _buildCustomNavbar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavbar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0E0),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavItem(
            icon: Icons.calendar_today_rounded,
            label: 'Kalender',
            isActive: _selectedIndex == 0,
            onTap: () => _handleItemTapped(0),
          ),
          const SizedBox(width: 4),
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'Rumah',
            isActive: _selectedIndex == 1,
            onTap: () => _handleItemTapped(1),
          ),
          const SizedBox(width: 4),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Profil',
            isActive: _selectedIndex == 2,
            onTap: () => _handleItemTapped(2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF4C7B0F);
    const fgColorActive = Colors.white;
    const fgColorInactive = Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? fgColorActive : fgColorInactive,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: fgColorActive,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // Efek getar ringan saat tap (UX yang bagus)
      HapticFeedback.lightImpact();
    }
  }
}
