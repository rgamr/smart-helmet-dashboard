import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final isArabic = context.locale == const Locale('ar');

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('settings.enable_notifications'.tr()),
            value: provider.notificationsEnabled,
            onChanged: (val) =>
                context.read<DashboardProvider>().toggleNotifications(val),
          ),
          SwitchListTile(
            title: Text('settings.dark_mode'.tr()),
            value: provider.isDarkMode,
            onChanged: (_) =>
                context.read<DashboardProvider>().toggleDarkMode(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('settings.language'.tr()),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'en',
                  label: Text('settings.english'.tr()),
                ),
                ButtonSegment(
                  value: 'ar',
                  label: Text('settings.arabic'.tr()),
                ),
              ],
              selected: {isArabic ? 'ar' : 'en'},
              onSelectionChanged: (selection) {
                final locale = selection.first == 'ar'
                    ? const Locale('ar')
                    : const Locale('en');
                context.setLocale(locale);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('settings.app_version'.tr()),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}