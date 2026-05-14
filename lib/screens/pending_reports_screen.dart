import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';
import '../providers/user_provider.dart';
import '../models/incident_model.dart';
import '../services/api_service.dart';

class PendingReportsScreen extends StatelessWidget {
  const PendingReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, UserProvider>(
      builder: (context, dashboard, userProvider, _) {
        final isAdmin = userProvider.isAdmin;
        final allPending = dashboard.incidents
            .where((i) =>
                i.status.toLowerCase() == 'open' ||
                i.status.toLowerCase() == 'in progress')
            .toList();

        return _PendingReportsView(
          isLoading: dashboard.isLoading,
          hasError: dashboard.hasError,
          allPending: allPending,
          onRetry: dashboard.retry,
          isAdmin: isAdmin,
        );
      },
    );
  }
}

class _PendingReportsView extends StatefulWidget {
  final bool isLoading;
  final bool hasError;
  final List<Incident> allPending;
  final VoidCallback onRetry;
  final bool isAdmin;

  const _PendingReportsView({
    required this.isLoading,
    required this.hasError,
    required this.allPending,
    required this.onRetry,
    required this.isAdmin,
  });

  @override
  State<_PendingReportsView> createState() => _PendingReportsViewState();
}

class _PendingReportsViewState extends State<_PendingReportsView> {
  String _filter = 'all'; // 'all', 'open', 'in_progress'
  final ApiService _apiService = ApiService();

  List<Incident> get _filtered {
    switch (_filter) {
      case 'open':
        return widget.allPending
            .where((i) => i.status.toLowerCase() == 'open')
            .toList();
      case 'in_progress':
        return widget.allPending
            .where((i) => i.status.toLowerCase() == 'in progress')
            .toList();
      default:
        return widget.allPending;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
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
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _updateStatus(Incident incident, String newStatus) async {
    if (incident.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('pending_reports.update_failed'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await _apiService.updateIncidentStatus(incident.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('pending_reports.status_updated'.tr()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('pending_reports.update_failed'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUpdateDialog(Incident incident) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('pending_reports.update_status'.tr()),
        content: Text(incident.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          if (incident.status.toLowerCase() == 'open')
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.15)),
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(incident, 'In Progress');
              },
              child: Text('pending_reports.mark_in_progress'.tr(),
                  style: const TextStyle(color: Colors.orange)),
            ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(incident, 'Resolved');
            },
            child: Text('pending_reports.mark_resolved'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterOptions = [
      {'key': 'all', 'label': 'pending_reports.filter_all'.tr()},
      {'key': 'open', 'label': 'pending_reports.filter_open'.tr()},
      {'key': 'in_progress', 'label': 'pending_reports.filter_in_progress'.tr()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('pending_reports.title'.tr()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.allPending.length}',
                  style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 56, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text('common.error'.tr(),
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: widget.onRetry,
                        icon: const Icon(Icons.refresh),
                        label: Text('common.retry'.tr()),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Read-only banner for viewers
          if (!widget.isAdmin)
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

          // Filter Chips
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: filterOptions.map((opt) {
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

                    // Summary strip
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _SummaryBadge(
                            count: widget.allPending
                                .where((i) =>
                                    i.status.toLowerCase() == 'open')
                                .length,
                            label: 'Open',
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          _SummaryBadge(
                            count: widget.allPending
                                .where((i) =>
                                    i.status.toLowerCase() == 'in progress')
                                .length,
                            label: 'In Progress',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    // List
                    Expanded(
                      child: _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 56, color: Colors.green.shade300),
                                  const SizedBox(height: 12),
                                  Text('pending_reports.no_pending'.tr(),
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 16)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, index) {
                                final incident = _filtered[index];
                                final color = _statusColor(incident.status);
                                return Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              color.withOpacity(0.12),
                                          child: Icon(
                                              _statusIcon(incident.status),
                                              color: color,
                                              size: 20),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                incident.title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                incident.workerName,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                incident.time,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status pill + update button
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color:
                                                    color.withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: color),
                                              ),
                                              child: Text(
                                                incident.status,
                                                style: TextStyle(
                                                    color: color,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            // Update button — admin only
                                            if (widget.isAdmin)
                                              TextButton.icon(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              icon: const Icon(Icons.update,
                                                  size: 14),
                                              label: Text(
                                                  'pending_reports.update'.tr(),
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              onPressed: () =>
                                                  _showUpdateDialog(incident),
                                            ),
                                          ],
                                        ),
                                      ],
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

class _SummaryBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryBadge(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text('$count',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
