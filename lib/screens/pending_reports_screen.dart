import 'package:flutter/material.dart';

class PendingReportsScreen extends StatelessWidget {
  const PendingReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingReports = [
      {"title": "Incident Follow-up Report", "priority": "High"},
      {"title": "Helmet H-121 Failure Analysis", "priority": "Medium"},
      {"title": "Unauthorized Zone Entry Report", "priority": "High"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Pending Reports")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingReports.length,
        itemBuilder: (context, index) {
          final report = pendingReports[index];

          Color priorityColor =
          report["priority"] == "High" ? Colors.red : Colors.orange;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: Text(report["title"]!),
              trailing: Text(
                report["priority"]!,
                style: TextStyle(
                    color: priorityColor, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
