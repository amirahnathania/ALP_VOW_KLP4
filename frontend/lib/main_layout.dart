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
          pages[_selectedIndex],
          
          // 2. Custom Navbar (Posisi di bawah)
          Positioned(
            left: 0,
            right: 0,
            bottom: 30, // Jarak dari bawah layar
            child: Center(
              child: _buildCustomNavbar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavbar() {
    return Container(
      // Ukuran container utama navbar
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0E0), // Warna Cream sesuai desain
        borderRadius: BorderRadius.circular(50), // Membuatnya berbentuk kapsul
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10), // Shadow halus di bawah
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Agar lebar navbar menyesuaikan isi
        children: [
          _NavBarItem(
            icon: Icons.calendar_today_rounded,
            label: "Kalendar",
            isSelected: _selectedIndex == 0,
            onTap: () => _handleItemTapped(0),
          ),
          const SizedBox(width: 8), // Jarak antar item
          _NavBarItem(
            icon: Icons.home_rounded,
            label: "Rumah",
            isSelected: _selectedIndex == 1,
            onTap: () => _handleItemTapped(1),
          ),
          const SizedBox(width: 8),
          _NavBarItem(
            icon: Icons.person_rounded,
            label: "Profil",
            isSelected: _selectedIndex == 2,
            onTap: () => _handleItemTapped(2),
          ),
        ],
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

// --- WIDGET ITEM NAVBAR YANG TERPISAH (CLEAN CODE) ---

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warna Diambil dari desain Anda
    const activeColor = Color(0xFF4C7B0F); // Hijau Tua
    const inactiveColor = Colors.transparent;
    const fgColorActive = Colors.white;
    const fgColorInactive = Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // INI KUNCI ANIMASINYA
        duration: const Duration(milliseconds: 400), // Durasi transisi
        curve: Curves.easeOutQuart, // Kurva animasi "mahal" (smooth ending)
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? fgColorActive : fgColorInactive,
              size: 26,
            ),
            // Trik untuk animasi Text muncul/hilang dengan smooth
            // Kita gunakan AnimatedSize atau ClipRect, tapi cara paling simple
            // dan performant di AnimatedContainer adalah mengatur width secara implisit via Row
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: fgColorActive,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
