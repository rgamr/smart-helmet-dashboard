import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  // API key is stored here — consider moving to Firebase Remote Config for production
  static const String _apiKey = '8d360a2b866ce2cc6a83b4ad1cbaff84';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Fallback coordinates (Cairo) if GPS unavailable
  static const double _defaultLat = 30.0444;
  static const double _defaultLon = 31.2357;

  Future<Position?> _getDeviceLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentWeather() async {
    try {
      double lat = _defaultLat;
      double lon = _defaultLon;

      final position = await _getDeviceLocation();
      if (position != null) {
        lat = position.latitude;
        lon = position.longitude;
      }

      final url = Uri.parse(
          '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double? getTemperature(Map<String, dynamic>? weatherData) {
    if (weatherData == null) return null;
    return weatherData['main']?['temp']?.toDouble();
  }

  String getWeatherDescription(Map<String, dynamic>? weatherData) {
    if (weatherData == null) return 'Unknown';
    return weatherData['weather']?[0]?['description'] ?? 'Unknown';
  }

  String? getCityName(Map<String, dynamic>? weatherData) {
    return weatherData?['name'] as String?;
  }

  String compareTemperatures({
    required double helmetTemp,
    required double? weatherTemp,
  }) {
    if (weatherTemp == null) {
      return 'Weather data unavailable';
    }

    double diff = helmetTemp - weatherTemp;

    if (diff > 15) {
      return '🔥 Critical: ${diff.toStringAsFixed(1)}°C above outside temp';
    } else if (diff > 10) {
      return '⚠️ Hot: ${diff.toStringAsFixed(1)}°C above outside temp';
    } else if (diff > 5) {
      return '✅ Warm: ${diff.toStringAsFixed(1)}°C above outside temp';
    } else {
      return '✅ Normal: ${diff.toStringAsFixed(1)}°C above outside temp';
    }
  }
}