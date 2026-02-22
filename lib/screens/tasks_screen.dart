import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tasks = [
      {"titleKey": "tasks.inspect_helmet", "statusKey": "tasks.status_pending"},
      {"titleKey": "tasks.review_incident", "statusKey": "tasks.status_in_progress"},
      {"titleKey": "tasks.battery_check", "statusKey": "tasks.status_completed"},
      {"titleKey": "tasks.safety_drill", "statusKey": "tasks.status_pending"},
      {"titleKey": "tasks.update_worker_logs", "statusKey": "tasks.status_pending"},
      {"titleKey": "tasks.maintenance_report", "statusKey": "tasks.status_in_progress"},
      {"titleKey": "tasks.factory_inspection", "statusKey": "tasks.status_completed"},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('tasks.title'.tr())),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final statusKey = task["statusKey"]!;

          Color statusColor;
          if (statusKey == "tasks.status_completed") {
            statusColor = Colors.green;
          } else if (statusKey == "tasks.status_in_progress") {
            statusColor = Colors.orange;
          } else {
            statusColor = Colors.red;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.task, color: theme.colorScheme.primary),
              title: Text(task["titleKey"]!.tr()),
              trailing: Text(
                statusKey.tr(),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
