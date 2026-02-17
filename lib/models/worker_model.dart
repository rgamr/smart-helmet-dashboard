class Worker {
  final String name;
  final String id;
  final String status;
  final String helmet;
  final String lastSeen;
  final int? helmetBattery;
  final String? location;

  Worker({
    required this.name,
    required this.id,
    required this.status,
    required this.helmet,
    required this.lastSeen,
    this.helmetBattery,
    this.location,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'status': status,
    'helmet': helmet,
    'lastSeen': lastSeen,
    'helmetBattery': helmetBattery,
    'location': location,
  };
}
