import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/helmet_model.dart';
import 'helmet_details_screen.dart';

class ActiveHelmetsScreen extends StatelessWidget {
  const ActiveHelmetsScreen({super.key});

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
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Helmets')),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          if (dashboard.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (dashboard.hasError) {
            return const Center(child: Text('Failed to load helmets'));
          }

          final helmets = dashboard.helmets;

          if (helmets.isEmpty) {
            return const Center(child: Text('No helmets available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: helmets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final helmet = helmets[index];

              return HelmetCard(
                helmet: helmet,
                statusColor: _statusColor(helmet.status),
                batteryColor: _batteryColor(helmet.battery),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HelmetDetailsScreen(helmet: helmet),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class HelmetCard extends StatelessWidget {
  final Helmet helmet;
  final Color statusColor;
  final Color batteryColor;
  final VoidCallback onTap;

  const HelmetCard({
    super.key,
    required this.helmet,
    required this.statusColor,
    required this.batteryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final workerName =
    helmet.workerName?.isNotEmpty == true ? helmet.workerName! : 'Unassigned';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.15),
                child: Icon(Icons.engineering, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      helmet.id.isNotEmpty ? helmet.id : 'Unknown ID',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(workerName, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Badge(label: helmet.status, color: statusColor),
                        _Badge(
                          label: 'Battery ${helmet.battery ?? 0}%',
                          color: batteryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                helmet.lastUpdate?.isNotEmpty == true ? helmet.lastUpdate! : '--',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.isNotEmpty ? label : 'N/A',
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
