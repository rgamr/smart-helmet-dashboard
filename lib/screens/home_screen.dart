import 'package:flutter/material.dart';
import '../models/dashboard_card_model.dart';
import 'workers_screen.dart';
import 'incidents_screen.dart';
import 'active_helmets_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<DashboardCardModel> cards = const  [
    DashboardCardModel(
        title: "Workers", icon: Icons.people, color: Colors.blue, metric: "12 online"),
    DashboardCardModel(
        title: "Active Helmets",
        icon: Icons.engineering,
        color: Colors.teal,
        metric: "15 active"),
    DashboardCardModel(
        title: "Incidents", icon: Icons.warning, color: Colors.red, metric: "3 open"),
    DashboardCardModel(
        title: "Pending Reports", icon: Icons.report, color: Colors.orange, metric: "3 pending"),
    DashboardCardModel(
        title: "Tasks Today", icon: Icons.task, color: Colors.blue, metric: "7 tasks"),
    DashboardCardModel(
        title: "Reports", icon: Icons.bar_chart, color: Colors.orange, metric: "5 pending"),
    DashboardCardModel(title: "Settings", icon: Icons.settings, color: Colors.grey),
  ];

  void _navigateCard(BuildContext context, String title) {
    switch (title) {
      case "Workers":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const WorkersScreen()));
        break;
      case "Active Helmets":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ActiveHelmetsScreen()));
        break;
      case "Incidents":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const IncidentsScreen()));
        break;
    // Add more routes as needed
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    // Responsive settings
    double padding = width < 600 ? 16 : 32;
    double appBarHeight = width < 600 ? 120 : 150;
    int crossAxis = 2;
    if (width > 1200)
      crossAxis = 4;
    else if (width > 800) crossAxis = 3;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              height: appBarHeight,
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
                      Text("Dashboard",
                          style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Welcome, Supervisor!",
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                  CircleAvatar(
                    radius: width < 600 ? 28 : 36,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        color: theme.colorScheme.primary, size: width < 600 ? 32 : 40),
                  ),
                ],
              ),
            ),

            // Main dashboard grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: padding,
                  mainAxisSpacing: padding,
                  childAspectRatio: 1.2,
                  children: cards
                      .map((card) => DashboardCard(
                    model: card,
                    onTap: () => _navigateCard(context, card.title),
                  ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final DashboardCardModel model;
  final VoidCallback? onTap;

  const DashboardCard({required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double iconSize = width < 600 ? 48 : 64;
    double fontSize = width < 600 ? 16 : 20;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(model.icon, size: iconSize, color: model.color),
              const SizedBox(height: 8),
              Text(model.title,
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: model.color)),
              if (model.metric != null) ...[
                const SizedBox(height: 4),
                Text(model.metric!,
                    style: TextStyle(color: model.color.withOpacity(0.8), fontSize: fontSize * 0.8)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
