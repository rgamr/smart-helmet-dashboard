import 'package:flutter/material.dart';
import '../models/helmet_model.dart';

class HelmetDetailsScreen extends StatelessWidget {
  final Helmet helmet;

  const HelmetDetailsScreen({super.key, required this.helmet});

  Color _statusColor(String? status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmall = screenWidth < 600;
    final padding = isSmall ? 12.0 : 16.0;
    final iconSize = isSmall ? 28.0 : 36.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Helmet Details"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
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
                        backgroundColor:
                        _statusColor(helmet.status)
                            .withOpacity(0.15),
                        child: Icon(
                          Icons.engineering,
                          size: iconSize,
                          color: _statusColor(helmet.status),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              helmet.id.isNotEmpty
                                  ? "Helmet ID: ${helmet.id}"
                                  : "Helmet ID: Unknown",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Assigned to: ${helmet.workerName ?? 'Unassigned'}",
                              style: const TextStyle(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoCard(
                    label: "Status",
                    value: helmet.status,
                    color: _statusColor(helmet.status),
                  ),
                  _InfoCard(
                    label: "Battery",
                    value: "${helmet.battery ?? 0}%",
                    color: Colors.blue,
                  ),
                  _InfoCard(
                    label: "Last Sync",
                    value: helmet.lastUpdate.isNotEmpty
                        ? helmet.lastUpdate
                        : '--',
                    color: Colors.grey.shade700,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: const Column(
                    children: [
                      _DetailRow("Location", "Factory Zone A"),
                      Divider(),
                      _DetailRow("Temperature", "36°C"),
                      Divider(),
                      _DetailRow("Pressure", "1.2 bar"),
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

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 6),
              Text(
                value.isNotEmpty ? value : 'N/A',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
