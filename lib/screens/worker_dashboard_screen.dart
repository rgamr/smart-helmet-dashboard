import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/dashboard_provider.dart';
import '../providers/user_provider.dart';
import '../models/worker_model.dart';
import '../models/helmet_model.dart';
import 'settings_screen.dart';

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final workerId = userProvider.workerId;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('worker_dashboard.title'.tr()),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          )
        ],
      ),
      body: workerId == null
          ? Center(child: Text('worker_dashboard.no_worker_assigned'.tr()))
          : Consumer<DashboardProvider>(
              builder: (context, dashboard, child) {
                if (dashboard.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final worker = dashboard.workers.cast<Worker?>().firstWhere(
                  (w) => w?.id == workerId,
                  orElse: () => null,
                );

                if (worker == null) {
                  return Center(child: Text('worker_dashboard.not_found'.tr()));
                }

                // Get assigned helmet
                final helmet = dashboard.helmets.cast<Helmet?>().firstWhere(
                  (h) => h?.id == worker.helmetId || h?.workerId == worker.id,
                  orElse: () => null,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      _buildHeaderCard(context, worker),
                      const SizedBox(height: 20),
                      
                      // Vitals Section
                      Text('worker_dashboard.my_vitals'.tr(), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(context, 'Heart Rate', '${worker.heartRate ?? 0} bpm', Icons.favorite, Colors.red)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(context, 'Oxygen', '${worker.oxygenLevel ?? 0}%', Icons.air, Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(context, 'Body Temp', '${worker.bodyTemperature ?? 0.0}°C', Icons.thermostat, Colors.orange)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(context, 'Status', worker.status, Icons.person, Colors.green)),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Helmet Status Section
                      Text('worker_dashboard.helmet_status'.tr(), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (helmet != null) ...[
                        Row(
                          children: [
                            Expanded(child: _buildStatCard(context, 'Battery', '${helmet.battery ?? 0}%', Icons.battery_charging_full, Colors.teal)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard(context, 'Helmet Temp', '${helmet.helmetTemperature ?? 0}°C', Icons.thermostat_auto, Colors.orangeAccent)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildStatCard(context, 'Ambient Temp', '${helmet.ambientTemperature ?? 0}°C', Icons.ac_unit, Colors.lightBlue)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard(context, 'Connection', helmet.status, Icons.wifi, helmet.status.toLowerCase() == 'active' ? Colors.green : Colors.red)),
                          ],
                        ),
                      ] else ...[
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(child: Text('worker_dashboard.no_helmet'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                        )
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Environmental Section
                      Text('worker_dashboard.environment'.tr(), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(context, 'CO Level', '${worker.coLevel ?? 0} ppm', Icons.cloud, Colors.grey)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(context, 'CO2 Level', '${worker.co2Level ?? 0} ppm', Icons.cloud_circle, Colors.blueGrey)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Worker worker) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${worker.id}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        worker.location ?? 'Unknown',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
