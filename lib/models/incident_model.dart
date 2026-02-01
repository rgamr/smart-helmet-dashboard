class Incident {
  final String title;
  final String workerName;
  final String status; // Open, In Progress, Resolved
  final String time;

  Incident({
    required this.title,
    required this.workerName,
    required this.status,
    required this.time,
  });
}
