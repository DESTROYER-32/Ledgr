import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/database/repositories/settings_repository.dart';
import 'core/providers/providers.dart';
import 'core/router/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/money_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  final db = AppDatabase();
  final settingsRepo = SettingsRepository(db);
  final onboarded = await settingsRepo.isOnboardingComplete();
  final currency = await settingsRepo.get('currency');
  MoneyUtils.setDefaultCurrencyCode(currency ?? 'USD');

  await db.close();

  runApp(
    ProviderScope(
      child: BudgetlyApp(
        initialRoute: onboarded ? '/' : '/onboarding',
      ),
    ),
  );
}

class BudgetlyApp extends ConsumerStatefulWidget {
  final String initialRoute;

  const BudgetlyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  ConsumerState<BudgetlyApp> createState() => _BudgetlyAppState();
}

class _BudgetlyAppState extends ConsumerState<BudgetlyApp>
    with WidgetsBindingObserver {
  AppLifecycleListener? _lifecycleListener;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _onResume() async {
    if (_locked) return;
    final repo = ref.read(settingsRepositoryProvider);
    final appLock = await repo.get('app_lock');
    if (appLock == 'true') {
      _locked = true;
      final authed = await AuthService.authenticate();
      _locked = false;
      if (!authed && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeAsync = ref.watch(themeConfigProvider);
    return themeAsync.when(
      data: (config) => MaterialApp.router(
        title: 'Budgetly',
        theme: AppTheme.light(seedOverride: config.seedColor),
        darkTheme: AppTheme.dark(seedOverride: config.seedColor),
        themeMode: config.themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
      error: (_, _) => MaterialApp.router(
        title: 'Budgetly',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => MaterialApp.router(
        title: 'Budgetly',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
