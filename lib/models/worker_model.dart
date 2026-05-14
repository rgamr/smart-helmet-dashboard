class Worker {
  final String name;
  final String id;
  final String status;
  final String? helmetId;
  final String helmet;
  final String lastSeen;
  final int? helmetBattery;
  final String? location;
  // Vitals
  final int? heartRate;
  final int? oxygenLevel;
  final double? bodyTemperature;
  // Environmental sensors
  final double? coLevel;
  final double? co2Level;
  final double? surroundingO2;
  // Safety events
  final bool? fallDetected;
  final int? impactCount;
  final bool? isHelmetWorn;

  Worker({
    required this.name,
    required this.id,
    required this.status,
    this.helmetId,
    required this.helmet,
    required this.lastSeen,
    this.helmetBattery,
    this.location,
    this.heartRate,
    this.oxygenLevel,
    this.bodyTemperature,
    this.coLevel,
    this.co2Level,
    this.surroundingO2,
    this.fallDetected,
    this.impactCount,
    this.isHelmetWorn,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      helmetId: json['helmetId'],
      helmet: json['helmet'] ?? '',
      lastSeen: json['lastSeen'] ?? '',
      helmetBattery: json['helmetBattery'],
      location: json['location'],
      heartRate: json['heartRate'],
      oxygenLevel: json['oxygenLevel'],
      bodyTemperature: json['bodyTemperature']?.toDouble(),
      coLevel: json['coLevel']?.toDouble(),
      co2Level: json['co2Level']?.toDouble(),
      surroundingO2: json['surroundingO2']?.toDouble(),
      fallDetected: json['fallDetected'],
      impactCount: json['impactCount'],
      isHelmetWorn: json['isHelmetWorn'],
    );
  }
}