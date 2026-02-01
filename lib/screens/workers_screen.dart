import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import 'worker_details_screen.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  String selectedFilter = 'All';

  // Sample worker data (replace with backend later)
  List<Worker> workers = [
    Worker(name: 'Ahmed Raafat', id: 'W-102', status: 'Online', helmet: 'Connected', lastSeen: '2 min ago'),
    Worker(name: 'Raghad Amr', id: 'W-117', status: 'Online', helmet: 'Connected', lastSeen: 'Just now'),
    Worker(name: 'Ahmed Eslam', id: 'W-121', status: 'Offline', helmet: 'Disconnected', lastSeen: '1 hr ago'),
    Worker(name: 'Hesham Abaza', id: 'W-135', status: 'Incident', helmet: 'Disconnected', lastSeen: '10 min ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter workers based on selected status
    final filteredWorkers = selectedFilter == 'All'
        ? workers
        : workers.where((w) => w.status == selectedFilter).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                'Workers',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${workers.length} total • ${workers.where((w) => w.status == 'Online').length} online',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Search (optional, logic can be implemented later)
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search worker...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
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
                  onSelected: (_) {
                    setState(() => selectedFilter = filter);
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Worker list
              Expanded(
                child: ListView.separated(
                  itemCount: filteredWorkers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final worker = filteredWorkers[index];
                    return WorkerCard(worker: worker);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= WorkerCard =================
class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({required this.worker});

  Color _statusColor(String status) {
    switch (status) {
      case 'Online':
        return Colors.green;
      case 'Incident':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _helmetColor(String helmet) {
    return helmet == 'Connected' ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Navigate to worker details
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkerDetailsScreen(worker: worker)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _statusColor(worker.status).withOpacity(0.15),
                child: Icon(Icons.person, color: _statusColor(worker.status)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(worker.id, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusBadge(label: worker.status, color: _statusColor(worker.status)),
                        const SizedBox(width: 6),
                        StatusBadge(label: 'Helmet ${worker.helmet}', color: _helmetColor(worker.helmet)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(worker.lastSeen, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= StatusBadge =================
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
