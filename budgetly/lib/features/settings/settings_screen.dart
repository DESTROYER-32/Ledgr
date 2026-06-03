import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _appLock = false;
  bool _notifications = false;
  String _currency = 'USD';
  bool _canAuth = false;
  bool _isLoading = true;

  final _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR', 'BRL',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final appLock = await repo.get('app_lock');
    final notifications = await repo.get('notifications');
    final currency = await repo.get('currency');
    final canAuth = await AuthService.canAuthenticate();
    if (mounted) {
      setState(() {
        _appLock = appLock == 'true';
        _notifications = notifications == 'true';
        _currency = currency ?? 'USD';
        _canAuth = canAuth;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value && !_canAuth) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Biometric authentication not available on this device')),
        );
      }
      return;
    }
    setState(() => _appLock = value);
    await ref.read(settingsRepositoryProvider).set(
          'app_lock',
          value.toString(),
        );
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notifications = value);
    await ref.read(settingsRepositoryProvider).set(
          'notifications',
          value.toString(),
        );
    if (value) {
      await NotificationService.requestPermissions();
    }
  }

  Future<void> _setCurrency(String currency) async {
    setState(() => _currency = currency);
    await ref
        .read(settingsRepositoryProvider)
        .set('currency', currency);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(theme, 'Security', [
            SwitchListTile(
              secondary: Icon(
                Icons.lock_outline,
                color: _appLock
                    ? theme.colorScheme.primary
                    : null,
              ),
              title: const Text('App Lock'),
              subtitle: Text(
                _canAuth
                    ? 'Require biometric to open'
                    : 'Not available on this device',
              ),
              value: _appLock,
              onChanged: _canAuth ? _toggleAppLock : null,
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Notifications', [
            SwitchListTile(
              secondary: Icon(
                Icons.notifications_outlined,
                color: _notifications
                    ? theme.colorScheme.primary
                    : null,
              ),
              title: const Text('Bill Reminders'),
              subtitle: const Text(
                  'Alerts for recurring transactions'),
              value: _notifications,
              onChanged: _toggleNotifications,
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Currency', [
            ListTile(
              leading: Icon(Icons.monetization_on_outlined,
                  color: theme.colorScheme.primary),
              title: const Text('Currency'),
              subtitle: Text(_currency),
              trailing: DropdownButton<String>(
                value: _currency,
                items: _currencies
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _setCurrency(v);
                },
                underline: const SizedBox(),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Data', [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Export Data'),
              subtitle: const Text(
                  'Backup your data to a file'),
              onTap: () => context.push('/backup'),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import Data'),
              subtitle: const Text(
                  'Restore from backup or import CSV'),
              onTap: () => context.push('/backup'),
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Management', [
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Accounts'),
              subtitle: const Text(
                  'Manage your wallets and accounts'),
              onTap: () => context.push('/wallets'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              subtitle: const Text(
                  'Manage transaction categories'),
              onTap: () => context.push('/categories'),
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'About', [
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(ThemeData theme, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(title,
              style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )),
        ),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }
}
