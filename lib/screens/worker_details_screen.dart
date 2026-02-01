import 'package:flutter/material.dart';
import 'package:smart_helmet_app/models/helmet_model.dart';
import '../models/worker_model.dart';
import 'incidents_screen.dart';
import 'helmet_details_screen.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final Worker worker;

  const WorkerDetailsScreen({super.key, required this.worker});

  // ===== Helpers =====
  Color _statusColor(String status) {
    switch (status) {
      case 'Online':
        return Colors.green;
      case 'Incident':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _helmetColor(String helmet) {
    return helmet == 'Connected' ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(worker.name),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ===== Profile =====
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: _statusColor(worker.status).withOpacity(0.15),
                        child: Icon(Icons.person, size: 36, color: _statusColor(worker.status)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(worker.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(worker.id,
                                style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== Status Cards =====
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: "Status",
                      value: worker.status,
                      color: _statusColor(worker.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (worker.helmet == 'Connected') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HelmetDetailsScreen(
                                helmet: Helmet (
                                  id: 'H-204',
                                  status: worker.helmet,
                                  battery: 82 ,
                                  workerName: worker.name,
                                  lastUpdate: '2 min ago',
                                ),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No helmet connected to this worker'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: _InfoCard(
                        label: "Helmet",
                        value: worker.helmet,
                        color: _helmetColor(worker.helmet),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ===== Extra Details =====
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow("Last Seen", worker.lastSeen),
                      const Divider(),
                      const _DetailRow("Battery Level", "82%"), // replace with dynamic later
                      const Divider(),
                      const _DetailRow("Location", "Factory Zone A"),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ===== Actions =====
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      icon: const Icon(Icons.call),
                      label: const Text("Call"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IncidentsScreen(workerName: worker.name),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.warning),
                      label: const Text("View Incidents"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Info Card =================
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Detail Row =================
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
