// home_ketua.dart
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Color brown = const Color(0xFF7B5B18);
  final Color green = const Color(0xFF4CAF50);
  final Color cream = const Color(0xFFF2F0D8);
  final Color bg = const Color(0xFFF9F9F9);

  int _currentIndex = 0; // 0: Kalender, 1: Home, 2: Profil

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            /// ===== TITLE =====
            Text(
              _currentIndex == 0
                  ? 'Kalender'
                  : _currentIndex == 1
                  ? 'Rumah'
                  : 'Profil',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 16),

            if (_currentIndex == 0) ...[
              /// ===== CARD KALENDER =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCalendarCard(),
              ),

              const SizedBox(height: 28),

              /// ===== HARI (SELASA) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selasa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// ===== SCHEDULE TIMELINE =====
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildScheduleList(),
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _currentIndex == 1
                            ? Icons.home_outlined
                            : Icons.person_outline,
                        size: 64,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentIndex == 1
                            ? 'Halaman Rumah (placeholder)'
                            : 'Halaman Profil (placeholder)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Navbar
            _buildBottomNav(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Kalender Card

  Widget _buildCalendarCard() {
    final List<List<String>> calendarGrid = [
      ['30', '01', '02', '03', '04', '05', '06'],
      ['07', '08', '09', '10', '11', '12', '13'],
      ['14', '15', '16', '17', '18', '19', '20'],
      ['21', '22', '23', '24', '25', '26', '27'],
      ['28', '29', '30', '31', '', '', ''],
    ];
    const selectedDay = '02';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Desember 2025',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  Icon(Icons.chevron_left, size: 22),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 22),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                .map(
                  (e) => Expanded(
                    child: Center(
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),

          ...List.generate(calendarGrid.length, (weekIndex) {
            final week = calendarGrid[weekIndex];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(week.length, (dayIndex) {
                final day = week[dayIndex];
                if (day.isEmpty) {
                  return const SizedBox(width: 34, height: 34);
                }
                final isSelected = day == selectedDay;
                final isPrevMonth = weekIndex == 0 && day == '30';
                return Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? brown : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white
                          : isPrevMonth
                          ? Colors.grey.withOpacity(0.5)
                          : Colors.black87,
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  // Schedule List (timeline)

  Widget _buildScheduleList() {
    return Column(
      children: [
        _buildTimelineItem(
          time: '08:00',
          hasEvent: true,
          eventTitle: 'Pengolahan Tanah',
          eventDescription: 'Lahan Masing - Masing',
          showLine: true,
        ),
        const SizedBox(height: 20),
        _buildTimelineItem(time: '09:00', hasEvent: false, showLine: true),
        const SizedBox(height: 20),
        _buildTimelineItem(time: '10:00', hasEvent: false, showLine: true),
        const SizedBox(height: 20),
        _buildTimelineItem(time: '11:00', hasEvent: false, showLine: false),
      ],
    );
  }

  // Timeline  (row)

  Widget _buildTimelineItem({
    required String time,
    bool hasEvent = false,
    String eventTitle = '',
    String eventDescription = '',
    bool showLine = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // time
        Container(
          width: 60,
          alignment: Alignment.topRight,
          padding: EdgeInsets.only(top: hasEvent ? 0 : 4),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // dot + line
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasEvent ? brown : Colors.grey[400],
              ),
            ),
            if (showLine) ...[
              const SizedBox(height: 4),
              Container(
                width: 2,
                height: hasEvent ? 60 : 40,
                color: Colors.black,
              ),
            ],
          ],
        ),
        const SizedBox(width: 12),
        if (hasEvent)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: brown,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eventDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const Expanded(child: SizedBox()),
      ],
    );
  }

  /// ================================================================
  /// NAVIGATION BAR (Disesuaikan dengan gambar - hanya "Kalendar")
  /// ================================================================
  /// ================================================================
  /// NAVIGATION BAR (3 tombol: Kalender kiri, Home tengah, Profil kanan)
  /// ================================================================
  Widget _buildBottomNav() {
    final bool isCalendar = _currentIndex == 0;
    final bool isHome = _currentIndex == 1;
    final bool isProfile = _currentIndex == 2;

    Widget buildPill({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        flex: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF62903A),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.black87, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildCircle({
      required IconData icon,
      required VoidCallback onTap,
      bool active = false,
    }) {
      return InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF62903A) : Colors.transparent,
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
            child: Icon(icon, color: active ? Colors.white : Colors.black87),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black12.withOpacity(0.15),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Calendar
          isCalendar
              ? buildPill(
                  icon: Icons.calendar_today,
                  label: 'Kalendar',
                  onTap: () => setState(() => _currentIndex = 0),
                )
              : buildCircle(
                  icon: Icons.calendar_today,
                  onTap: () => setState(() => _currentIndex = 0),
                  active: false,
                ),

          const SizedBox(width: 12),

          // Middle: Home
          isHome
              ? buildPill(
                  icon: Icons.home_outlined,
                  label: 'Rumah',
                  onTap: () => setState(() => _currentIndex = 1),
                )
              : buildCircle(
                  icon: Icons.home_outlined,
                  onTap: () => setState(() => _currentIndex = 1),
                  active: false,
                ),

          const SizedBox(width: 12),

          // Right: Profile
          isProfile
              ? buildPill(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  onTap: () => setState(() => _currentIndex = 2),
                )
              : buildCircle(
                  icon: Icons.person_outline,
                  onTap: () => setState(() => _currentIndex = 2),
                  active: false,
                ),
        ],
      ),
    );
  }
}
