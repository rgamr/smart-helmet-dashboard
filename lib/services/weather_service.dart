import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '8d360a2b866ce2cc6a83b4ad1cbaff84';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Cairo coordinates as default
  static const double _defaultLat = 30.0444;
  static const double _defaultLon = 31.2357;

  Future<Map<String, dynamic>?> getCurrentWeather() async {
    try {
      final url = Uri.parse(
          '$_baseUrl?lat=$_defaultLat&lon=$_defaultLon&appid=$_apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Weather API error: $e');
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