import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'auth_page.dart';
import 'models/kegiatan.dart';
import 'services/weather_service.dart';
import 'services/api_service.dart';

part 'kalender_gapoktan.dart';
part 'home_modals.dart';
part 'profil_gapoktan.dart';

enum HomeSection { calendar, dashboard, profile }

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user, required this.token});

  final Map<String, dynamic> user;
  final String token;

  @override
  State<HomePage> createState() => _HomePageState();
}

abstract class _HomePageStateBase extends State<HomePage> {
  Color get _navButton => const Color(0xFF62903A);
  Color get _primaryGreen => const Color(0xFF617F59);
  Color get _primaryBrown => const Color(0xFF7B5B18);
  Color get _primaryGray => const Color(0xFF7F7E79);
  static const List<Color> _eventPalette = <Color>[
    Color(0xFF7B5B18),
    Color(0xFF617F59),
    Color(0xFF7F7E79),
    Color(0xFFD3AB58),
    Color(0xFF19A6A9),
  ];
  static const List<Map<String, String>> _reporterSamples =
      <Map<String, String>>[
        {'name': 'Kelompok Tani Mawar', 'email': 'mawar@desa.id'},
        {'name': 'Kelompok Tani Melati', 'email': 'melati@desa.id'},
        {'name': 'Kelompok Tani Anggrek', 'email': 'anggrek@desa.id'},
        {'name': 'Kelompok Tani Kenanga', 'email': 'kenanga@desa.id'},
      ];
  static const List<String> _dummyPhotoUrls = <String>[
    'https://images.unsplash.com/photo-1461354464878-ad92f492a5a0?auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1492496913980-501348b61469?auto=format&fit=crop&w=800&q=60',
  ];

  final ImagePicker _picker = ImagePicker();
  final List<Kegiatan> _kegiatan = <Kegiatan>[];
  final Map<DateTime, List<Kegiatan>> _eventsByDay =
      <DateTime, List<Kegiatan>>{};
  final Map<String, Color> _eventColors = <String, Color>{};
  final Random _random = Random();
  final List<Color> _colorCycle = <Color>[];
  int _colorCycleIndex = 0;
  late String _profileName;
  late String _profileEmail;
  String? _profilePhotoPath;

  HomeSection _activeSection = HomeSection.dashboard;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  late final DateFormat _dateFormatter;
  late final DateFormat _dateTimeFormatter;
  late final DateFormat _monthFormatter;

  // Weather data
  WeatherData? _currentWeather;
  List<DailyForecast>? _forecast;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _dateFormatter = DateFormat('d MMM yyyy', 'id_ID');
    _dateTimeFormatter = DateFormat('d MMM yyyy HH:mm', 'id_ID');
    _monthFormatter = DateFormat('MMMM yyyy', 'id_ID');
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay!;
    _profileName = (widget.user['name'] ?? 'Pengguna').toString();
    _profileEmail = (widget.user['email'] ?? '-').toString();
    final initialPhoto = widget.user['photo']?.toString();
    _profilePhotoPath = initialPhoto != null && initialPhoto.isNotEmpty
        ? initialPhoto
        : null;
    _resetColorCycle();
    _seedDummyData();
    _reindexEvents();
    _loadWeatherData();
    // Attempt to load real kegiatan/bukti from backend; keep seeded data as fallback
    _loadKegiatanFromApi();
  }

  TimeOfDay _parseTimeOfDay(String? s) {
    if (s == null) return const TimeOfDay(hour: 0, minute: 0);
    try {
      // Accept formats like '08:30:00' or '08:30'
      final parts = s.split(':');
      final hh = int.tryParse(parts[0]) ?? 0;
      final mm = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return TimeOfDay(hour: hh, minute: mm);
    } catch (_) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  Future<void> _loadKegiatanFromApi() async {
    try {
      final token = widget.token;
      if (token == null || token.isEmpty) return;

      final kegiatanResp = await ApiService.getKegiatanList(token: token);
      final buktiResp = await ApiService.getBuktiList(token: token);

      final List<dynamic> kegiatanData = kegiatanResp['data'] ?? [];
      final List<dynamic> buktiData = buktiResp['data'] ?? [];

      // Group bukti by idKegiatan
      final Map<String, List<dynamic>> buktiByKegiatan = {};
      for (final b in buktiData) {
        final idK = b['idKegiatan']?.toString() ?? '';
        buktiByKegiatan.putIfAbsent(idK, () => <dynamic>[]).add(b);
      }

      final List<Kegiatan> loaded = [];
      for (final item in kegiatanData) {
        try {
          final id = (item['id'] ?? '').toString();
          final keterangan = (item['keterangan'] ?? '').toString();
          final jenis = (item['jenisKegiatan'] ?? '').toString();
          final tanggalMulai = item['tanggalMulai'];
          final tanggalSelesai = item['tanggalSelesai'];
          final waktuMulai = item['waktuMulai']?.toString();
          final waktuSelesai = item['waktuSelesai']?.toString();
          final jenisPestisida = (item['jenisPestisida'] ?? '').toString();
          final target = (item['targetPenanaman'] ?? '').toString();

          final DateTime startDate = DateTime.parse(
            tanggalMulai.toString(),
          ).toLocal();
          final DateTime endDate = DateTime.parse(
            tanggalSelesai.toString(),
          ).toLocal();
          final TimeOfDay tStart = _parseTimeOfDay(waktuMulai);
          final TimeOfDay tEnd = _parseTimeOfDay(waktuSelesai);

          final List<dynamic> buktiFor = buktiByKegiatan[id] ?? [];
          final List<PhotoEvidence> evidences = buktiFor.map<PhotoEvidence>((
            b,
          ) {
            final uploadedAtRaw = b['createdAt'] ?? b['created_at'] ?? '';
            DateTime uploadedAt;
            try {
              uploadedAt = DateTime.parse(uploadedAtRaw.toString()).toLocal();
            } catch (_) {
              uploadedAt = DateTime.now();
            }
            // Prefer explicit imageUrl from API; fall back to namaFoto provided by backend
            String imageUrl = '';
            if ((b['imageUrl'] ?? '').toString().isNotEmpty) {
              imageUrl = b['imageUrl']?.toString() ?? '';
            } else if ((b['image_url'] ?? '').toString().isNotEmpty) {
              imageUrl = b['image_url']?.toString() ?? '';
            } else if ((b['namaFoto'] ?? '').toString().isNotEmpty) {
              imageUrl = ApiService.imageUrlFromName(
                (b['namaFoto'] ?? '').toString(),
              );
            } else if ((b['nama_foto'] ?? '').toString().isNotEmpty) {
              imageUrl = ApiService.imageUrlFromName(
                (b['nama_foto'] ?? '').toString(),
              );
            }

            return PhotoEvidence(
              id: (b['id'] ?? '').toString(),
              uploaderName:
                  (b['namaPengguna'] ??
                          b['profil']?['user']?['nama_pengguna'] ??
                          '')
                      .toString(),
              uploaderRole: (b['jabatan'] ?? '').toString(),
              uploaderEmail: '',
              uploadedAt: uploadedAt,
              imagePath: imageUrl,
            );
          }).toList();

          final kegiatan = Kegiatan(
            id: id,
            keterangan: keterangan,
            jenisPenanaman: jenis,
            startDate: startDate,
            endDate: endDate,
            waktuMulai: tStart,
            waktuSelesai: tEnd,
            jenisPestisida: jenisPestisida,
            targetPenanaman: target,
            buktiFoto: evidences,
          );

          loaded.add(kegiatan);
        } catch (e) {
          debugPrint('Mapping kegiatan error: $e');
        }
      }

      if (mounted && loaded.isNotEmpty) {
        setState(() {
          _kegiatan
            ..clear()
            ..addAll(loaded);
          _resetColorCycle();
          _reindexEvents();
        });
      }
    } catch (e) {
      debugPrint('Failed to load kegiatan from API: $e');
    }
  }

  String _formatDateString(dynamic raw) {
    if (raw == null) return '-';
    try {
      final s = raw.toString();
      final dt = DateTime.parse(s);
      return DateFormat('dd MMM yyyy').format(dt.toLocal());
    } catch (_) {
      try {
        final s = raw.toString();
        if (s.contains('T')) return s.split('T').first;
        return s;
      } catch (_) {
        return '-';
      }
    }
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoadingWeather = true);

    final weather = await WeatherService.getCurrentWeather();
    final forecast = await WeatherService.get7DayForecast();

    if (mounted) {
      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoadingWeather = false;
      });
    }
  }

  /// Refresh main data used across sections: kegiatan, weather, and profile.
  Future<void> _refreshAll() async {
    try {
      // Always try to refresh kegiatan and weather
      await Future.wait([_loadKegiatanFromApi(), _loadWeatherData()]);

      // Attempt to refresh user profile fields if we have an ID and token
      try {
        final idRaw = widget.user['id'];
        final token = widget.token;
        if (idRaw != null && token != null && token.isNotEmpty) {
          final id = int.tryParse(idRaw.toString());
          if (id != null) {
            final u = await ApiService.getUserById(id, token);
            if (mounted) {
              setState(() {
                _profileName = (u['name'] ?? _profileName).toString();
                _profileEmail = (u['email'] ?? _profileEmail).toString();
                final photo = (u['photo'] ?? u['profil']?['photo'])?.toString();
                if (photo != null && photo.isNotEmpty) {
                  _profilePhotoPath = photo;
                }
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to refresh profile: $e');
      }
    } catch (e) {
      debugPrint('Refresh failed: $e');
    }
  }

  Color _colorFor(Kegiatan kegiatan) {
    return _eventColors.putIfAbsent(kegiatan.id, _nextAccent);
  }

  Color _nextAccent() {
    if (_colorCycle.isEmpty || _colorCycleIndex >= _colorCycle.length) {
      _resetColorCycle();
    }
    return _colorCycle[_colorCycleIndex++];
  }

  void _removeColor(String kegiatanId) {
    _eventColors.remove(kegiatanId);
  }

  void _resetColorCycle() {
    _colorCycle
      ..clear()
      ..addAll(_eventPalette);
    _colorCycle.shuffle(_random);
    _colorCycleIndex = 0;
  }

  int get _photoReporterTarget => _reporterSamples.length;

  bool _isRemoteImage(String path) => path.startsWith('http');

  int _uploadedPhotoCount(Kegiatan kegiatan) {
    return kegiatan.buktiFoto
        .map((photo) => photo.uploaderEmail)
        .where((email) => email.isNotEmpty)
        .toSet()
        .length;
  }

  double _photoProgressValue(Kegiatan kegiatan) {
    if (_photoReporterTarget == 0) return 0;
    return _uploadedPhotoCount(kegiatan) / _photoReporterTarget;
  }

  Widget _buildAvatarStack(
    Kegiatan kegiatan, {
    double size = 30,
    Alignment alignment = Alignment.centerRight,
  }) {
    final evidences = kegiatan.buktiFoto;
    if (evidences.isEmpty) return const SizedBox.shrink();
    final display = evidences.take(3).toList();
    final overflow = evidences.length - display.length;
    final overlap = size * 0.55;
    final width =
        size +
        (display.length > 1 ? (display.length - 1) * overlap : 0) +
        (overflow > 0 ? size * 0.8 : 0);

    return Align(
      alignment: alignment,
      child: SizedBox(
        height: size,
        width: width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < display.length; i++)
              Positioned(
                right: i * overlap,
                child: _buildAvatarCircle(
                  display[display.length - 1 - i],
                  size,
                ),
              ),
            if (overflow > 0)
              Positioned(
                right: display.length * overlap,
                child: _buildOverflowCircle(overflow, size),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(PhotoEvidence evidence, double size) {
    final imageProvider = _imageProviderFor(evidence.imagePath);
    final initials = _initialsFor(evidence.uploaderName);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: _withOpacity(_primaryGreen, 0.2),
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildOverflowCircle(int extra, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _primaryBrown,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$extra',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ImageProvider? _imageProviderFor(String path) {
    if (path.isEmpty) return null;
    if (_isRemoteImage(path)) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  String _initialsFor(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    final buffer = StringBuffer();
    for (final part in parts.take(2)) {
      if (part.isNotEmpty) {
        buffer.write(part[0]);
      }
    }
    return buffer.toString().toUpperCase();
  }

  Future<void> _editProfileName() async {
    await _editProfileField(
      title: 'Ubah Nama Pengguna',
      initialValue: _profileName,
      keyboardType: TextInputType.name,
      onSaved: (value) => _profileName = value,
    );
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _profilePhotoPath = file.path);
  }

  void _resetProfilePhoto() {
    setState(() => _profilePhotoPath = null);
  }

  Future<void> _showProfilePhotoActions() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih Foto dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePhoto();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text('Hapus Foto Profil'),
                onTap: () {
                  Navigator.pop(context);
                  _resetProfilePhoto();
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editProfileField({
    required String title,
    required String initialValue,
    required TextInputType keyboardType,
    required void Function(String value) onSaved,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
    if (!mounted || result == null || result.isEmpty) return;
    setState(() => onSaved(result));
  }

  PhotoEvidence _sampleEvidence({
    required int reporterIndex,
    required String activityId,
    required DateTime timestamp,
  }) {
    final reporter = _reporterSamples[reporterIndex % _reporterSamples.length];
    final photoUrl = _dummyPhotoUrls[reporterIndex % _dummyPhotoUrls.length];
    return PhotoEvidence(
      id: '$activityId-foto-$reporterIndex',
      uploaderName: reporter['name']!,
      uploaderRole: 'Petugas Lapangan',
      uploaderEmail: reporter['email']!,
      uploadedAt: timestamp,
      imagePath: photoUrl,
    );
  }

  void _seedDummyData() {
    if (_kegiatan.isNotEmpty) return;

    final today = DateTime.now();
    final base = DateTime(today.year, today.month, 1);

    final List<Kegiatan> sharedEvents = <Kegiatan>[
      Kegiatan(
        id: 'seed-rapat-gapoktan',
        keterangan: 'Rapat Koordinasi Musim Tanam',
        jenisPenanaman: 'Padi Inpari 32',
        startDate: base.add(const Duration(days: 3)),
        endDate: base.add(const Duration(days: 3)),
        waktuMulai: const TimeOfDay(hour: 9, minute: 0),
        waktuSelesai: const TimeOfDay(hour: 11, minute: 0),
        jenisPestisida: 'Organik Cair',
        targetPenanaman: 'Blok A & B',
      ),
      Kegiatan(
        id: 'seed-penyuluhan',
        keterangan: 'Penyuluhan Teknologi Tanam Jajar Legowo',
        jenisPenanaman: 'Padi Ciherang',
        startDate: base.add(const Duration(days: 10)),
        endDate: base.add(const Duration(days: 11)),
        waktuMulai: const TimeOfDay(hour: 8, minute: 30),
        waktuSelesai: const TimeOfDay(hour: 12, minute: 0),
        jenisPestisida: 'Hayati',
        targetPenanaman: 'Kelompok Tani Mawar',
      ),
      Kegiatan(
        id: 'seed-penanaman-serentak',
        keterangan: 'Penanaman Serentak Musim Rendeng',
        jenisPenanaman: 'Jagung Hibrida',
        startDate: base.add(const Duration(days: 17)),
        endDate: base.add(const Duration(days: 19)),
        waktuMulai: const TimeOfDay(hour: 7, minute: 0),
        waktuSelesai: const TimeOfDay(hour: 10, minute: 0),
        jenisPestisida: 'Kontak Selektif',
        targetPenanaman: 'Blok C-D',
      ),
    ];

    _kegiatan
      ..clear()
      ..addAll(sharedEvents);

    List<PhotoEvidence> buildEvidence(
      String id,
      DateTime anchor,
      List<int> reporters,
    ) {
      return reporters.asMap().entries.map((entry) {
        final order = entry.key;
        final reporterIndex = entry.value;
        final time = anchor.add(Duration(hours: 9 + order * 2));
        return _sampleEvidence(
          reporterIndex: reporterIndex,
          activityId: id,
          timestamp: time,
        );
      }).toList();
    }

    final Map<String, List<PhotoEvidence>> dummyBukti =
        <String, List<PhotoEvidence>>{
          'seed-rapat-gapoktan': buildEvidence(
            'seed-rapat-gapoktan',
            base.add(const Duration(days: 3)),
            const <int>[0, 1, 2],
          ),
          'seed-penyuluhan': buildEvidence(
            'seed-penyuluhan',
            base.add(const Duration(days: 10)),
            const <int>[0, 2, 3, 1],
          ),
          'seed-penanaman-serentak': buildEvidence(
            'seed-penanaman-serentak',
            base.add(const Duration(days: 19)),
            const <int>[1, 3],
          ),
        };

    List<PhotoEvidence> fallbackEvidence(Kegiatan kegiatan, int index) {
      final baseHour = 8 + (index % 3);
      final count = 3 + (index % 2); // 3 atau 4 bukti untuk variasi
      return List<PhotoEvidence>.generate(count, (i) {
        final reporterIndex = (index + i) % _reporterSamples.length;
        return _sampleEvidence(
          reporterIndex: reporterIndex,
          activityId: kegiatan.id,
          timestamp: kegiatan.startDate.add(Duration(hours: baseHour + i * 2)),
        );
      });
    }

    for (var i = 0; i < _kegiatan.length; i++) {
      if (_kegiatan[i].buktiFoto.isNotEmpty) continue;
      final bukti =
          dummyBukti[_kegiatan[i].id] ?? fallbackEvidence(_kegiatan[i], i);
      _kegiatan[i] = _kegiatan[i].copyWith(buktiFoto: bukti);
    }

    for (final kegiatan in _kegiatan) {
      _colorFor(kegiatan);
    }
  }

  List<Kegiatan> _eventsOfDay(DateTime day) {
    final key = _normalizeDay(day);
    return List<Kegiatan>.unmodifiable(_eventsByDay[key] ?? <Kegiatan>[]);
  }

  void _reindexEvents() {
    _eventsByDay.clear();
    for (final kegiatan in _kegiatan) {
      var cursor = _normalizeDay(kegiatan.startDate);
      final end = _normalizeDay(kegiatan.endDate);
      while (!cursor.isAfter(end)) {
        final list = _eventsByDay.putIfAbsent(cursor, () => <Kegiatan>[]);
        if (!list.contains(kegiatan)) {
          list.add(kegiatan);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
  }

  bool _isRangeClashing(DateTime start, DateTime end, {String? exceptId}) {
    var cursor = _normalizeDay(start);
    final endDay = _normalizeDay(end);
    while (!cursor.isAfter(endDay)) {
      final events = _eventsByDay[cursor];
      if (events != null && events.any((event) => event.id != exceptId)) {
        return true;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return false;
  }

  DateTime _normalizeDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Color _withOpacity(Color color, double opacity) => color.withOpacity(opacity);

  String _formatTime(TimeOfDay time) {
    final dt = DateTime(0, 1, 1, time.hour, time.minute);
    return DateFormat('HH:mm', 'id_ID').format(dt);
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatRange(DateTimeRange? range) {
    if (range == null) return 'Pilih rentang tanggal';
    return '${_dateFormatter.format(range.start)} - ${_dateFormatter.format(range.end)}';
  }

  void _openActionsForDay(DateTime day);
  Future<void> _openEventForm({Kegiatan? existing});
  void _showDetail(Kegiatan kegiatan);
  void _showBuktiFoto(Kegiatan kegiatan);
  void _confirmDelete(Kegiatan kegiatan);
}

class _HomePageState extends _HomePageStateBase
    with _HomeSectionsMixin, _HomeModalsMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      body: Stack(
        children: [
          // Konten halaman
          Positioned.fill(
            child: SafeArea(bottom: false, child: _buildSection()),
          ),

          // Navbar floating di bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 16),
              child: Center(child: _buildNavbar()),
            ),
          ),
        ],
      ),
    );
  }
}
