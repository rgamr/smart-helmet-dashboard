import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';
import '../providers/user_provider.dart';
import '../models/incident_model.dart';
import '../services/api_service.dart';

class AllIncidentsScreen extends StatefulWidget {
  const AllIncidentsScreen({super.key});

  @override
  State<AllIncidentsScreen> createState() => _AllIncidentsScreenState();
}

class _AllIncidentsScreenState extends State<AllIncidentsScreen> {
  String _filter = 'all';
  String _search = '';
  final ApiService _apiService = ApiService();

  final List<Map<String, String>> _filterOptions = [
    {'key': 'all', 'label': 'All'},
    {'key': 'open', 'label': 'Open'},
    {'key': 'in progress', 'label': 'In Progress'},
    {'key': 'resolved', 'label': 'Resolved'},
  ];

  List<Incident> _applyFilters(List<Incident> all) {
    var list = all;
    if (_filter != 'all') {
      list = list
          .where((i) => i.status.toLowerCase() == _filter.toLowerCase())
          .toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((i) =>
              i.title.toLowerCase().contains(q) ||
              i.workerName.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.error_outline;
      case 'in progress':
        return Icons.pending_outlined;
      case 'resolved':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _updateStatus(Incident incident, String newStatus) async {
    if (incident.id.isEmpty) return;
    try {
      await _apiService.updateIncidentStatus(incident.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatusDialog(Incident incident) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status'),
        content: Text(incident.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (incident.status.toLowerCase() != 'open')
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(incident, 'Open');
              },
              child: const Text('Open', style: TextStyle(color: Colors.red)),
            ),
          if (incident.status.toLowerCase() != 'in progress')
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(incident, 'In Progress');
              },
              child: const Text('In Progress',
                  style: TextStyle(color: Colors.orange)),
            ),
          if (incident.status.toLowerCase() != 'resolved')
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(incident, 'Resolved');
              },
              child: const Text('Resolved'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final isAdmin = context.watch<UserProvider>().isAdmin;
    final incidents = _applyFilters(dashboard.incidents);

    return Scaffold(
      appBar: AppBar(
        title: Text('reports.recent_incidents'.tr()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${incidents.length}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Read-only banner for viewers
          if (!isAdmin)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.visibility, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text('common.view_only'.tr(),
                    style: const TextStyle(color: Colors.blue, fontSize: 13)),
              ]),
            ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search incidents...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),
          const SizedBox(height: 8),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((opt) {
                  final isSelected = _filter == opt['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(opt['label']!),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _filter = opt['key']!),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: dashboard.isLoading
                ? const Center(child: CircularProgressIndicator())
                : incidents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 64, color: Colors.green.shade300),
                            const SizedBox(height: 12),
                            Text(
                              _search.isNotEmpty
                                  ? 'No incidents match your search'
                                  : 'reports.no_incidents_reported'.tr(),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: incidents.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final inc = incidents[index];
                          final color = _statusColor(inc.status);
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: isAdmin
                                  ? () => _showStatusDialog(inc)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          color.withOpacity(0.12),
                                      child: Icon(_statusIcon(inc.status),
                                          color: color, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(inc.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15)),
                                          const SizedBox(height: 3),
                                          Text(inc.workerName,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13)),
                                          Text(inc.time,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(color: color),
                                      ),
                                      child: Text(inc.status,
                                          style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
