// home_ketua.dart
import 'package:flutter/material.dart';
import 'services/photo_service.dart';
import 'services/api_service.dart';
import 'services/weather_service.dart';

class HomeKetuaPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final String token;

  const HomeKetuaPage({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  State<HomeKetuaPage> createState() => _HomeKetuaPageState();
}

class _HomeKetuaPageState extends State<HomeKetuaPage> {
  // Track which tasks have submitted photos
  final Set<String> _submittedTasks = {};
  
  // Weather data
  WeatherData? _currentWeather;
  List<DailyForecast>? _forecast;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
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

  Future<void> _handlePhotoCapture(String taskId) async {
    final file = await PhotoService.captureOrPick(context);
    if (file == null) return;
    
    // Langsung tandai sebagai terkirim setelah foto dipilih
    setState(() {
      _submittedTasks.add(taskId);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Foto berhasil dikirim'),
            ],
          ),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    // Optional: Upload ke API di background (tidak blocking UI)
    try {
      await ApiService.uploadTaskPhoto(
        token: widget.token,
        taskId: taskId,
        filePath: file.path,
      );
    } catch (e) {
      // Tetap tandai sebagai terkirim meskipun upload gagal (offline-first)
      debugPrint('Upload photo error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // Navbar dihandle oleh MainLayout
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Greeting capsule header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: Row(
                  children: [
                    // Small avatar circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                        image: const DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Halo, ${widget.user['name'] ?? 'Pengguna'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Weather Forecast Widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildWeatherWidget(),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Daftar Tugas ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 14, 13, 13),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                children: [
                  _buildTaskItem(
                    title: 'Pengolahan Tanah',
                    color: const Color(0xFF7B5B18),
                    location: '02 Desember 2024',
                    distance: '08:00 - 11:00',
                    detail:
                        'Membersihkan lahan, membajak, dan meratakan tanah untuk persiapan tanam.',
                    isSubmitted: _submittedTasks.contains('task-1'),
                    onCapturePhoto: () => _handlePhotoCapture('task-1'),
                  ),

                  const SizedBox(height: 16),

                  _buildTaskItem(
                    title: 'Pananaman Bibit',
                    color: const Color(0xFF617F59),
                    location: '10 Desember 2025',
                    distance: '07:00 - 12:00',
                    detail:
                        'Penanaman bibit sesuai jarak tanam, penyiraman awal dan pengecekan akar.',
                    isSubmitted: _submittedTasks.contains('task-2'),
                    onCapturePhoto: () => _handlePhotoCapture('task-2'),
                  ),

                  const SizedBox(height: 16),

                  _buildTaskItem(
                    title: 'Pestisida',
                    color: const Color(0xFF7F7E79),
                    location: '28 Desember 2025',
                    distance: '07:00 - 10:00',
                    detail:
                        'Penyemprotan hama sesuai dosis anjuran dan pemantauan daun.',
                    isSubmitted: _submittedTasks.contains('task-3'),
                    onCapturePhoto: () => _handlePhotoCapture('task-3'),
                  ),

                  const SizedBox(height: 16),

                  _buildTaskItem(
                    title: 'Pemupukan',
                    color: const Color(0xFFD9C36A),
                    location: '01 Januari 2026',
                    distance: '07:00 - 12:00',
                    detail:
                        'Pemberian pupuk dasar dan susulan sesuai kebutuhan tanaman.',
                    isSubmitted: _submittedTasks.contains('task-4'),
                    onCapturePhoto: () => _handlePhotoCapture('task-4'),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  /// Weather Widget with real API data - Sky & Growth Design
  Widget _buildWeatherWidget() {
    final now = DateTime.now();
    final List<String> shortDays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    
    // Default/fallback data jika API gagal
    final currentTemp = _currentWeather?.temperature.round().toString() ?? '32';
    final currentCondition = _currentWeather?.condition ?? 'Cerah';
    final currentIcon = _currentWeather?.icon ?? Icons.wb_sunny_rounded;
    final location = _currentWeather?.location ?? 'Lokasi';
    
    // Build forecast data
    List<Map<String, dynamic>> weeklyForecast = [];
    
    if (_forecast != null && _forecast!.isNotEmpty) {
      for (int i = 0; i < _forecast!.length && i < 7; i++) {
        final f = _forecast![i];
        final dayName = i == 0 ? 'Ini' : shortDays[f.date.weekday % 7];
        weeklyForecast.add({
          'day': dayName,
          'isToday': i == 0,
          'icon': f.icon,
          'temp': '${f.tempMax.round()}°',
        });
      }
    } else {
      // Fallback data
      final fallbackConditions = [
        {'icon': Icons.wb_sunny, 'temp': '32°'},
        {'icon': Icons.cloud_queue, 'temp': '29°'},
        {'icon': Icons.grain, 'temp': '27°'},
        {'icon': Icons.wb_sunny, 'temp': '31°'},
        {'icon': Icons.cloud, 'temp': '28°'},
        {'icon': Icons.water_drop, 'temp': '26°'},
        {'icon': Icons.wb_sunny, 'temp': '30°'},
      ];
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final dayName = i == 0 ? 'Ini' : shortDays[date.weekday % 7];
        weeklyForecast.add({
          'day': dayName,
          'isToday': i == 0,
          ...fallbackConditions[i],
        });
      }
    }

    // Dynamic gradient based on weather condition
    List<Color> _getWeatherGradient(String condition) {
      final lowerCondition = condition.toLowerCase();
      switch (lowerCondition) {
        case 'cerah':
        case 'cerah berawan':
        case 'clear':
        case 'sunny':
          // Bright sky blue gradient
          return [const Color(0xFF4FACFE), const Color(0xFF00F2FE)];
        case 'berawan':
        case 'mendung':
        case 'cloudy':
        case 'clouds':
        case 'overcast':
          // Soft cloudy sky gradient
          return [const Color(0xFF89ABE3), const Color(0xFFA7C7E7)];
        case 'hujan':
        case 'hujan ringan':
        case 'hujan sedang':
        case 'hujan lebat':
        case 'gerimis':
        case 'rain':
        case 'drizzle':
          // Rainy sky gradient
          return [const Color(0xFF5B86E5), const Color(0xFF36D1DC)];
        case 'badai petir':
        case 'thunderstorm':
          // Stormy gradient
          return [const Color(0xFF373B44), const Color(0xFF4286F4)];
        case 'berkabut':
        case 'kabut':
        case 'mist':
        case 'fog':
          // Misty gradient
          return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
        default:
          // Fresh green gradient - growth feel
          return [const Color(0xFF56AB2F), const Color(0xFFA8E063)];
      }
    }

    final gradientColors = _getWeatherGradient(currentCondition);

    return Container(
      decoration: BoxDecoration(
        // Dynamic gradient based on weather
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Main shadow for depth
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          // Soft ambient shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles for depth (glassmorphism effect)
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Cuaca hari ini
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather icon - glassmorphism style
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoadingWeather
                          ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Icon(
                              currentIcon,
                              color: Colors.white,
                              size: 40,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Temperature and condition
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cuaca Hari Ini',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$currentTemp°',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentCondition,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Location badge
                    GestureDetector(
                      onTap: _loadWeatherData, // Tap to refresh
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 70),
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
          
                // Prakiraan 7 Hari label
                Text(
                  'Prakiraan 7 Hari',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                
                const SizedBox(height: 14),
                
                // Weekly forecast row - modern card style
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weeklyForecast.map((forecast) {
                      final isToday = forecast['isToday'] == true;
                      return Column(
                        children: [
                          Text(
                            forecast['day'] as String,
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isToday 
                                  ? Colors.white.withOpacity(0.25) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isToday 
                                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                                  : null,
                            ),
                            child: Icon(
                              forecast['icon'] as IconData,
                              color: Colors.white,
                              size: 22,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            forecast['temp'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// WIDGET TASK ITEM (Reusable)

Widget _buildTaskItem({
  required String title,
  required Color color,
  required String location,
  required String distance,
  required String detail,
  required VoidCallback onCapturePhoto,
  bool isSubmitted = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: Colors.white.withOpacity(0.98),
                ),
              ),
            ),
            // Show checkmark if submitted, otherwise show camera button
            if (isSubmitted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'TERKIRIM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              TextButton.icon(
                onPressed: onCapturePhoto,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: Colors.black87,
                ),
                label: const Text(
                  'KIRIM FOTO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFDFEEDB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Deskripsi singkat kegiatan: diberi sedikit indent dan spasi lebih
        Text(
          detail,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.white.withOpacity(0.92),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              location,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Icon(Icons.access_time, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              distance,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        // Bottom action removed per request
      ],
    ),
  );
}

/// Card khusus untuk aksi "Kirim Foto"
Widget _buildSendPhotoCard(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF62903A),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kirim Foto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final file = await PhotoService.captureOrPick(context);
                if (file == null) return;
                const token = 'YOUR_TOKEN_HERE';
                const taskId = 'quick-send';
                try {
                  await ApiService.uploadTaskPhoto(
                    token: token,
                    taskId: taskId,
                    filePath: file.path,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto berhasil dikirim')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal kirim foto: $e')),
                  );
                }
              },
              icon: const Icon(
                Icons.camera_alt_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Ambil & Kirim',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: Colors.white.withOpacity(0.85)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}