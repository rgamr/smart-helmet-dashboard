class Incident {
  final String title;
  final String workerName;
  final String status;
  final String time;

  Incident({
    required this.title,
    required this.workerName,
    required this.status,
    required this.time,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      title: json['title'],
      workerName: json['workerName'],
      status: json['status'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'workerName': workerName,
    'status': status,
    'time': time,
  };
}
