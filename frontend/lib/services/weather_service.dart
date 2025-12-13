// services/weather_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String description;
  final IconData icon;
  final String location;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.icon,
    required this.location,
    required this.humidity,
    required this.windSpeed,
  });
}

class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final IconData icon;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.icon,
  });
}

class WeatherService {
  // OpenWeatherMap API Key - Ganti dengan API key Anda sendiri
  // Daftar gratis di: https://openweathermap.org/api
  static const String _apiKey = '4d8fb5b93d4af21d66a2948710284366'; // Demo key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Koordinat tetap untuk Desa Sengka, Kec. Bontonompo, Kab. Gowa, Sulawesi Selatan
  static const double _desaSengkaLat = -5.3833;
  static const double _desaSengkaLon = 119.4333;
  static const String _locationName = 'Desa Sengka';

  // Cache untuk menghindari terlalu banyak API calls
  static WeatherData? _cachedCurrentWeather;
  static List<DailyForecast>? _cachedForecast;
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidity = Duration(minutes: 30);

  /// Get current location coordinates
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Fetch current weather data
  static Future<WeatherData?> getCurrentWeather({
    double? lat,
    double? lon,
  }) async {
    try {
      // Check cache first
      if (_cachedCurrentWeather != null && _lastFetchTime != null) {
        if (DateTime.now().difference(_lastFetchTime!) < _cacheValidity) {
          return _cachedCurrentWeather;
        }
      }

      // Selalu gunakan koordinat Desa Sengka
      lat = _desaSengkaLat;
      lon = _desaSengkaLon;

      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _cachedCurrentWeather = WeatherData(
          temperature: (data['main']['temp'] as num).toDouble(),
          condition: _translateCondition(data['weather'][0]['main']),
          description: data['weather'][0]['description'] ?? '',
          icon: _getWeatherIcon(data['weather'][0]['main']),
          location: _locationName, // Selalu tampilkan Desa Sengka
          humidity: data['main']['humidity'] ?? 0,
          windSpeed: (data['wind']['speed'] as num?)?.toDouble() ?? 0.0,
        );
        _lastFetchTime = DateTime.now();
        
        return _cachedCurrentWeather;
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    }
    return null;
  }

  /// Fetch 7-day forecast
  static Future<List<DailyForecast>?> get7DayForecast({
    double? lat,
    double? lon,
  }) async {
    try {
      // Check cache first
      if (_cachedForecast != null && _lastFetchTime != null) {
        if (DateTime.now().difference(_lastFetchTime!) < _cacheValidity) {
          return _cachedForecast;
        }
      }

      // Selalu gunakan koordinat Desa Sengka
      lat = _desaSengkaLat;
      lon = _desaSengkaLon;

      // Using 5-day/3-hour forecast API (free tier)
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];
        
        // Group by day and get daily summary
        Map<String, List<dynamic>> dailyData = {};
        for (var item in list) {
          final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dayKey = '${date.year}-${date.month}-${date.day}';
          dailyData.putIfAbsent(dayKey, () => []);
          dailyData[dayKey]!.add(item);
        }

        List<DailyForecast> forecasts = [];
        for (var entry in dailyData.entries.take(7)) {
          final dayItems = entry.value;
          double maxTemp = -100;
          double minTemp = 100;
          String mainCondition = 'Clear';
          
          for (var item in dayItems) {
            final temp = (item['main']['temp'] as num).toDouble();
            if (temp > maxTemp) maxTemp = temp;
            if (temp < minTemp) minTemp = temp;
            mainCondition = item['weather'][0]['main'];
          }
          
          final dateStr = entry.key.split('-');
          final date = DateTime(
            int.parse(dateStr[0]),
            int.parse(dateStr[1]),
            int.parse(dateStr[2]),
          );
          
          forecasts.add(DailyForecast(
            date: date,
            tempMax: maxTemp,
            tempMin: minTemp,
            condition: _translateCondition(mainCondition),
            icon: _getWeatherIcon(mainCondition),
          ));
        }

        _cachedForecast = forecasts;
        return forecasts;
      }
    } catch (e) {
      debugPrint('Error fetching forecast: $e');
    }
    return null;
  }

  /// Translate weather condition to Indonesian
  static String _translateCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'Cerah';
      case 'clouds':
        return 'Berawan';
      case 'few clouds':
      case 'scattered clouds':
        return 'Berawan Tipis';
      case 'broken clouds':
      case 'overcast clouds':
        return 'Berawan Tebal';
      case 'rain':
        return 'Hujan';
      case 'light rain':
        return 'Hujan Ringan';
      case 'moderate rain':
        return 'Hujan Sedang';
      case 'heavy rain':
        return 'Hujan Lebat';
      case 'drizzle':
        return 'Gerimis';
      case 'thunderstorm':
        return 'Badai Petir';
      case 'snow':
        return 'Salju';
      case 'mist':
        return 'Berkabut';
      case 'fog':
        return 'Kabut Tebal';
      case 'haze':
        return 'Kabut Asap';
      case 'smoke':
        return 'Berasap';
      case 'dust':
        return 'Berdebu';
      default:
        return 'Berawan';
    }
  }

  /// Get appropriate weather icon based on condition
  /// Icons yang lebih jelas dan distinct
  static IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny; // Matahari penuh
      case 'clouds':
      case 'few clouds':
      case 'scattered clouds':
        return Icons.cloud_queue; // Awan dengan outline
      case 'broken clouds':
      case 'overcast clouds':
        return Icons.cloud; // Awan penuh/mendung
      case 'rain':
      case 'moderate rain':
      case 'heavy rain':
        return Icons.water_drop; // Tetesan air untuk hujan
      case 'light rain':
      case 'drizzle':
        return Icons.grain; // Titik-titik untuk gerimis
      case 'thunderstorm':
        return Icons.flash_on; // Petir
      case 'snow':
        return Icons.ac_unit; // Salju/kristal es
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.dehaze; // Garis-garis untuk kabut
      case 'smoke':
      case 'dust':
        return Icons.blur_on; // Blur untuk asap/debu
      default:
        return Icons.cloud;
    }
  }

  /// Get weather icon with color based on condition
  static Color getWeatherIconColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'cerah':
        return const Color(0xFFFFD700); // Gold/Yellow for sunny
      case 'clouds':
      case 'berawan':
      case 'berawan tipis':
      case 'berawan tebal':
        return const Color(0xFFE0E0E0); // Light gray for cloudy
      case 'rain':
      case 'hujan':
      case 'hujan ringan':
      case 'hujan sedang':
      case 'hujan lebat':
      case 'drizzle':
      case 'gerimis':
        return const Color(0xFF64B5F6); // Blue for rain
      case 'thunderstorm':
      case 'badai petir':
        return const Color(0xFFFFEB3B); // Yellow for lightning
      case 'snow':
      case 'salju':
        return const Color(0xFFE3F2FD); // Light blue for snow
      case 'mist':
      case 'fog':
      case 'haze':
      case 'berkabut':
      case 'kabut tebal':
      case 'kabut asap':
        return const Color(0xFFBDBDBD); // Gray for mist
      default:
        return Colors.white;
    }
  }

  /// Clear cache (useful when location changes)
  static void clearCache() {
    _cachedCurrentWeather = null;
    _cachedForecast = null;
    _lastFetchTime = null;
  }
}
