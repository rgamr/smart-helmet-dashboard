import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../models/helmet_model.dart';
import 'incidents_screen.dart';
import 'helmet_details_screen.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final Worker worker;

  const WorkerDetailsScreen({super.key, required this.worker});

  // ================= Validation Helpers =================

  String _safeText(String? value, {String fallback = 'Unknown'}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'incident':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _helmetColor(String? helmet) {
    if (helmet?.toLowerCase() == 'connected') return Colors.green;
    return Colors.orange;
  }

  bool get _hasHelmet => worker.helmet.toLowerCase() == 'connected';

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final padding = width < 500 ? 12.0 : 16.0;
    final avatarRadius = width < 500 ? 30.0 : 36.0;
    final titleSize = width < 500 ? 16.0 : 18.0;
    final valueSize = width < 500 ? 14.0 : 16.0;

    final name = _safeText(worker.name, fallback: 'Unknown Worker');
    final id = _safeText(worker.id);
    final status = _safeText(worker.status);
    final helmet = _safeText(worker.helmet, fallback: 'Not Connected');
    final lastSeen = _safeText(worker.lastSeen);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // ================= Profile =================
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
                        radius: avatarRadius,
                        backgroundColor:
                        _statusColor(status).withOpacity(0.15),
                        child: Icon(
                          Icons.person,
                          size: avatarRadius,
                          color: _statusColor(status),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              id,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= Status Cards =================
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: "Status",
                      value: status,
                      color: _statusColor(status),
                      valueSize: valueSize,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (_hasHelmet) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HelmetDetailsScreen(
                                helmet: Helmet(
                                  id: 'H-204',
                                  status: helmet,
                                  battery: 82,
                                  workerName: name,
                                  lastUpdate: '2 min ago',
                                ),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('No helmet connected to this worker'),
                            ),
                          );
                        }
                      },
                      child: _InfoCard(
                        label: "Helmet",
                        value: helmet,
                        color: _helmetColor(helmet),
                        valueSize: valueSize,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ================= Extra Details =================
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      _DetailRow("Last Seen", lastSeen),
                      const Divider(),
                      const _DetailRow("Battery Level", "82%"),
                      const Divider(),
                      const _DetailRow("Location", "Factory Zone A"),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ================= Actions =================
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
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
                            builder: (_) =>
                                IncidentsScreen(workerName: name),
                          ),
                        );
                      },
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
  final double valueSize;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.color,
    required this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
