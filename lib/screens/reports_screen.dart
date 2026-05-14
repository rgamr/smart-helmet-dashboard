import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';
import '../providers/user_provider.dart';
import '../models/incident_model.dart';
import '../services/pdf_service.dart';
import 'all_incidents_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _exportingPdf = false;

  Future<void> _exportPdf(BuildContext context) async {
    final dashboard = context.read<DashboardProvider>();
    setState(() => _exportingPdf = true);
    try {
      await PdfService().exportReport(
        incidents: dashboard.incidents,
        workers: dashboard.workers,
        helmets: dashboard.helmets,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  Map<String, int> _getStats(List<Incident> incidents) => {
    'total': incidents.length,
    'open': incidents.where((i) => i.status.toLowerCase() == 'open').length,
    'inProgress': incidents.where((i) => i.status.toLowerCase() == 'in progress').length,
    'resolved': incidents.where((i) => i.status.toLowerCase() == 'resolved').length,
  };

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.red;
      case 'in progress': return Colors.orange;
      case 'resolved': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Icons.error_outline;
      case 'in progress': return Icons.pending_outlined;
      case 'resolved': return Icons.check_circle_outline;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final isAdmin = context.watch<UserProvider>().isAdmin;
    final incidents = provider.incidents;
    final workers = provider.workers;
    final helmets = provider.helmets;
    final stats = _getStats(incidents);
    final activeHelmets = helmets.where((h) => h.status.toLowerCase() == 'active').length;
    final lowBattery = helmets.where((h) => h.battery != null && h.battery! < 20).length;
    final onlineWorkers = workers.where((w) => w.status.toLowerCase() == 'online').length;
    final workerStats = <String, int>{};
    for (final i in incidents) {
      workerStats[i.workerName] = (workerStats[i.workerName] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('reports.title'.tr()),
        actions: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _exportingPdf
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                  : IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      tooltip: 'reports.export_pdf'.tr(),
                      onPressed: () => _exportPdf(context),
                    ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.hasError
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text('common.error'.tr(), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(onPressed: provider.retry,
                    icon: const Icon(Icons.refresh), label: Text('common.retry'.tr())),
                ]))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('reports.safety_overview'.tr(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _QuickStat('reports.workers'.tr(), '$onlineWorkers/${workers.length}', 'reports.online'.tr(), Icons.people, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickStat('reports.helmets'.tr(), '$activeHelmets/${helmets.length}', 'reports.active'.tr(), Icons.engineering, Colors.green)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _QuickStat('reports.incidents'.tr(), stats['total'].toString(), 'reports.total'.tr(), Icons.warning, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickStat('reports.low_battery'.tr(), lowBattery.toString(), 'reports.helmets_label'.tr(), Icons.battery_alert, Colors.red)),
                    ]),
                    const SizedBox(height: 24),

                    Text('reports.incident_breakdown'.tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _StatCard('reports.open'.tr(), stats['open']!, Colors.red, Icons.error_outline)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard('reports.in_progress'.tr(), stats['inProgress']!, Colors.orange, Icons.pending_outlined)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard('reports.resolved'.tr(), stats['resolved']!, Colors.green, Icons.check_circle_outline)),
                    ]),
                    const SizedBox(height: 24),

                    if (workerStats.isNotEmpty) ...[
                      Text('reports.incidents_by_worker'.tr(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: workerStats.entries.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Row(children: [
                                const Icon(Icons.person, size: 20, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(e.key),
                              ]),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  'reports.incidents_count'.tr(namedArgs: {'count': e.value.toString()}),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                              ),
                            ]),
                          )).toList()),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (incidents.isNotEmpty) ...[
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('reports.recent_incidents'.tr(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const AllIncidentsScreen()));
                        }, child: Text('reports.view_all'.tr())),
                      ]),
                      const SizedBox(height: 12),
                      ...incidents.take(5).map((inc) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            CircleAvatar(
                              backgroundColor: _statusColor(inc.status).withOpacity(0.1),
                              child: Icon(_statusIcon(inc.status), color: _statusColor(inc.status), size: 20)),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(inc.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(inc.workerName, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(inc.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _statusColor(inc.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _statusColor(inc.status))),
                              child: Text(inc.status,
                                style: TextStyle(color: _statusColor(inc.status), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ]),
                        ),
                      )),
                    ] else
                      Center(child: Column(children: [
                        const SizedBox(height: 24),
                        const Icon(Icons.check_circle, size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        Text('reports.no_incidents_reported'.tr(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 8),
                        Text('reports.all_workers_safe'.tr(), style: const TextStyle(color: Colors.grey)),
                      ])),
                  ]),
                ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String title, value, subtitle; final IconData icon; final Color color;
  const _QuickStat(this.title, this.value, this.subtitle, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ])),
  );
}

class _StatCard extends StatelessWidget {
  final String title; final int count; final Color color; final IconData icon;
  const _StatCard(this.title, this.count, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Icon(icon, color: color, size: 32),
      const SizedBox(height: 8),
      Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
    ])),
  );
}