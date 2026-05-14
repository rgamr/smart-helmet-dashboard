class Task {
  final String id;
  final String title;
  final String status; // 'pending', 'in_progress', 'completed'
  final String assignedTo;
  final String priority; // 'low', 'medium', 'high'
  final String createdAt;
  final String? dueDate;
  final String? description;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.assignedTo,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.description,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 'pending',
      assignedTo: json['assignedTo'] ?? '',
      priority: json['priority'] ?? 'medium',
      createdAt: json['createdAt'] ?? '',
      dueDate: json['dueDate'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'status': status,
        'assignedTo': assignedTo,
        'priority': priority,
        'createdAt': createdAt,
        if (dueDate != null) 'dueDate': dueDate,
        if (description != null) 'description': description,
      };

  Task copyWith({
    String? title,
    String? status,
    String? assignedTo,
    String? priority,
    String? dueDate,
    String? description,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
    );
  }
}
