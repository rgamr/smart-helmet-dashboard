class Worker {
  final String name;
  final String id;
  final String status; // Online, Offline, Incident
  final String helmet; // Connected, Disconnected
  final String lastSeen;

  Worker({
    required this.name,
    required this.id,
    required this.status,
    required this.helmet,
    required this.lastSeen,
  });
}
