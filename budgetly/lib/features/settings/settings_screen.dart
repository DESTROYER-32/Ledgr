import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/currency_options.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/modern_selection_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = false;
  int? _defaultWalletId;
  bool _isLoading = true;
  bool _securityBusy = false;
  bool _demoMode = false;
  bool _resetBusy = false;
  String? _userName;
  String _themeMode = 'system';
  int _themeSeed = 0xFF1A6D4A;
  String _displayCurrency = MoneyUtils.defaultCurrencyCode;
  bool _showDefaultCurrency = true;
  List<String> _favoriteCurrencies = CurrencyUtils.codes;

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

  static const _lockTimeoutOptions = <ModernSelectionItem<int>>[
    ModernSelectionItem(
      value: -1,
      title: 'When app is opened',
      subtitle: 'Default. Do not lock just because you switch apps',
      icon: Icons.lock_open_outlined,
    ),
    ModernSelectionItem(
      value: 0,
      title: 'Immediately after leaving',
      subtitle: 'Lock as soon as you return to Budgetly',
      icon: Icons.lock_clock_outlined,
    ),
    ModernSelectionItem(
      value: 60,
      title: 'After 1 minute',
      subtitle: 'Allow quick app switching without unlocking again',
      icon: Icons.timer_outlined,
    ),
    ModernSelectionItem(
      value: 300,
      title: 'After 5 minutes',
      subtitle: 'Longer grace period before locking',
      icon: Icons.timer_3_select_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final notifications = await repo.get('notifications');
    final defaultWalletId = await repo.get('default_wallet_id');
    final themeMode = await repo.get('theme_mode');
    final themeSeed = await repo.get('theme_seed');
    final displayCurrency = await repo.get('display_currency');
    final showDefaultCurrency = await repo.get('show_default_currency');
    final favoriteCurrencies = await repo.get('favorite_currencies');
    final demoMode = await repo.get('budgetly_demo_mode');
    final userName = await repo.get('user_name');
    if (mounted) {
      setState(() {
        _notifications = notifications == 'true';
        _defaultWalletId = defaultWalletId == null
            ? null
            : int.tryParse(defaultWalletId);
        _themeMode = themeMode ?? 'system';
        _themeSeed = int.tryParse(themeSeed ?? '') ?? 0xFF1A6D4A;
        _displayCurrency = displayCurrency ?? MoneyUtils.defaultCurrencyCode;
        _showDefaultCurrency = showDefaultCurrency != 'false';
        _favoriteCurrencies = _decodeFavoriteCurrencies(favoriteCurrencies);
        _demoMode = demoMode == 'true';
        final trimmedName = userName?.trim();
        _userName = trimmedName == null || trimmedName.isEmpty
            ? null
            : trimmedName;
        _isLoading = false;
      });
    }
  }

  Future<void> _resetEverything() async {
    final first = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset everything?'),
        content: const Text(
          'This permanently deletes all accounts, transactions, budgets, objectives, categories, recurring items, settings, and demo data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;

    final controller = TextEditingController();
    final second = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type RESET to permanently erase all Budgetly data.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Confirmation'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim().toUpperCase() == 'RESET',
            ),
            child: const Text('Erase everything'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (second != true || !mounted) return;

    setState(() => _resetBusy = true);
    final db = ref.read(appDatabaseProvider);
    await db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await db.transaction(() async {
        for (final table in [
          'delete_logs',
          'associated_titles',
          'recurring_transactions',
          'budget_wallets',
          'budget_category_limits',
          'transactions',
          'objectives',
          'budgets',
          'categories',
          'wallets',
          'settings',
        ]) {
          await db.customStatement('DELETE FROM $table');
          await db.customStatement(
            "DELETE FROM sqlite_sequence WHERE name = '$table'",
          );
        }
      });
    } finally {
      await db.customStatement('PRAGMA foreign_keys = ON');
    }
    ref.invalidate(activeWalletsProvider);
    ref.invalidate(activeCategoriesProvider);
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(allBudgetsProvider);
    ref.invalidate(allObjectivesProvider);
    ref.invalidate(activeRecurringProvider);
    ref.invalidate(themeConfigProvider);
    ref.invalidate(displayCurrencyProvider);
    ref.invalidate(favoriteCurrenciesProvider);
    ref.invalidate(totalBalanceProvider);
    if (!mounted) return;
    setState(() {
      _resetBusy = false;
      _demoMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All Budgetly data has been reset.')),
    );
    context.go('/onboarding');
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notifications = value);
    await ref
        .read(settingsRepositoryProvider)
        .set('notifications', value.toString());
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

  Future<void> _setThemeMode(String mode) async {
    setState(() => _themeMode = mode);
    await ref.read(settingsRepositoryProvider).set('theme_mode', mode);
    ref.invalidate(themeConfigProvider);
  }

  Future<void> _setDisplayCurrency(String code) async {
    setState(() => _displayCurrency = code);
    await ref.read(settingsRepositoryProvider).set('display_currency', code);
    ref.invalidate(displayCurrencyProvider);
    ref.invalidate(totalBalanceProvider);
  }

  Future<void> _editUserName() async {
    final controller = TextEditingController(text: _userName ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'What should Budgetly call you?',
          ),
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;

    final trimmed = result.trim();
    final repo = ref.read(settingsRepositoryProvider);
    if (trimmed.isEmpty) {
      await repo.remove('user_name');
    } else {
      await repo.set('user_name', trimmed);
    }
    if (!mounted) return;
    setState(() => _userName = trimmed.isEmpty ? null : trimmed);
    ref.invalidate(userNameProvider);
  }

  Future<void> _setShowDefaultCurrency(bool value) async {
    setState(() => _showDefaultCurrency = value);
    await ref
        .read(settingsRepositoryProvider)
        .set('show_default_currency', value.toString());
    ref.invalidate(showDefaultCurrencyProvider);
  }

  String? _currencyName(String code) {
    for (final currency in CurrencyUtils.currencies) {
      if (currency.code == code) return currency.name;
    }
    return null;
  }

  IconData _walletIcon(String type) => switch (type) {
    'savings' => Icons.savings_outlined,
    'cash' => Icons.payments_outlined,
    'credit_card' => Icons.credit_card_outlined,
    'loan' => Icons.account_balance_wallet_outlined,
    _ => Icons.account_balance_outlined,
  };

  List<String> _decodeFavoriteCurrencies(String? raw) {
    if (raw == null || raw.isEmpty) return CurrencyUtils.codes;
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        final favorites = decoded
            .whereType<String>()
            .map((code) => code.toUpperCase())
            .where(CurrencyUtils.codes.contains)
            .toSet()
            .toList();
        return favorites.isEmpty ? CurrencyUtils.codes : favorites;
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to parse favorite currencies',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return CurrencyUtils.codes;
  }

  Future<void> _setFavoriteCurrencies(List<String> codes) async {
    final favorites = codes
        .where(CurrencyUtils.codes.contains)
        .toSet()
        .toList();
    final repo = ref.read(settingsRepositoryProvider);
    setState(
      () => _favoriteCurrencies = favorites.isEmpty
          ? CurrencyUtils.codes
          : favorites,
    );
    if (favorites.isEmpty || favorites.length == CurrencyUtils.codes.length) {
      await repo.remove('favorite_currencies');
    } else {
      await repo.set('favorite_currencies', json.encode(favorites));
    }
    ref.invalidate(favoriteCurrenciesProvider);
  }

  Future<void> _showFavoriteCurrenciesDialog() async {
    final selected = _favoriteCurrencies.toSet();
    var query = '';
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;
          final filtered = CurrencyUtils.currencies.where((currency) {
            final q = query.trim().toLowerCase();
            return q.isEmpty ||
                currency.code.toLowerCase().contains(q) ||
                currency.name.toLowerCase().contains(q) ||
                currency.symbol.toLowerCase().contains(q);
          }).toList();

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.82,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorite Currencies',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Currency lists will show only selected currencies. Select all or none to show every currency.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search currency, code, or symbol',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            setDialogState(() => query = value),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setDialogState(() {
                                selected
                                  ..clear()
                                  ..addAll(CurrencyUtils.codes);
                              }),
                              icon: const Icon(Icons.done_all_rounded),
                              label: const Text('Select All'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setDialogState(selected.clear),
                              icon: const Icon(Icons.remove_done_rounded),
                              label: const Text('Unselect All'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final currency = filtered[index];
                      final isSelected = selected.contains(currency.code);
                      return Material(
                        color: isSelected
                            ? cs.primaryContainer
                            : cs.surfaceContainerHighest.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setDialogState(() {
                            if (isSelected) {
                              selected.remove(currency.code);
                            } else {
                              selected.add(currency.code);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected
                                      ? cs.primary
                                      : cs.surface,
                                  foregroundColor: isSelected
                                      ? cs.onPrimary
                                      : cs.primary,
                                  child: Text(
                                    currency.symbol,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currency.code,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        currency.name,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 160),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    key: ValueKey(isSelected),
                                    color: isSelected
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, selected.toList()),
                            child: Text('Save (${selected.length})'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (result != null) {
      await _setFavoriteCurrencies(result);
    }
  }

  Future<void> _setThemeSeed(int seed) async {
    setState(() => _themeSeed = seed);
    await ref
        .read(settingsRepositoryProvider)
        .set('theme_seed', seed.toString());
    ref.invalidate(themeConfigProvider);
  }

  Future<String?> _askForPin({required String title}) async {
    final first = TextEditingController();
    final second = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: first,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.length < 4) {
                    return 'Use at least 4 digits';
                  }
                  if (int.tryParse(value) == null) return 'Digits only';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: second,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: const InputDecoration(
                  labelText: 'Confirm PIN',
                  counterText: '',
                ),
                validator: (value) =>
                    value == first.text ? null : 'PINs do not match',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, first.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    first.dispose();
    second.dispose();
    return result;
  }

  Future<void> _setPin({bool changing = false}) async {
    final pin = await _askForPin(title: changing ? 'Change PIN' : 'Create PIN');
    if (pin == null) return;
    setState(() => _securityBusy = true);
    await ref.read(appLockControllerProvider).setPin(pin);
    if (mounted) setState(() => _securityBusy = false);
  }

  Future<void> _disableLock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable app lock?'),
        content: const Text('Budgetly will open without a PIN or biometrics.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _securityBusy = true);
    await ref.read(appLockControllerProvider).disable();
    if (mounted) setState(() => _securityBusy = false);
  }

  Future<void> _toggleBiometrics(bool enabled) async {
    setState(() => _securityBusy = true);
    final ok = await ref
        .read(appLockControllerProvider)
        .setBiometricsEnabled(enabled);
    if (mounted) {
      setState(() => _securityBusy = false);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric unlock is not available or was cancelled'),
          ),
        );
      }
    }
  }

  Future<void> _setLockTimeout(int? seconds) async {
    if (seconds == null) return;
    await ref.read(appLockControllerProvider).setLockTimeoutSeconds(seconds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(activeWalletsProvider);
    final lockState = ref.watch(appLockStateProvider);

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
          if (_demoMode) ...[
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.onErrorContainer,
                ),
                title: Text(
                  'Demo mode is active',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  'You are viewing sample demo data. Reset everything to start fresh with real data.',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _section(theme, 'Notifications', [
            SwitchListTile(
              secondary: Icon(
                Icons.notifications_outlined,
                color: _notifications ? theme.colorScheme.primary : null,
              ),
              title: const Text('Bill Reminders'),
              subtitle: const Text('Alerts for recurring transactions'),
              value: _notifications,
              onChanged: _toggleNotifications,
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Privacy & Security', [
            SwitchListTile(
              secondary: Icon(
                Icons.lock_outline,
                color: lockState.isEnabled ? theme.colorScheme.primary : null,
              ),
              title: const Text('PIN Lock'),
              subtitle: Text(
                lockState.isEnabled
                    ? 'Require a PIN when opening Budgetly'
                    : 'Protect Budgetly with a PIN',
              ),
              value: lockState.isEnabled,
              onChanged: _securityBusy
                  ? null
                  : (value) => value ? _setPin() : _disableLock(),
            ),
            if (lockState.isEnabled) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.pin_outlined),
                title: const Text('Change PIN'),
                subtitle: const Text('Update your Budgetly unlock PIN'),
                onTap: _securityBusy ? null : () => _setPin(changing: true),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: ModernSelectionField<int>(
                  label: 'Lock Timeout',
                  value: lockState.lockTimeoutSeconds,
                  leadingIcon: Icons.lock_clock_outlined,
                  searchEnabled: false,
                  items: _lockTimeoutOptions,
                  onChanged: (value) {
                    if (!_securityBusy) _setLockTimeout(value);
                  },
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(
                  Icons.fingerprint,
                  color: lockState.biometricsEnabled
                      ? theme.colorScheme.primary
                      : null,
                ),
                title: const Text('Biometric Unlock'),
                subtitle: Text(
                  lockState.biometricsAvailable
                      ? 'Use fingerprint, face, or device biometrics like Cashew'
                      : 'No enrolled biometrics found on this device',
                ),
                value: lockState.biometricsEnabled,
                onChanged: _securityBusy || !lockState.biometricsAvailable
                    ? null
                    : _toggleBiometrics,
              ),
            ],
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Account Defaults', [
            ListTile(
              leading: Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Your Name'),
              subtitle: Text(
                _userName == null
                    ? 'Add a name for dashboard greetings'
                    : _userName!,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _editUserName,
            ),
            const Divider(height: 1),
            walletsAsync.when(
              data: (wallets) {
                final hasSelected = wallets.any(
                  (w) => w.id == _defaultWalletId,
                );
                final selectedId = hasSelected ? _defaultWalletId : null;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: ModernSelectionField<int>(
                    label: 'Default Account',
                    value: selectedId,
                    placeholder: 'None',
                    allowClear: true,
                    leadingIcon: Icons.account_balance_wallet_outlined,
                    items: wallets
                        .map(
                          (w) => ModernSelectionItem(
                            value: w.id,
                            title: w.name,
                            subtitle: 'Used for quick transaction add',
                            icon: _walletIcon(w.type),
                            badge: w.currencyCode,
                          ),
                        )
                        .toList(),
                    onChanged: _setDefaultWallet,
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
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: ModernSelectionField<String>(
                label: 'Default Currency',
                value: _displayCurrency,
                leadingIcon: Icons.monetization_on_outlined,
                items:
                    currencyOptionsWithSelection(
                          _favoriteCurrencies,
                          _displayCurrency,
                        )
                        .map(
                          (c) => ModernSelectionItem(
                            value: c,
                            title: c,
                            subtitle: _currencyName(c),
                            icon: Icons.monetization_on_outlined,
                            badge: CurrencyUtils.symbolFor(c),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) _setDisplayCurrency(v);
                },
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: Icon(
                Icons.currency_exchange,
                color: _showDefaultCurrency ? theme.colorScheme.primary : null,
              ),
              title: const Text('Show Default Currency'),
              subtitle: const Text(
                'Show the converted default amount below transaction currency',
              ),
              value: _showDefaultCurrency,
              onChanged: _setShowDefaultCurrency,
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.star_border,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Favorite Currencies'),
              subtitle: Text(
                _favoriteCurrencies.length == CurrencyUtils.codes.length
                    ? 'All currencies shown'
                    : _favoriteCurrencies.join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showFavoriteCurrenciesDialog,
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.currency_exchange,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Exchange Rates'),
              subtitle: const Text('View rates and set custom overrides'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/exchange-rates'),
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Theme', [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: ModernSelectionField<String>(
                label: 'Theme Mode',
                value: _themeMode,
                leadingIcon: Icons.palette_outlined,
                searchEnabled: false,
                items: const [
                  ModernSelectionItem(
                    value: 'system',
                    title: 'System',
                    subtitle: 'Follow device theme',
                    icon: Icons.brightness_auto_outlined,
                  ),
                  ModernSelectionItem(
                    value: 'light',
                    title: 'Light',
                    subtitle: 'Always use light mode',
                    icon: Icons.light_mode_outlined,
                  ),
                  ModernSelectionItem(
                    value: 'dark',
                    title: 'Dark',
                    subtitle: 'Always use dark mode',
                    icon: Icons.dark_mode_outlined,
                  ),
                  ModernSelectionItem(
                    value: 'amoled',
                    title: 'AMOLED',
                    subtitle: 'Pure black dark mode for OLED screens',
                    icon: Icons.contrast_outlined,
                  ),
                ],
                onChanged: (v) {
                  if (v != null) _setThemeMode(v);
                },
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
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 2.5,
                              )
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
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
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Backup & Restore'),
              subtitle: const Text('Export or restore all app data'),
              onTap: () => context.push('/backup'),
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Smart Features', [
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Smart Labels'),
              subtitle: const Text('Auto-categorize transactions by keyword'),
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
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendar'),
              subtitle: const Text(
                'Open a calendar-only view of daily income and outgoing',
              ),
              onTap: () => context.push('/transactions/calendar'),
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('Subscriptions & Scheduled'),
              subtitle: const Text(
                'View recurring outgoing payments and scheduled money movements',
              ),
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
              subtitle: const Text('Savings goals and debt tracking'),
              onTap: () => context.push('/objectives'),
            ),
          ]),
          const SizedBox(height: 8),
          _section(theme, 'Management', [
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Accounts'),
              subtitle: const Text('Manage your wallets and accounts'),
              onTap: () => context.push('/wallets'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              subtitle: const Text('Manage transaction categories'),
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
          const SizedBox(height: 8),
          _section(theme, 'Danger Zone', [
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: theme.colorScheme.error,
              ),
              title: const Text('Reset Everything'),
              subtitle: const Text(
                'Erase all Budgetly data and settings after double confirmation',
              ),
              trailing: _resetBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _resetBusy ? null : _resetEverything,
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
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(child: Column(children: items)),
      ],
    );
  }
}
