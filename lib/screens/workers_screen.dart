import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/worker_model.dart';
import 'worker_details_screen.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        final filteredWorkers = dashboard.workers.where((w) {
          final matchesStatus =
              selectedFilter == 'All' || w.status == selectedFilter;
          final matchesSearch = searchQuery.isEmpty ||
              w.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              w.id.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesStatus && matchesSearch;
        }).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Workers')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search worker...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => searchQuery = ''),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Filters
                Wrap(
                  spacing: 8,
                  children: ['All', 'Online', 'Offline', 'Incident']
                      .map((filter) => ChoiceChip(
                    label: Text(filter),
                    selected: selectedFilter == filter,
                    onSelected: (_) =>
                        setState(() => selectedFilter = filter),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Worker List
                Expanded(
                  child: dashboard.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : dashboard.hasError
                      ? Center(
                    child: Text('Error loading workers'),
                  )
                      : ListView.separated(
                    itemCount: filteredWorkers.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final worker = filteredWorkers[index];
                      return WorkerCard(
                        worker: worker,
                        onTap: () {
                          dashboard.selectWorker(worker.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const WorkerDetailsScreen(),
                            ),
                          );
                        },
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

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onTap;

  const WorkerCard({super.key, required this.worker, required this.onTap});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'incident':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _helmetColor(String helmet) {
    return helmet.toLowerCase() == 'connected' ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _statusColor(worker.status).withOpacity(0.15),
                child: Icon(Icons.person, color: _statusColor(worker.status)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18)),
                    Text(worker.id,
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusBadge(
                          label: worker.status,
                          color: _statusColor(worker.status),
                        ),
                        const SizedBox(width: 6),
                        StatusBadge(
                          label: worker.helmet.toLowerCase() == 'connected'
                              ? 'Helmet ${worker.helmetBattery ?? 0}%'
                              : 'Helmet ${worker.helmet}',
                          color: _helmetColor(worker.helmet),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(worker.lastSeen,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

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
