import 'package:flutter/material.dart';
import '../models/helmet_model.dart';

class HelmetDetailsScreen extends StatelessWidget {
  final Helmet helmet;

  const HelmetDetailsScreen({super.key, required this.helmet});

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _batteryColor(int? battery) {
    if (battery == null) return Colors.grey;
    if (battery <= 20) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 600 ? 12.0 : 16.0;
    final iconSize = screenWidth < 600 ? 28.0 : 36.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Helmet Details")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Profile
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: iconSize,
                        backgroundColor: _statusColor(helmet.status).withOpacity(0.15),
                        child: Icon(Icons.engineering,
                            size: iconSize, color: _statusColor(helmet.status)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              helmet.id.isNotEmpty ? "Helmet ID: ${helmet.id}" : "Unknown ID",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text("Assigned to: ${helmet.workerName ?? 'Unassigned'}",
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
