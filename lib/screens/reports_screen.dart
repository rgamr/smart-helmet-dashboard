import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {"title": "Weekly Safety Report", "date": "12 Feb 2026"},
      {"title": "Helmet Performance Analysis", "date": "10 Feb 2026"},
      {"title": "Incident Overview", "date": "08 Feb 2026"},
      {"title": "Monthly Compliance Report", "date": "01 Feb 2026"},
      {"title": "Battery Usage Summary", "date": "28 Jan 2026"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.orange),
              title: Text(report["title"]!),
              subtitle: Text("Generated on ${report["date"]}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}

