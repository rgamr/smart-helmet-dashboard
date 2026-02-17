import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tasks = [
      {"title": "Inspect Helmet H-102", "status": "Pending"},
      {"title": "Review Incident I-004", "status": "In Progress"},
      {"title": "Battery Check - Zone A", "status": "Completed"},
      {"title": "Safety Drill Preparation", "status": "Pending"},
      {"title": "Update Worker Status Logs", "status": "Pending"},
      {"title": "Maintenance Report Submission", "status": "In Progress"},
      {"title": "Factory Zone C Inspection", "status": "Completed"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Tasks Today")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          Color statusColor;
          switch (task["status"]) {
            case "Completed":
              statusColor = Colors.green;
              break;
            case "In Progress":
              statusColor = Colors.orange;
              break;
            default:
              statusColor = Colors.red;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.task, color: theme.colorScheme.primary),
              title: Text(task["title"]!),
              trailing: Text(
                task["status"]!,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
