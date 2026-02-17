class Helmet {
  final String id;
  final String status;
  final int? battery;
  final String? workerName;
  final String? lastUpdate;
  final String? location;

  Helmet({
    required this.id,
    required this.status,
    this.battery,
    this.workerName,
    this.lastUpdate,
    this.location,
  });

  factory Helmet.fromJson(Map<String, dynamic> json) {
    return Helmet(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      battery: json['battery'],
      workerName: json['workerName'],
      lastUpdate: json['lastUpdate'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'battery': battery,
    'workerName': workerName,
    'lastUpdate': lastUpdate,
    'location': location,
  };
}
