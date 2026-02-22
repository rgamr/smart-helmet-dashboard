import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PendingReportsScreen extends StatelessWidget {
  const PendingReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingReports = [
      {"titleKey": "pending_reports.incident_followup", "priorityKey": "pending_reports.priority_high"},
      {"titleKey": "pending_reports.helmet_failure", "priorityKey": "pending_reports.priority_medium"},
      {"titleKey": "pending_reports.unauthorized_zone", "priorityKey": "pending_reports.priority_high"},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('pending_reports.title'.tr())),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingReports.length,
        itemBuilder: (context, index) {
          final report = pendingReports[index];
          final priorityKey = report["priorityKey"]!;

          Color priorityColor =
          priorityKey == "pending_reports.priority_high" ? Colors.red : Colors.orange;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: Text(report["titleKey"]!.tr()),
              trailing: Text(
                priorityKey.tr(),
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
