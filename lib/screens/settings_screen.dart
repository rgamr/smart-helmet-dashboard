import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/dashboard_provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import '../screens/role_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings.logout'.tr()),
        content: Text('settings.logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('settings.logout'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);
    await context.read<UserProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isAdmin;
    final isArabic = context.locale == const Locale('ar');

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            children: [
          // ── Role Badge ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isAdmin
                      ? Colors.green.withOpacity(0.15)
                      : Colors.blue.withOpacity(0.15),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: isAdmin ? Colors.green : Colors.blue,
                  ),
                ),
                title: Text(userProvider.user?.email ?? ''),
                subtitle: Text(
                  isAdmin
                      ? 'settings.admin'.tr()
                      : 'settings.viewer'.tr(),
                  style: TextStyle(
                      color: isAdmin ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? Colors.green.withOpacity(0.12)
                        : Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'settings.role'.tr(),
                    style: TextStyle(
                        fontSize: 11,
                        color: isAdmin ? Colors.green : Colors.blue),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── General ─────────────────────────────────────────────────────
          _SectionHeader('settings.title'.tr()),
          SwitchListTile(
            title: Text('settings.enable_notifications'.tr()),
            secondary: const Icon(Icons.notifications_outlined),
            value: provider.notificationsEnabled,
            onChanged: (val) =>
                context.read<DashboardProvider>().toggleNotifications(val),
          ),
          SwitchListTile(
            title: Text('settings.dark_mode'.tr()),
            secondary: const Icon(Icons.dark_mode_outlined),
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
                    value: 'en', label: Text('settings.english'.tr())),
                ButtonSegment(
                    value: 'ar', label: Text('settings.arabic'.tr())),
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

          // ── Alert Thresholds (Admin only) ────────────────────────────────
          if (isAdmin) ...[
            const Divider(),
            _SectionHeader('settings.thresholds'.tr()),
            _ThresholdTile(
              icon: Icons.favorite,
              iconColor: Colors.red,
              label: 'settings.heart_rate_max'.tr(),
              value: provider.heartRateMax.toString(),
              unit: 'bpm',
              onEdit: () => _editThreshold(
                context,
                'settings.heart_rate_max'.tr(),
                provider.heartRateMax.toString(),
                (val) => provider.updateThresholds(
                    heartRateMax: int.tryParse(val)),
              ),
            ),
            _ThresholdTile(
              icon: Icons.air,
              iconColor: Colors.blue,
              label: 'settings.oxygen_min'.tr(),
              value: provider.oxygenMin.toString(),
              unit: '%',
              onEdit: () => _editThreshold(
                context,
                'settings.oxygen_min'.tr(),
                provider.oxygenMin.toString(),
                (val) => provider.updateThresholds(
                    oxygenMin: int.tryParse(val)),
              ),
            ),
            _ThresholdTile(
              icon: Icons.thermostat,
              iconColor: Colors.orange,
              label: 'settings.body_temp_max'.tr(),
              value: provider.bodyTempMax.toString(),
              unit: '°C',
              onEdit: () => _editThreshold(
                context,
                'settings.body_temp_max'.tr(),
                provider.bodyTempMax.toString(),
                (val) => provider.updateThresholds(
                    bodyTempMax: double.tryParse(val)),
              ),
            ),
            _ThresholdTile(
              icon: Icons.cloud,
              iconColor: Colors.purple,
              label: 'settings.co_max'.tr(),
              value: provider.coMax.toString(),
              unit: 'ppm',
              onEdit: () => _editThreshold(
                context,
                'settings.co_max'.tr(),
                provider.coMax.toString(),
                (val) =>
                    provider.updateThresholds(coMax: double.tryParse(val)),
              ),
            ),
            _ThresholdTile(
              icon: Icons.cloud_queue,
              iconColor: Colors.teal,
              label: 'settings.co2_max'.tr(),
              value: provider.co2Max.toString(),
              unit: 'ppm',
              onEdit: () => _editThreshold(
                context,
                'settings.co2_max'.tr(),
                provider.co2Max.toString(),
                (val) =>
                    provider.updateThresholds(co2Max: double.tryParse(val)),
              ),
            ),
            _ThresholdTile(
              icon: Icons.air_outlined,
              iconColor: Colors.indigo,
              label: 'settings.surrounding_o2_min'.tr(),
              value: provider.surroundingO2Min.toString(),
              unit: '%',
              onEdit: () => _editThreshold(
                context,
                'settings.surrounding_o2_min'.tr(),
                provider.surroundingO2Min.toString(),
                (val) => provider.updateThresholds(
                    surroundingO2Min: double.tryParse(val)),
              ),
            ),
          ],

          // ── Admin Tools ─────────────────────────────────────────────────
          if (isAdmin) ...[
            const Divider(),
            _SectionHeader('settings.admin_tools'.tr()),
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.green),
              title: Text('settings.role_management'.tr()),
              subtitle: Text('settings.role_management_subtitle'.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RoleManagementScreen(),
                ),
              ),
            ),
          ],

          // ── App Info ─────────────────────────────────────────────────────
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('settings.app_version'.tr()),
            subtitle: const Text('1.0.0'),
          ),

          // ── Logout ───────────────────────────────────────────────────────
          const Divider(),
          ListTile(
            leading: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'settings.logout'.tr(),
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: _isLoggingOut ? null : _logout,
          ),
          const SizedBox(height: 24),
        ],
      ),
     ),
    ),
    );
  }

  Future<void> _editThreshold(
    BuildContext context,
    String label,
    String currentValue,
    void Function(String) onSave,
  ) async {
    final ctrl = TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              onSave(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ThresholdTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final VoidCallback onEdit;

  const _ThresholdTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.12),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value $unit',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: iconColor),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onEdit,
    );
  }
}