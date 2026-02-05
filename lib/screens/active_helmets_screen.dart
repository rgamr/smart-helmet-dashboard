import 'package:flutter/material.dart';
import '../models/helmet_model.dart';
import 'helmet_details_screen.dart';

class ActiveHelmetsScreen extends StatelessWidget {
  const ActiveHelmetsScreen({super.key});

  final List<Helmet> helmets = const [
    Helmet(
      id: 'H-201',
      status: 'Active',
      battery: 86,
      workerName: 'Ahmed Raafat',
      lastUpdate: 'Just now',
    ),
    Helmet(
      id: 'H-214',
      status: 'Warning',
      battery: 18,
      workerName: 'Hesham Abaza',
      lastUpdate: '2 min ago',
    ),
    Helmet(
      id: 'H-233',
      status: 'Offline',
      battery: 0,
      workerName: null,
      lastUpdate: '45 min ago',
    ),
  ];

  Color _statusColor(String? status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Warning':
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
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmall = screenWidth < 600;
    final padding = isSmall ? 12.0 : 16.0;
    final iconSize = isSmall ? 20.0 : 24.0;
    final titleSize = isSmall ? 14.0 : 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Active Helmets')),
      body: helmets.isEmpty
          ? const Center(child: Text('No helmets available'))
          : ListView.separated(
        padding: EdgeInsets.all(padding),
        itemCount: helmets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final helmet = helmets[index];

          final workerName =
          helmet.workerName?.isNotEmpty == true
              ? helmet.workerName!
              : 'Unassigned';

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      HelmetDetailsScreen(helmet: helmet),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _statusColor(helmet.status)
                          .withOpacity(0.15),
                      child: Icon(
                        Icons.security,
                        size: iconSize,
                        color: _statusColor(helmet.status),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            helmet.id.isNotEmpty
                                ? helmet.id
                                : 'Unknown ID',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            workerName,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _Badge(
                                label: helmet.status,
                                color:
                                _statusColor(helmet.status),
                              ),
                              _Badge(
                                label:
                                'Battery ${helmet.battery ?? 0}%',
                                color:
                                _batteryColor(helmet.battery),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Text(
                      helmet.lastUpdate.isNotEmpty
                          ? helmet.lastUpdate
                          : '--',
                      style:
                      const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
