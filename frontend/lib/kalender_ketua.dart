// kalender_ketua.dart
import 'package:flutter/material.dart';
import 'models/tasks.dart';

// kalender_ketua.dart
class CalendarPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final String token;

  CalendarPage({super.key, required this.user, required this.token});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Color brown = const Color(0xFF7B5B18);
  final Color green = const Color(0xFF4CAF50);
  final Color cream = const Color(0xFFF2F0D8);
  final Color bg = const Color(0xFFF9F9F9);

  late Map<String, Color> eventColors;
  DateTime _visibleMonth = DateTime(2025, 12, 1);
  String? _selectedDay; // selected 'DD' in current visible month

  static const Map<String, int> _bulanId = {
    'Januari': 1,
    'Februari': 2,
    'Maret': 3,
    'April': 4,
    'Mei': 5,
    'Juni': 6,
    'Juli': 7,
    'Agustus': 8,
    'September': 9,
    'Oktober': 10,
    'November': 11,
    'Desember': 12,
  };

  @override
  void initState() {
    super.initState();
    _rebuildEventColors();
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
      _rebuildEventColors();
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
      _rebuildEventColors();
      _selectedDay = null;
    });
  }

  void _rebuildEventColors() {
    eventColors = {};
    for (final t in sharedTasks) {
      final parts = t.date.split(' '); // [DD, Bulan, YYYY]
      if (parts.length >= 3) {
        final day = parts[0].padLeft(2, '0');
        final bulan = _bulanId[parts[1]] ?? 0;
        final tahun = int.tryParse(parts[2]) ?? 0;
        if (bulan == _visibleMonth.month && tahun == _visibleMonth.year) {
          eventColors[day] = t.color;
        }
      }
    }
  }

  int _currentIndex = 0; // 0: Kalender, 1: Home, 2: Profil

  // Events for the currently visible month
  List<TaskItem> _eventsForVisibleMonth() {
    final all = _eventsForVisibleMonthHelper(_visibleMonth);
    if (_selectedDay == null) return all;
    final bulanName = _namaBulan(_visibleMonth.month);
    final target = '${_selectedDay!} $bulanName ${_visibleMonth.year}';
    return all.where((t) => t.date == target).toList();
  }

  // Weekday name (Indonesian) for the first event in the visible month
  String _firstEventWeekdayNameForVisibleMonth() {
    final events = _eventsForVisibleMonth();
    if (events.isEmpty) {
      if (_selectedDay == null) return '';
      final bulanName = _namaBulan(_visibleMonth.month);
      final day = int.tryParse(_selectedDay!) ?? 1;
      final month = _visibleMonth.month;
      final year = _visibleMonth.year;
      final dt = DateTime(year, month, day);
      return _namaHari(dt.weekday);
    }
    final parts = events.first.date.split(' '); // [DD, Bulan, YYYY]
    if (parts.length < 3) return '';
    final day = int.tryParse(parts[0]) ?? 1;
    final month = _bulanId[parts[1]] ?? 1;
    final year = int.tryParse(parts[2]) ?? DateTime.now().year;
    final dt = DateTime(year, month, day);
    return _namaHari(dt.weekday);
  }

  String _namaHari(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // Navbar dihandle oleh MainLayout
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

              /// ===== HEADER: DAFTAR KEGIATAN =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (_) {
                      return const Text(
                        'Daftar Kegiatan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// ===== SCHEDULE TIMELINE =====
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: _buildScheduleList(_eventsForVisibleMonth()),
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
          ],
        ),
    );
  }

  // Kalender Card

  Widget _buildCalendarCard() {
    // Build grid for current visible month
    final year = _visibleMonth.year;
    final month = _visibleMonth.month;
    final firstWeekday = DateTime(year, month, 1).weekday; // Mon=1..Sun=7
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Convert to Sunday-first columns (Min..Sab). Flutter's weekday Mon=1..Sun=7
    final startOffset = firstWeekday % 7; // Sun -> 0, Mon -> 1
    List<List<String>> calendarGrid = [];
    List<String> week = List.generate(7, (_) => '');
    int dayCounter = 1;
    for (int i = 0; i < startOffset; i++) {
      week[i] = '';
    }
    for (int i = startOffset; i < 7; i++) {
      week[i] = dayCounter.toString().padLeft(2, '0');
      dayCounter++;
    }
    calendarGrid.add(week);
    while (dayCounter <= daysInMonth) {
      week = List.generate(7, (_) => '');
      for (int i = 0; i < 7 && dayCounter <= daysInMonth; i++) {
        week[i] = dayCounter.toString().padLeft(2, '0');
        dayCounter++;
      }
      calendarGrid.add(week);
    }
    final now = DateTime.now();
    final isCurrentVisibleMonth = now.year == year && now.month == month;
    final String fallbackToday = isCurrentVisibleMonth
        ? now.day.toString().padLeft(2, '0')
        : '';
    final String selectedDay = _selectedDay ?? fallbackToday;

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
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _prevMonth,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.chevron_left, size: 22),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_namaBulan(month)} $year',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _nextMonth,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.chevron_right, size: 22),
                ),
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
                final isSelected = day == selectedDay && day.isNotEmpty;
                final isPrevMonth = false;
                final Color? eventColor = eventColors[day];
                final bool isToday =
                    (DateTime.now().year == _visibleMonth.year &&
                    DateTime.now().month == _visibleMonth.month &&
                    DateTime.now().day.toString().padLeft(2, '0') == day);
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 40,
                    height: 48,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Only color if there's an event on that day
                            color: eventColor ?? Colors.transparent,
                            // Today indicator: subtle ring around the circle
                            border: isToday
                                ? Border.all(color: Colors.black54, width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              // White text for colored event days, dark for others
                              color: isPrevMonth
                                  ? Colors.grey.withOpacity(0.5)
                                  : (eventColor != null
                                        ? Colors.white
                                        : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Penanda kegiatan: titik kecil dengan warna sesuai kegiatan
                        if (eventColor != null)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: eventColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const SizedBox(height: 8),
                      ],
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

  // Schedule List - Daftar Kegiatan (card style like Gapoktan)

  Widget _buildScheduleList(List<TaskItem> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kegiatan hari ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih tanggal lain untuk melihat kegiatan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < events.length; i++) ...[
          _buildTaskCard(events[i]),
          if (i != events.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  // Task Card (like Gapoktan style but without action buttons)
  Widget _buildTaskCard(TaskItem task) {
    final accent = task.color;
    // Simulasi progress (untuk Ketua tidak ada aksi, hanya tampilan)
    final progress = task.progress / 100.0;
    final percent = task.progress;
    // Simulasi jumlah pelapor (misal dari 4 total)
    final total = 4;
    final uploaded = (percent * total / 100).round();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: accent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showTaskDetail(task),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Time Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      task.time,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Date
                Text(
                  task.date,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                // Progress Bar
                _buildPhotoProgressBar(
                  progress: progress,
                  percent: percent,
                  uploaded: uploaded,
                  total: total,
                ),
                const SizedBox(height: 10),
                // Bukti Foto button (read-only for Ketua)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _showBuktiFotoInfo(task),
                      child: const Text('Bukti Foto'),
                    ),
                    const Spacer(),
                    // Avatar stack placeholder (representing reporters)
                    _buildAvatarStack(uploaded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoProgressBar({
    required double progress,
    required int percent,
    required int uploaded,
    required int total,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$percent% pelapor mengunggah foto ($uploaded/$total)',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAvatarStack(int count) {
    if (count == 0) return const SizedBox.shrink();
    
    final displayCount = count > 3 ? 3 : count;
    final overflow = count > 3 ? count - 3 : 0;
    const size = 34.0;
    const overlap = size * 0.55;
    final width = size + (displayCount > 1 ? (displayCount - 1) * overlap : 0) + (overflow > 0 ? size * 0.8 : 0);
    
    return SizedBox(
      height: size,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < displayCount; i++)
            Positioned(
              right: i * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.white70,
                ),
              ),
            ),
          if (overflow > 0)
            Positioned(
              right: displayCount * overlap,
              child: Container(
                width: size * 0.9,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showTaskDetail(TaskItem task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.calendar_today, 'Tanggal', task.date),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, 'Waktu', task.time),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.trending_up, 'Progress', '${task.progress}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value)),
      ],
    );
  }

  void _showBuktiFotoInfo(TaskItem task) {
    final uploaded = (task.progress * 4 / 100).round();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.photo_library, color: task.color),
            const SizedBox(width: 8),
            const Text('Bukti Foto'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.people, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$uploaded dari 4 pelapor telah mengunggah foto',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sebagai ketua kelompok, Anda dapat melihat progress pelaporan foto dari anggota.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

List<TaskItem> _eventsForVisibleMonthHelper(DateTime visibleMonth) {
  final int year = visibleMonth.year;
  final int month = visibleMonth.month;
  return sharedTasks.where((t) {
    final parts = t.date.split(' ');
    if (parts.length >= 3) {
      final dMonth = _CalendarPageState._bulanId[parts[1]] ?? 0;
      final dYear = int.tryParse(parts[2]) ?? 0;
      return dMonth == month && dYear == year;
    }
    return false;
  }).toList();
}

String _namaBulan(int bulan) {
  switch (bulan) {
    case 1:
      return 'Januari';
    case 2:
      return 'Februari';
    case 3:
      return 'Maret';
    case 4:
      return 'April';
    case 5:
      return 'Mei';
    case 6:
      return 'Juni';
    case 7:
      return 'Juli';
    case 8:
      return 'Agustus';
    case 9:
      return 'September';
    case 10:
      return 'Oktober';
    case 11:
      return 'November';
    case 12:
      return 'Desember';
    default:
      return '';
  }
}
