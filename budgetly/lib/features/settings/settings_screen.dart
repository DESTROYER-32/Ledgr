import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/money_utils.dart';
import '../../core/utils/currency_utils.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _appLock = false;
  bool _notifications = false;
  String _currency = 'USD';
  int? _defaultWalletId;
  bool _canAuth = false;
  bool _isLoading = true;
  String _themeMode = 'system';
  int _themeSeed = 0xFF1A6D4A;

  final _currencies = CurrencyUtils.codes;

  static const _themeSeeds = <int>[
    0xFF1A6D4A, // Green
    0xFF1565C0, // Blue
    0xFF7B1FA2, // Purple
    0xFFC62828, // Red
    0xFFEF6C00, // Orange
    0xFF283593, // Indigo
    0xFF00838F, // Teal
    0xFF4E342E, // Brown
    0xFF37474F, // Blue Grey
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
    final defaultWalletId = await repo.get('default_wallet_id');
    final themeMode = await repo.get('theme_mode');
    final themeSeed = await repo.get('theme_seed');
    final canAuth = await AuthService.canAuthenticate();
    if (mounted) {
      setState(() {
        _appLock = appLock == 'true';
        _notifications = notifications == 'true';
        _currency = currency ?? 'USD';
        _defaultWalletId = defaultWalletId == null
            ? null
            : int.tryParse(defaultWalletId);
        _themeMode = themeMode ?? 'system';
        _themeSeed = themeSeed != null ? int.parse(themeSeed) : 0xFF1A6D4A;
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

  Future<void> _setDefaultWallet(int? walletId) async {
    setState(() => _defaultWalletId = walletId);
    final repo = ref.read(settingsRepositoryProvider);
    if (walletId == null) {
      await repo.remove('default_wallet_id');
    } else {
      await repo.set('default_wallet_id', walletId.toString());
    }
    ref.invalidate(defaultWalletIdProvider);
  }

  Future<void> _setCurrency(String currency) async {
    setState(() => _currency = currency);
    MoneyUtils.setDefaultCurrencyCode(currency);
    await ref.read(settingsRepositoryProvider).set('currency', currency);
    ref.invalidate(currencyCodeProvider);
    ref.invalidate(totalBalanceProvider);
  }

  Future<void> _setThemeMode(String mode) async {
    setState(() => _themeMode = mode);
    await ref.read(settingsRepositoryProvider).set('theme_mode', mode);
    ref.invalidate(themeConfigProvider);
  }

  Future<void> _setThemeSeed(int seed) async {
    setState(() => _themeSeed = seed);
    await ref
        .read(settingsRepositoryProvider)
        .set('theme_seed', seed.toString());
    ref.invalidate(themeConfigProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(activeWalletsProvider);

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
          _section(theme, 'Account Defaults', [
            walletsAsync.when(
              data: (wallets) {
                final hasSelected = wallets.any((w) => w.id == _defaultWalletId);
                final selectedId = hasSelected ? _defaultWalletId : null;
                return ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined,
                      color: theme.colorScheme.primary),
                  title: const Text('Default Account'),
                  subtitle: const Text('Used for quick transaction add'),
                  trailing: SizedBox(
                    width: 160,
                    child: DropdownButton<int?>(
                      value: selectedId,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...wallets.map((w) => DropdownMenuItem<int?>(
                              value: w.id,
                              child: Text(
                                w.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: _setDefaultWallet,
                      underline: const SizedBox(),
                    ),
                  ),
                );
              },
              error: (_, _) => const ListTile(
                leading: Icon(Icons.error_outline),
                title: Text('Default Account'),
                subtitle: Text('Unable to load accounts'),
              ),
              loading: () => const ListTile(
                title: Text('Default Account'),
                trailing: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
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
          _section(theme, 'Theme', [
            ListTile(
              leading: Icon(Icons.palette_outlined,
                  color: theme.colorScheme.primary),
              title: const Text('Theme Mode'),
              trailing: DropdownButton<String>(
                value: _themeMode,
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (v) {
                  if (v != null) _setThemeMode(v);
                },
                underline: const SizedBox(),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_themeSeeds.length, (i) {
                  final color = Color(_themeSeeds[i]);
                  final selected = _themeSeed == _themeSeeds[i];
                  return GestureDetector(
                    onTap: () => _setThemeSeed(_themeSeeds[i]),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: theme.colorScheme.onSurface, width: 2.5)
                            : null,
                        boxShadow: selected
                            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }),
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
          _section(theme, 'Smart Features', [
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Smart Labels'),
              subtitle: const Text(
                  'Auto-categorize transactions by keyword'),
              onTap: () => context.push('/smart-labels'),
            ),
            ListTile(
              leading: const Icon(Icons.call_split),
              title: const Text('Bill Splitter'),
              subtitle: const Text('Split expenses with others'),
              onTap: () => context.push('/bill-splitter'),
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Tracking', [
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('Subscriptions'),
              subtitle: const Text('View subscription transactions'),
              onTap: () => context.push('/subscriptions'),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Credit & Debt'),
              subtitle: const Text('Track lent and borrowed money'),
              onTap: () => context.push('/credit-debt'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Activity Log'),
              subtitle: const Text('Recently deleted transactions'),
              onTap: () => context.push('/activity'),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Goals & Loans'),
              subtitle: const Text(
                  'Savings goals and debt tracking'),
              onTap: () => context.push('/objectives'),
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
