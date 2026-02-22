class Helmet {
  final String id;
  final String status;
  final int? battery;
  final String? workerName;
  final String? lastUpdate;
  final String? location;
  final double? helmetTemperature;
  final double? ambientTemperature;

  Helmet({
    required this.id,
    required this.status,
    this.battery,
    this.workerName,
    this.lastUpdate,
    this.location,
    this.helmetTemperature,
    this.ambientTemperature,
  });

  factory Helmet.fromJson(Map<String, dynamic> json) {
    return Helmet(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      battery: json['battery'],
      workerName: json['workerName'],
      lastUpdate: json['lastUpdate'],
      location: json['location'],
      helmetTemperature: json['helmetTemperature']?.toDouble(),
      ambientTemperature: json['ambientTemperature']?.toDouble(),
    );
  }
}