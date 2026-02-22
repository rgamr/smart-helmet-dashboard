import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';

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

  Color _vitalColor(String type, dynamic value) {
    if (value == null || value == 0) return Colors.grey;

    if (type == 'heart') {
      int hr = value as int;
      if (hr > 120) return Colors.red;
      if (hr > 100) return Colors.orange;
      return Colors.green;
    } else if (type == 'oxygen') {
      int ox = value as int;
      if (ox < 90) return Colors.red;
      if (ox < 95) return Colors.orange;
      return Colors.green;
    } else if (type == 'temp') {
      double temp = value as double;
      if (temp > 38.5) return Colors.red;
      if (temp > 37.5) return Colors.orange;
      return Colors.green;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final worker = context.read<DashboardProvider>().selectedWorker;

    if (worker == null) {
      return Scaffold(
        body: Center(child: Text('worker_details.no_worker_selected'.tr())),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(worker.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
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
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status & Helmet Row
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'worker_details.status'.tr(),
                    value: worker.status,
                    color: _statusColor(worker.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'worker_details.helmet'.tr(),
                    value: worker.helmet.toLowerCase() == 'connected'
                        ? '${worker.helmetBattery ?? 0}%'
                        : worker.helmet,
                    color: _helmetColor(worker.helmet),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vital Signs Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'worker_details.vital_signs'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _VitalCard(
                          icon: Icons.favorite,
                          label: 'worker_details.heart_rate'.tr(),
                          value: worker.heartRate != null && worker.heartRate! > 0
                              ? '${worker.heartRate} bpm'
                              : 'common.na'.tr(),
                          color: _vitalColor('heart', worker.heartRate),
                        ),
                        _VitalCard(
                          icon: Icons.air,
                          label: 'worker_details.oxygen'.tr(),
                          value: worker.oxygenLevel != null && worker.oxygenLevel! > 0
                              ? '${worker.oxygenLevel}%'
                              : 'common.na'.tr(),
                          color: _vitalColor('oxygen', worker.oxygenLevel),
                        ),
                        _VitalCard(
                          icon: Icons.thermostat,
                          label: 'worker_details.body_temp'.tr(),
                          value: worker.bodyTemperature != null && worker.bodyTemperature! > 0
                              ? '${worker.bodyTemperature!.toStringAsFixed(1)}°C'
                              : 'common.na'.tr(),
                          color: _vitalColor('temp', worker.bodyTemperature),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Details Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow('worker_details.last_seen'.tr(), worker.lastSeen),
                    const Divider(),
                    _DetailRow(
                        'worker_details.location'.tr(),
                        worker.location ?? 'worker_details.unknown'.tr()),
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

  const _InfoCard({
    required this.label,
    required this.value,
    required this.color,
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
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _VitalCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}