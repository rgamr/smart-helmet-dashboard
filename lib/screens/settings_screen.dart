import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: provider.notificationsEnabled,
            onChanged: (val) => context.read<DashboardProvider>().toggleNotifications(val),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: provider.isDarkMode,
            onChanged: (_) => context.read<DashboardProvider>().toggleDarkMode(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version"),
            subtitle: const Text("1.0.0"),
          ),
        ],
      ),
    );
  }
}