import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';
import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
import '../models/worker_model.dart';
import '../models/helmet_model.dart';
import 'settings_screen.dart';
import 'charts_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _WorkerDashboardPage(),
      const _MyTasksPage(),
      const _MyIncidentsPage(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: 'worker_home.my_dashboard'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_outlined),
            selectedIcon: const Icon(Icons.task),
            label: 'worker_home.my_tasks'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.warning_amber_outlined),
            selectedIcon: const Icon(Icons.warning_amber),
            label: 'worker_home.my_incidents'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: 'settings.title'.tr(),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  WORKER DASHBOARD — Shows worker's own vitals, helmet, alerts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _WorkerDashboardPage extends StatelessWidget {
  const _WorkerDashboardPage();

  Color _vitalColor(String type, dynamic v) {
    if (v == null || v == 0) return Colors.grey;
    if (type == 'heart') {
      int h = v;
      return h > 120 ? Colors.red : h > 100 ? Colors.orange : Colors.green;
    }
    if (type == 'oxygen') {
      int o = v;
      return o < 90 ? Colors.red : o < 95 ? Colors.orange : Colors.green;
    }
    if (type == 'temp') {
      double t = v;
      return t > 38.5 ? Colors.red : t > 37.5 ? Colors.orange : Colors.green;
    }
    return Colors.grey;
  }

  Color _gasColor(String type, double? v) {
    if (v == null) return Colors.grey;
    if (type == 'co')
      return v > 35 ? Colors.red : v > 20 ? Colors.orange : Colors.green;
    if (type == 'co2')
      return v > 1000 ? Colors.red : v > 800 ? Colors.orange : Colors.green;
    if (type == 'o2')
      return v < 19.5 ? Colors.red : v < 20.5 ? Colors.orange : Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final theme = Theme.of(context);

    final workerName =
        userProvider.workerName ?? userProvider.user?.email ?? 'Worker';
    final workerId = userProvider.workerId;

    // Find this worker's data
    final Worker? myWorker = workerId != null
        ? dashboard.workers
            .where((w) => w.id == workerId)
            .fold<Worker?>(null, (_, w) => w)
        : null;

    // Find my helmet
    final myHelmet = myWorker != null
        ? dashboard.helmets
            .where((h) =>
                h.workerName == myWorker.name ||
                h.id == myWorker.helmet)
            .fold<Helmet?>(null, (_, h) => h)
        : null;

    return Scaffold(
      body: SafeArea(
        child: dashboard.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primaryContainer,
                            ]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: const Icon(Icons.engineering,
                                    color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'worker_home.welcome'.tr(args: [workerName]),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'worker_home.role_badge'.tr(),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (myWorker != null) ...[
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _StatusPill(
                                  label: myWorker.status,
                                  color: myWorker.status.toLowerCase() ==
                                          'online'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                if (myWorker.isHelmetWorn == true)
                                  _StatusPill(
                                    label: 'worker_home.helmet_on'.tr(),
                                    color: Colors.green,
                                  )
                                else
                                  _StatusPill(
                                    label: 'worker_home.helmet_off'.tr(),
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (myWorker == null && workerId != null) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.link_off,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('worker_home.not_linked'.tr(),
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('worker_home.contact_admin'.tr(),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],

                    if (myWorker != null) ...[
                      const SizedBox(height: 20),

                      // ── My Vital Signs ──────────────────────────────
                      _SectionTitle('worker_home.my_vitals'.tr()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _VitalCard(
                            icon: Icons.favorite,
                            label: 'worker_details.heart_rate'.tr(),
                            value: myWorker.heartRate != null
                                ? '${myWorker.heartRate}'
                                : '--',
                            unit: 'bpm',
                            color: _vitalColor('heart', myWorker.heartRate),
                          ),
                          const SizedBox(width: 10),
                          _VitalCard(
                            icon: Icons.water_drop,
                            label: 'worker_details.oxygen'.tr(),
                            value: myWorker.oxygenLevel != null
                                ? '${myWorker.oxygenLevel}'
                                : '--',
                            unit: '%',
                            color: _vitalColor('oxygen', myWorker.oxygenLevel),
                          ),
                          const SizedBox(width: 10),
                          _VitalCard(
                            icon: Icons.thermostat,
                            label: 'worker_details.body_temp'.tr(),
                            value: myWorker.bodyTemperature != null
                                ? myWorker.bodyTemperature!.toStringAsFixed(1)
                                : '--',
                            unit: '°C',
                            color: _vitalColor('temp', myWorker.bodyTemperature),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Environmental ──────────────────────────────
                      _SectionTitle('worker_details.environmental'.tr()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _VitalCard(
                            icon: Icons.cloud,
                            label: 'CO',
                            value: myWorker.coLevel != null
                                ? myWorker.coLevel!.toStringAsFixed(1)
                                : '--',
                            unit: 'ppm',
                            color: _gasColor('co', myWorker.coLevel),
                          ),
                          const SizedBox(width: 10),
                          _VitalCard(
                            icon: Icons.cloud_queue,
                            label: 'CO₂',
                            value: myWorker.co2Level != null
                                ? myWorker.co2Level!.toStringAsFixed(0)
                                : '--',
                            unit: 'ppm',
                            color: _gasColor('co2', myWorker.co2Level),
                          ),
                          const SizedBox(width: 10),
                          _VitalCard(
                            icon: Icons.air,
                            label: 'O₂',
                            value: myWorker.surroundingO2 != null
                                ? myWorker.surroundingO2!.toStringAsFixed(1)
                                : '--',
                            unit: '%',
                            color: _gasColor('o2', myWorker.surroundingO2),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Safety Alerts ──────────────────────────────
                      _SectionTitle('worker_details.safety_events'.tr()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _AlertCard(
                              icon: Icons.warning_amber,
                              label: 'worker_details.fall_detected'.tr(),
                              value: myWorker.fallDetected == true
                                  ? '🆘 YES'
                                  : '✅ No',
                              color: myWorker.fallDetected == true
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _AlertCard(
                              icon: Icons.speed,
                              label: 'worker_details.impact_count'.tr(),
                              value: '${myWorker.impactCount ?? 0}',
                              color: (myWorker.impactCount ?? 0) > 0
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Helmet Info ──────────────────────────────
                      if (myHelmet != null) ...[
                        _SectionTitle('worker_home.my_helmet'.tr()),
                        const SizedBox(height: 8),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor:
                                      theme.colorScheme.primary.withOpacity(0.1),
                                  child: Icon(Icons.engineering,
                                      color: theme.colorScheme.primary,
                                      size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Helmet ${myHelmet.id}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(myHelmet.status,
                                          style: TextStyle(
                                            color: myHelmet.status
                                                        .toLowerCase() ==
                                                    'active'
                                                ? Colors.green
                                                : Colors.orange,
                                            fontSize: 13,
                                          )),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Icon(Icons.battery_std,
                                        color: (myHelmet.battery ?? 0) > 20
                                            ? Colors.green
                                            : Colors.red),
                                    Text('${myHelmet.battery ?? 0}%',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Quick Access: My Charts ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.show_chart),
                          label: Text('worker_home.view_my_charts'.tr()),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChartsScreen(
                                    preselectedWorkerId: workerId),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  MY TASKS — Filtered to this worker only
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MyTasksPage extends StatelessWidget {
  const _MyTasksPage();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final workerName = userProvider.workerName ?? '';
    final workerId = userProvider.workerId ?? '';

    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          // Filter tasks assigned to this worker
          final myTasks = taskProvider.tasks
              .where((t) =>
                  t.assignedTo.toLowerCase() == workerName.toLowerCase() ||
                  t.assignedTo.toLowerCase() == workerId.toLowerCase())
              .toList();

          return Scaffold(
            appBar: AppBar(title: Text('worker_home.my_tasks'.tr())),
            body: taskProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : myTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.task_alt,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('worker_home.no_tasks_assigned'.tr(),
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 16)),
                          ],
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: myTasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final task = myTasks[index];
                          final statusColor = task.status == 'completed'
                              ? Colors.green
                              : task.status == 'in_progress'
                                  ? Colors.orange
                                  : Colors.red;
                          final priorityColor = task.priority == 'high'
                              ? Colors.red
                              : task.priority == 'medium'
                                  ? Colors.orange
                                  : Colors.green;

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        task.status == 'completed'
                                            ? Icons.check_circle
                                            : task.status == 'in_progress'
                                                ? Icons.pending
                                                : Icons.radio_button_unchecked,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(task.title,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  if (task.description != null &&
                                      task.description!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(task.description!,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _ChipSmall(
                                          label: 'tasks.${task.status}'.tr(),
                                          color: statusColor),
                                      const SizedBox(width: 8),
                                      _ChipSmall(
                                          label:
                                              'tasks.priority_${task.priority}'.tr(),
                                          color: priorityColor),
                                      if (task.dueDate != null) ...[
                                        const Spacer(),
                                        Icon(Icons.calendar_today,
                                            size: 12,
                                            color: Colors.grey.shade400),
                                        const SizedBox(width: 4),
                                        Text(task.dueDate!,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  MY INCIDENTS — Filtered to this worker only
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MyIncidentsPage extends StatelessWidget {
  const _MyIncidentsPage();

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

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final workerName = userProvider.workerName ?? '';

    final myIncidents = dashboard.incidents
        .where((i) => i.workerName.toLowerCase() == workerName.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('worker_home.my_incidents'.tr())),
      body: myIncidents.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green.shade300),
                  const SizedBox(height: 12),
                  Text('worker_home.no_incidents'.tr(),
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('worker_home.stay_safe'.tr(),
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: myIncidents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                final inc = myIncidents[index];
                final color = _statusColor(inc.status);
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withOpacity(0.12),
                          child: Icon(
                            inc.status.toLowerCase() == 'resolved'
                                ? Icons.check_circle_outline
                                : Icons.warning_amber,
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inc.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              const SizedBox(height: 3),
                              Text(inc.time,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
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
                );
              },
            ),
          ),
        ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SHARED WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
      );
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _VitalCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.unit,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text(unit,
                    style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
                const SizedBox(height: 4),
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      );
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _AlertCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _ChipSmall extends StatelessWidget {
  final String label;
  final Color color;
  const _ChipSmall({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}
