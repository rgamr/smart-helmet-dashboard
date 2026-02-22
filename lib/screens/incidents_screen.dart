import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';
import '../models/incident_model.dart';

class IncidentsScreen extends StatelessWidget {
  final String? workerName;

  const IncidentsScreen({super.key, this.workerName});

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.red;
      case 'In Progress':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterKeys = ['All', 'Open', 'In Progress', 'Resolved'];
    final filterLabels = {
      'All': 'incidents.filter_all'.tr(),
      'Open': 'incidents.filter_open'.tr(),
      'In Progress': 'incidents.filter_in_progress'.tr(),
      'Resolved': 'incidents.filter_resolved'.tr(),
    };

    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        final allIncidents = dashboard.incidents;
        final filtered = allIncidents.where((inc) {
          final matchesWorker =
              workerName == null || inc.workerName == workerName;
          final matchesFilter =
              dashboard.selectedIncidentFilter == 'All' ||
                  inc.status == dashboard.selectedIncidentFilter;
          return matchesWorker && matchesFilter;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(workerName != null
                ? 'incidents.title_for_worker'.tr(namedArgs: {'name': workerName!})
                : 'incidents.title'.tr()),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Filters
                Wrap(
                  spacing: 8,
                  children: filterKeys
                      .map((key) => ChoiceChip(
                    label: Text(filterLabels[key]!),
                    selected:
                    dashboard.selectedIncidentFilter == key,
                    onSelected: (_) =>
                        dashboard.setIncidentFilter(key),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: dashboard.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : dashboard.hasError
                      ? Center(child: Text('incidents.failed_to_load'.tr()))
                      : filtered.isEmpty
                      ? Center(child: Text('incidents.no_incidents'.tr()))
                      : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final incident = filtered[index];
                      return _IncidentCard(
                        incident: incident,
                        statusColor:
                        _statusColor(incident.status),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;
  final Color statusColor;

  const _IncidentCard({required this.incident, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(incident.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
                'incidents.worker_label'.tr(namedArgs: {'name': incident.workerName}),
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusBadge(label: incident.status, color: statusColor),
                Text(incident.time,
                    style: const TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
