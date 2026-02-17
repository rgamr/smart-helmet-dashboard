import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_card_model.dart';
import '../screens/workers_screen.dart';
import '../screens/active_helmets_screen.dart';
import '../screens/incidents_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/pending_reports_screen.dart';
import '../screens/settings_screen.dart';
import '../providers/dashboard_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateCard(BuildContext context, String title) {
    switch (title) {
      case "Workers":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const WorkersScreen()));
        break;

      case "Active Helmets":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ActiveHelmetsScreen()));
        break;

      case "Incidents":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const IncidentsScreen()));
        break;

      case "Tasks Today":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TasksScreen()));
        break;

      case "Reports":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
        break;

      case "Pending Reports":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PendingReportsScreen()));
        break;

      case "Settings":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    double padding = width < 600 ? 16 : 32;
    double appBarHeight = width < 600 ? 120 : 150;

    int crossAxis = 2;
    if (width > 1200) {
      crossAxis = 4;
    } else if (width > 800) {
      crossAxis = 3;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ===== Custom AppBar =====
            Container(
              height: appBarHeight,
              padding: EdgeInsets.symmetric(
                  horizontal: padding, vertical: padding / 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Dashboard",
                        style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Welcome, Supervisor!",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: width < 600 ? 28 : 36,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                      size: width < 600 ? 32 : 40,
                    ),
                  ),
                ],
              ),
            ),

            // ===== Dashboard Grid =====
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: padding,
                  mainAxisSpacing: padding,
                  childAspectRatio: 1.2,
                  children: [
                    WorkersCard(
                        onTap: () => _navigateCard(context, "Workers")),

                    ActiveHelmetsCard(
                        onTap: () =>
                            _navigateCard(context, "Active Helmets")),

                    IncidentsCard(
                        onTap: () =>
                            _navigateCard(context, "Incidents")),

                    DashboardCard(
                      title: "Pending Reports",
                      icon: Icons.report,
                      color: Colors.orange,
                      metric: "3 pending",
                      onTap: () =>
                          _navigateCard(context, "Pending Reports"),
                    ),

                    DashboardCard(
                      title: "Tasks Today",
                      icon: Icons.task,
                      color: Colors.blue,
                      metric: "7 tasks",
                      onTap: () =>
                          _navigateCard(context, "Tasks Today"),
                    ),

                    DashboardCard(
                      title: "Reports",
                      icon: Icons.bar_chart,
                      color: Colors.orange,
                      metric: "5 reports",
                      onTap: () =>
                          _navigateCard(context, "Reports"),
                    ),

                    DashboardCard(
                      title: "Settings",
                      icon: Icons.settings,
                      color: Colors.grey,
                      onTap: () =>
                          _navigateCard(context, "Settings"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ===== Metric Cards =====
//

class WorkersCard extends StatelessWidget {
  final VoidCallback onTap;
  const WorkersCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (_, dashboard, __) {
        int onlineWorkers = dashboard.workers
            .where((w) => w.status.toLowerCase() == 'online')
            .length;

        return DashboardCard(
          title: "Workers",
          icon: Icons.people,
          color: Colors.blue,
          metric: "$onlineWorkers online",
          onTap: onTap,
        );
      },
    );
  }
}

class ActiveHelmetsCard extends StatelessWidget {
  final VoidCallback onTap;
  const ActiveHelmetsCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (_, dashboard, __) {
        int activeHelmets = dashboard.helmets
            .where((h) => h.status.toLowerCase() == 'active')
            .length;

        return DashboardCard(
          title: "Active Helmets",
          icon: Icons.engineering,
          color: Colors.teal,
          metric: "$activeHelmets active",
          onTap: onTap,
        );
      },
    );
  }
}

class IncidentsCard extends StatelessWidget {
  final VoidCallback onTap;
  const IncidentsCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (_, dashboard, __) {
        int openIncidents = dashboard.incidents
            .where((i) => i.status.toLowerCase() == 'open')
            .length;

        return DashboardCard(
          title: "Incidents",
          icon: Icons.warning,
          color: Colors.red,
          metric: "$openIncidents open",
          onTap: onTap,
        );
      },
    );
  }
}

//
// ===== DashboardCard Widget =====
//

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? metric;
  final VoidCallback? onTap;

  const DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    this.metric,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double iconSize = width < 600 ? 48 : 64;
    double fontSize = width < 600 ? 16 : 20;

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (metric != null) ...[
                const SizedBox(height: 4),
                Text(
                  metric!,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: fontSize * 0.8,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
