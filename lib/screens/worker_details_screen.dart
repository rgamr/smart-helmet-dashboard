import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/worker_model.dart';

class WorkerDetailsScreen extends StatelessWidget {
  const WorkerDetailsScreen({super.key});

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
    return helmet?.toLowerCase() == 'connected' ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final worker = context.read<DashboardProvider>().selectedWorker;

    if (worker == null) {
      return const Scaffold(
        body: Center(child: Text('No worker selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(worker.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                      _statusColor(worker.status).withOpacity(0.15),
                      child: Icon(Icons.person,
                          color: _statusColor(worker.status), size: 36),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(worker.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(worker.id,
                            style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Status',
                    value: worker.status,
                    color: _statusColor(worker.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Helmet',
                    value: worker.helmet.toLowerCase() == 'connected'
                        ? 'Helmet ${worker.helmetBattery ?? 0}%'
                        : 'Helmet ${worker.helmet}',
                    color: _helmetColor(worker.helmet),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow('Last Seen', worker.lastSeen),
                    const Divider(),
                    _DetailRow('Battery',
                        worker.helmetBattery != null
                            ? '${worker.helmetBattery}%'
                            : 'Unknown'),
                    const Divider(),
                    _DetailRow(
                        'Location',
                        worker.location != null ? worker.location! : 'Unknown'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoCard(
      {super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
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
        children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value)],
      ),
    );
  }
}
