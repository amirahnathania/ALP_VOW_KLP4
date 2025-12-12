// kalender_ketua.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/kegiatan.dart';

class CalendarPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final String token;

  const CalendarPage({super.key, required this.user, required this.token});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Colors
  final Color _primaryBrown = const Color(0xFF7B5B18);
  final Color _primaryGreen = const Color(0xFF62903A);
  final Color _primaryGray = const Color(0xFF9E9E9E);

  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Data kegiatan (mock data - read-only untuk ketua)
  final List<Kegiatan> _kegiatan = [
    Kegiatan(
      id: '1',
      jenisPenanaman: 'Penanaman Padi',
      startDate: DateTime(2025, 12, 15),
      endDate: DateTime(2025, 12, 16),
      waktuMulai: const TimeOfDay(hour: 8, minute: 0),
      waktuSelesai: const TimeOfDay(hour: 12, minute: 0),
      targetPenanaman: '2 Hektar',
      jenisPestisida: 'Organik A',
      keterangan: 'Area sawah utara',
      buktiFoto: [],
    ),
    Kegiatan(
      id: '2',
      jenisPenanaman: 'Pemupukan',
      startDate: DateTime(2025, 12, 20),
      endDate: DateTime(2025, 12, 21),
      waktuMulai: const TimeOfDay(hour: 7, minute: 0),
      waktuSelesai: const TimeOfDay(hour: 11, minute: 0),
      targetPenanaman: '3 Hektar',
      jenisPestisida: '',
      keterangan: 'Pupuk organik',
      buktiFoto: [],
    ),
  ];

  final Map<String, Color> _kegiatanColors = {};
  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMMM yyyy', 'id');
  final DateFormat _monthFormatter = DateFormat('MMMM yyyy', 'id');

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _reindexEvents();
  }

  void _reindexEvents() {
    _kegiatanColors.clear();
    final colors = [
      const Color(0xFF4C7B0F),
      const Color(0xFF7B5B18),
      const Color(0xFFB8860B),
      const Color(0xFF8B4513),
      const Color(0xFF556B2F),
    ];
    for (int i = 0; i < _kegiatan.length; i++) {
      _kegiatanColors[_kegiatan[i].id] = colors[i % colors.length];
    }
  }

  Color _colorFor(Kegiatan kegiatan) {
    return _kegiatanColors[kegiatan.id] ?? _primaryGreen;
  }

  Color _withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  List<Kegiatan> _eventsOfDay(DateTime day) {
    return _kegiatan.where((kegiatan) {
      return (isSameDay(kegiatan.startDate, day) ||
          isSameDay(kegiatan.endDate, day) ||
          (day.isAfter(kegiatan.startDate) && day.isBefore(kegiatan.endDate)));
    }).toList();
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }



  @override
  Widget build(BuildContext context) {
    final selectedEvents = _eventsOfDay(_selectedDay ?? DateTime.now());
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Kalender Kegiatan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),
              
              // Calendar Card (tanpa tombol tambah)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _withOpacity(_primaryGray, 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: _withOpacity(Colors.black, 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCalendarHeader(),
                    const SizedBox(height: 8),
                    TableCalendar<Kegiatan>(
                      locale: 'id',
                      firstDay: DateTime.utc(2018, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Bulan',
                        CalendarFormat.twoWeeks: '2 Pekan',
                        CalendarFormat.week: 'Pekan',
                      },
                      eventLoader: _eventsOfDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerVisible: false,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        selectedDecoration: BoxDecoration(
                          border: Border.all(color: _primaryBrown, width: 2),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.15),
                          border: Border.all(color: _primaryGreen, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) =>
                            _buildDayCell(day),
                        todayBuilder: (context, day, focusedDay) =>
                            _buildDayCell(day, highlightToday: true),
                        selectedBuilder: (context, day, focusedDay) =>
                            _buildDayCell(day, isSelected: true),
                      ),
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                      },
                      onPageChanged: (focused) =>
                          setState(() => _focusedDay = focused),
                      onFormatChanged: (format) =>
                          setState(() => _calendarFormat = format),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 18),
              Text(
                selectedEvents.isEmpty
                    ? 'Belum ada kegiatan pada tanggal ini'
                    : 'Kegiatan pada ${_dateFormatter.format(_selectedDay ?? DateTime.now())}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedEvents.isEmpty ? _primaryGray : _primaryBrown,
                ),
              ),
              const SizedBox(height: 12),
              ...selectedEvents.map(_buildEventCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month - 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _monthFormatter.format(_focusedDay),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kalender Kegiatan',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month + 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool highlightToday = false,
    bool isSelected = false,
  }) {
    final events = _eventsOfDay(day);
    final hasOverlap = events.length > 1;
    final hasEvent = events.isNotEmpty;
    LinearGradient? gradient;
    Color? fillColor;
    if (hasEvent) {
      final List<Color> colors = events.map(_colorFor).toList();
      if (hasOverlap) {
        final List<Color> uniqueColors = <Color>[];
        for (final color in colors) {
          if (!uniqueColors.any((c) => c.value == color.value)) {
            uniqueColors.add(color);
          }
        }
        if (uniqueColors.length == 1) {
          fillColor = uniqueColors.first;
        } else {
          gradient = LinearGradient(colors: uniqueColors);
        }
      } else {
        fillColor = colors.first;
      }
    }
    BoxDecoration? decoration;
    if (hasEvent) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        color: gradient == null ? fillColor : null,
        border: isSelected
            ? Border.all(color: Colors.black, width: 2)
            : highlightToday
            ? Border.all(color: _primaryGray, width: 1.2)
            : null,
      );
    } else if (highlightToday) {
      // Tampilkan dekorasi untuk hari ini meskipun tidak ada event
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: _primaryGreen.withOpacity(0.15),
        border: Border.all(color: _primaryGreen, width: 2),
      );
    } else if (isSelected) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _primaryBrown, width: 2),
      );
    }

    return Center(
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: hasEvent ? Colors.white : Colors.black,
            fontWeight: hasEvent ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Kegiatan kegiatan) {
    final accent = _colorFor(kegiatan);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _withOpacity(accent, 0.12),
        border: Border.all(color: _withOpacity(accent, 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kegiatan.jenisPenanaman,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (kegiatan.keterangan.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        kegiatan.keterangan,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_dateFormatter.format(kegiatan.startDate)} - ${_dateFormatter.format(kegiatan.endDate)}',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: kegiatan.jenisPenanaman),
              _Chip(
                label:
                    'Waktu ${_formatTimeRange(kegiatan.waktuMulai, kegiatan.waktuSelesai)}',
              ),
              _Chip(label: 'Target ${kegiatan.targetPenanaman}'),
              if (kegiatan.jenisPestisida.isNotEmpty)
                _Chip(label: 'Pestisida ${kegiatan.jenisPestisida}'),
            ],
          ),
        ],
      ),
    );
  }
}

// Chip widget untuk menampilkan info singkat
class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }
}
