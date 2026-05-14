class Incident {
  final String id;
  final String title;
  final String? workerId;
  final String workerName;
  final String status;
  final String time;

  Incident({
    required this.id,
    required this.title,
    this.workerId,
    required this.workerName,
    required this.status,
    required this.time,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      workerId: json['workerId'],
      workerName: json['workerName'] ?? '',
      status: json['status'] ?? '',
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'workerId': workerId,
    'workerName': workerName,
    'status': status,
    'time': time,
  };

  Incident copyWith({String? status}) => Incident(
    id: id,
    title: title,
    workerId: workerId,
    workerName: workerName,
    status: status ?? this.status,
    time: time,
  );
}
