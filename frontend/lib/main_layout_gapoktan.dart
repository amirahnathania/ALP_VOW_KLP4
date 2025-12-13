// main_layout_gapoktan.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainLayoutGapoktan extends StatefulWidget {
  final Map<String, dynamic> user;
  final String token;

  const MainLayoutGapoktan({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  State<MainLayoutGapoktan> createState() => _MainLayoutGapoktanState();
}

class _MainLayoutGapoktanState extends State<MainLayoutGapoktan> {
  int _selectedIndex = 1; // Default ke "Dashboard" (Index 1)

  @override
  Widget build(BuildContext context) {
    // Pages untuk Gapoktan
    final List<Widget> pages = [
      _GapoktanCalendarWrapper(user: widget.user, token: widget.token),
      _GapoktanDashboardWrapper(user: widget.user, token: widget.token),
      _GapoktanProfileWrapper(user: widget.user, token: widget.token),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      body: Stack(
        children: [
          // Konten Halaman
          pages[_selectedIndex],
          
          // Custom Navbar (Posisi di bawah)
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
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
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0E0),
        borderRadius: BorderRadius.circular(50),
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
          _NavBarItem(
            icon: Icons.calendar_today_rounded,
            label: "Kalendar",
            isSelected: _selectedIndex == 0,
            onTap: () => _handleItemTapped(0),
          ),
          const SizedBox(width: 8),
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
      HapticFeedback.lightImpact();
    }
  }
}

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
    const activeColor = Color(0xFF4C7B0F);
    const inactiveColor = Colors.transparent;
    const fgColorActive = Colors.white;
    const fgColorInactive = Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
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

// Wrapper widgets yang akan menggunakan content dari home_gapoktan.dart
class _GapoktanCalendarWrapper extends StatelessWidget {
  final Map<String, dynamic> user;
  final String token;

  const _GapoktanCalendarWrapper({
    required this.user,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    // Akan menggunakan _buildCalendarSection dari mixin
    return _TemporaryCalendarPlaceholder();
  }
}

class _GapoktanDashboardWrapper extends StatelessWidget {
  final Map<String, dynamic> user;
  final String token;

  const _GapoktanDashboardWrapper({
    required this.user,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    // Akan menggunakan _buildDashboardSection dari mixin
    return _TemporaryDashboardPlaceholder();
  }
}

class _GapoktanProfileWrapper extends StatelessWidget {
  final Map<String, dynamic> user;
  final String token;

  const _GapoktanProfileWrapper({
    required this.user,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    // Akan menggunakan _buildProfileSection dari mixin
    return _TemporaryProfilePlaceholder();
  }
}

// Temporary placeholders - akan diganti dengan konten sebenarnya
class _TemporaryCalendarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('Kalender Gapoktan - Coming Soon'),
      ),
    );
  }
}

class _TemporaryDashboardPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('Dashboard Gapoktan - Coming Soon'),
      ),
    );
  }
}

class _TemporaryProfilePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('Profil Gapoktan - Coming Soon'),
      ),
    );
  }
}
