import 'package:flutter/material.dart';
import '../models/incident_model.dart';

class IncidentsScreen extends StatefulWidget {
  final String? workerName; // optional filter

  const IncidentsScreen({super.key, this.workerName});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  String selectedFilter = 'All';

  final List<Incident> incidents = [
    Incident(
      title: 'Helmet disconnect',
      workerName: 'Ahmed Raafat',
      status: 'Open',
      time: 'Just now',
    ),
    Incident(
      title: 'Worker fatigue detected',
      workerName: 'Raghad Amr',
      status: 'Resolved',
      time: '10 min ago',
    ),
    Incident(
      title: 'Helmet battery low',
      workerName: 'Ahmed Eslam',
      status: 'Open',
      time: '1 hr ago',
    ),
    Incident(
      title: 'Unauthorized zone entry',
      workerName: 'Hesham Abaza',
      status: 'In Progress',
      time: '5 min ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredIncidents = incidents.where((incident) {
      final matchesWorker =
          widget.workerName == null ||
              incident.workerName == widget.workerName;

      final matchesStatus =
          selectedFilter == 'All' ||
              incident.status == selectedFilter;

      return matchesWorker && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workerName != null
              ? "${widget.workerName} - Incidents"
              : "Incidents",
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters
            Wrap(
              spacing: 8,
              children: ['All', 'Open', 'In Progress', 'Resolved']
                  .map(
                    (filter) => ChoiceChip(
                  label: Text(filter),
                  selected: selectedFilter == filter,
                  onSelected: (_) {
                    setState(() => selectedFilter = filter);
                  },
                ),
              )
                  .toList(),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: filteredIncidents.isEmpty
                  ? Center(
                child: Text(
                  "No incidents found",
                  style: theme.textTheme.bodyMedium,
                ),
              )
                  : ListView.separated(
                itemCount: filteredIncidents.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _IncidentCard(
                    incident: filteredIncidents[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;

  const _IncidentCard({required this.incident});

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
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              "Worker: ${incident.workerName}",
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusBadge(
                  label: incident.status,
                  color: _statusColor(incident.status),
                ),
                Text(
                  incident.time,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
