class Worker {
  final String name;
  final String id;
  final String status;
  final String helmet;
  final String lastSeen;
  final int? helmetBattery;
  final String? location;
  final int? heartRate;
  final int? oxygenLevel;
  final double? bodyTemperature;

  Worker({
    required this.name,
    required this.id,
    required this.status,
    required this.helmet,
    required this.lastSeen,
    this.helmetBattery,
    this.location,
    this.heartRate,
    this.oxygenLevel,
    this.bodyTemperature,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      helmet: json['helmet'] ?? '',
      lastSeen: json['lastSeen'] ?? '',
      helmetBattery: json['helmetBattery'],
      location: json['location'],
      heartRate: json['heartRate'],
      oxygenLevel: json['oxygenLevel'],
      bodyTemperature: json['bodyTemperature']?.toDouble(),
    );
  }
}