class Helmet {
  final String id;
  final String status;
  final int? battery;
  final String? workerId;
  final String? workerName;
  final String? lastUpdate;
  final String? location;
  final double? helmetTemperature;
  final double? ambientTemperature;
  final bool? isWorn;
  final double? latitude;
  final double? longitude;

  Helmet({
    required this.id,
    required this.status,
    this.battery,
    this.workerId,
    this.workerName,
    this.lastUpdate,
    this.location,
    this.helmetTemperature,
    this.ambientTemperature,
    this.isWorn,
    this.latitude,
    this.longitude,
  });

  factory Helmet.fromJson(Map<String, dynamic> json) {
    return Helmet(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      battery: json['battery'],
      workerId: json['workerId'],
      workerName: json['workerName'],
      lastUpdate: json['lastUpdate'],
      location: json['location'],
      helmetTemperature: json['helmetTemperature']?.toDouble(),
      ambientTemperature: json['ambientTemperature']?.toDouble(),
      isWorn: json['isWorn'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}