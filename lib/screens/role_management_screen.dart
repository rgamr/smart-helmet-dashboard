import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/api_service.dart';
import '../models/user_role.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final ApiService _apiService = ApiService();

  Future<void> _changeRole(
      String uid, String email, String currentRole) async {
    final newRole = currentRole.toLowerCase() == 'admin' ? 'viewer' : 'admin';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('role_management.change_role'.tr()),
        content: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: email,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '\n\n'),
              TextSpan(
                  text: '$currentRole  →  ',
                  style: const TextStyle(color: Colors.grey)),
              TextSpan(
                text: newRole,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: newRole == 'admin' ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('role_management.confirm'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await _apiService.setUserRole(uid, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'role_management.role_updated'.tr()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('common.error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('role_management.title'.tr()),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _apiService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 56, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text('common.error'.tr(),
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'role_management.no_users'.tr(),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'role_management.no_users_hint'.tr(),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final user = users[index];
              final uid = user['uid'] as String? ?? '';
              final email = user['email'] as String? ?? uid;
              final role = UserRoleExtension.fromString(
                      user['role'] as String?)
                  .label;
              final isAdmin = role == 'Admin';

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isAdmin
                        ? Colors.green.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.15),
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: isAdmin ? Colors.green : Colors.blue,
                    ),
                  ),
                  title: Text(email,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    uid.length > 20 ? '${uid.substring(0, 20)}…' : uid,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.green.withOpacity(0.12)
                              : Colors.blue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAdmin ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        tooltip: 'role_management.toggle_role'.tr(),
                        onPressed: () =>
                            _changeRole(uid, email, role.toLowerCase()),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
