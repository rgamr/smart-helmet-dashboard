import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';

class WorkerDetailsScreen extends StatelessWidget {
  const WorkerDetailsScreen({super.key});

  Color _statusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'online': return Colors.green;
      case 'incident': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _helmetColor(String? h) =>
      h?.toLowerCase() == 'connected' ? Colors.green : Colors.orange;

  Color _vitalColor(String type, dynamic v) {
    if (v == null || v == 0) return Colors.grey;
    if (type == 'heart') { int h = v; return h > 120 ? Colors.red : h > 100 ? Colors.orange : Colors.green; }
    if (type == 'oxygen') { int o = v; return o < 90 ? Colors.red : o < 95 ? Colors.orange : Colors.green; }
    if (type == 'temp') { double t = v; return t > 38.5 ? Colors.red : t > 37.5 ? Colors.orange : Colors.green; }
    return Colors.grey;
  }

  Color _gasColor(String type, double? v) {
    if (v == null) return Colors.grey;
    if (type == 'co') return v > 35 ? Colors.red : v > 20 ? Colors.orange : Colors.green;
    if (type == 'co2') return v > 1000 ? Colors.red : v > 800 ? Colors.orange : Colors.green;
    if (type == 'o2') return v < 19.5 ? Colors.red : v < 20.5 ? Colors.orange : Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final worker = context.read<DashboardProvider>().selectedWorker;
    if (worker == null) {
      return Scaffold(body: Center(child: Text('worker_details.no_worker_selected'.tr())));
    }

    return Scaffold(
      appBar: AppBar(title: Text(worker.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Profile
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: _statusColor(worker.status).withOpacity(0.15),
                  child: Icon(Icons.person, color: _statusColor(worker.status), size: 36),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(worker.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(worker.id, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Status row
          Row(children: [
            Expanded(child: _InfoCard('worker_details.status'.tr(), worker.status, _statusColor(worker.status))),
            const SizedBox(width: 12),
            Expanded(child: _InfoCard('worker_details.helmet'.tr(),
              worker.helmet.toLowerCase() == 'connected' ? '${worker.helmetBattery ?? 0}%' : worker.helmet,
              _helmetColor(worker.helmet))),
            const SizedBox(width: 12),
            Expanded(child: _InfoCard('worker_details.helmet_worn'.tr(),
              worker.isHelmetWorn == null ? 'common.na'.tr() : worker.isHelmetWorn! ? '✅' : '⛑️ No',
              worker.isHelmetWorn == null ? Colors.grey : worker.isHelmetWorn! ? Colors.green : Colors.red)),
          ]),
          const SizedBox(height: 16),

          // Vital Signs
          _SensorCard(title: 'worker_details.vital_signs'.tr(), items: [
            _VitalItem(Icons.favorite, 'worker_details.heart_rate'.tr(),
              worker.heartRate != null && worker.heartRate! > 0 ? '${worker.heartRate} bpm' : 'common.na'.tr(),
              _vitalColor('heart', worker.heartRate)),
            _VitalItem(Icons.water_drop, 'worker_details.oxygen'.tr(),
              worker.oxygenLevel != null && worker.oxygenLevel! > 0 ? '${worker.oxygenLevel}%' : 'common.na'.tr(),
              _vitalColor('oxygen', worker.oxygenLevel)),
            _VitalItem(Icons.thermostat, 'worker_details.body_temp'.tr(),
              worker.bodyTemperature != null && worker.bodyTemperature! > 0 ? '${worker.bodyTemperature!.toStringAsFixed(1)}°C' : 'common.na'.tr(),
              _vitalColor('temp', worker.bodyTemperature)),
          ]),
          const SizedBox(height: 16),

          // Environmental
          _SensorCard(title: 'worker_details.environmental'.tr(), items: [
            _VitalItem(Icons.cloud, 'worker_details.co_level'.tr(),
              worker.coLevel != null ? '${worker.coLevel!.toStringAsFixed(1)} ppm' : 'common.na'.tr(),
              _gasColor('co', worker.coLevel)),
            _VitalItem(Icons.cloud_queue, 'worker_details.co2_level'.tr(),
              worker.co2Level != null ? '${worker.co2Level!.toStringAsFixed(0)} ppm' : 'common.na'.tr(),
              _gasColor('co2', worker.co2Level)),
            _VitalItem(Icons.air, 'worker_details.surrounding_o2'.tr(),
              worker.surroundingO2 != null ? '${worker.surroundingO2!.toStringAsFixed(1)}%' : 'common.na'.tr(),
              _gasColor('o2', worker.surroundingO2)),
          ]),
          const SizedBox(height: 16),

          // Safety Events
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('worker_details.safety_events'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _InfoCard('worker_details.fall_detected'.tr(),
                    worker.fallDetected == null ? 'common.na'.tr() : worker.fallDetected! ? '🆘 YES' : '✅ No',
                    worker.fallDetected == true ? Colors.red : Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _InfoCard('worker_details.impact_count'.tr(),
                    worker.impactCount != null ? '${worker.impactCount}' : 'common.na'.tr(),
                    (worker.impactCount ?? 0) > 0 ? Colors.orange : Colors.green)),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Details
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _DetailRow('worker_details.last_seen'.tr(), worker.lastSeen),
                const Divider(),
                _DetailRow('worker_details.location'.tr(), worker.location ?? 'worker_details.unknown'.tr()),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label; final String value; final Color color;
  const _InfoCard(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    ),
  );
}

class _VitalItem {
  final IconData icon; final String label; final String value; final Color color;
  _VitalItem(this.icon, this.label, this.value, this.color);
}

class _SensorCard extends StatelessWidget {
  final String title; final List<_VitalItem> items;
  const _SensorCard({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((i) => Column(children: [
            Icon(i.icon, color: i.color, size: 32),
            const SizedBox(height: 4),
            Text(i.value, style: TextStyle(color: i.color, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text(i.label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])).toList(),
        ),
      ]),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label; final String value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
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