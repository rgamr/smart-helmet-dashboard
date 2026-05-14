class SensorReading {
  final int timestamp;
  final int? heartRate;
  final int? oxygenLevel;
  final double? bodyTemperature;
  final double? coLevel;
  final double? co2Level;
  final double? surroundingO2;

  SensorReading({
    required this.timestamp,
    this.heartRate,
    this.oxygenLevel,
    this.bodyTemperature,
    this.coLevel,
    this.co2Level,
    this.surroundingO2,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      timestamp: json['timestamp'] ?? 0,
      heartRate: json['heartRate'],
      oxygenLevel: json['oxygenLevel'],
      bodyTemperature: json['bodyTemperature']?.toDouble(),
      coLevel: json['coLevel']?.toDouble(),
      co2Level: json['co2Level']?.toDouble(),
      surroundingO2: json['surroundingO2']?.toDouble(),
    );
  }
}
