import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/database/repositories/settings_repository.dart';
import 'l10n/app_localizations.dart';
import 'core/providers/providers.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'features/security/app_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService.init();
  } catch (error, stackTrace) {
    // Notifications are optional; startup should continue if the platform
    // plugin is unavailable or initialization fails.
    AppLogger.warning(
      'Notification initialization failed; continuing without notifications',
      error: error,
      stackTrace: stackTrace,
    );
  }

  final db = AppDatabase();
  final settingsRepo = SettingsRepository(db);
  final onboarded = await settingsRepo.isOnboardingComplete();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          ref.onDispose(db.close);
          return db;
        }),
        initialRouteProvider.overrideWithValue(onboarded ? '/' : '/onboarding'),
      ],
      child: LedgrApp(initialRoute: onboarded ? '/' : '/onboarding'),
    ),
  );
}

class LedgrApp extends ConsumerStatefulWidget {
  final String initialRoute;

  const LedgrApp({super.key, required this.initialRoute});

  @override
  ConsumerState<LedgrApp> createState() => _LedgrAppState();
}

class _LedgrAppState extends ConsumerState<LedgrApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(recurringServiceProvider).processDueRecurrings();
      ref.read(backupServiceProvider).runScheduledBackupIfDue();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(backupServiceProvider).runScheduledBackupIfDue();
      ref.read(appLockControllerProvider).handleAppResumed();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(appLockControllerProvider).markAppLeft();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeAsync = ref.watch(themeConfigProvider);
    return themeAsync.when(
      data: (config) => MaterialApp.router(
        title: 'Ledgr',
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(seedOverride: config.seedColor),
        darkTheme: config.amoled
            ? AppTheme.amoled(seedOverride: config.seedColor)
            : AppTheme.dark(seedOverride: config.seedColor),
        themeMode: config.themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final lockState = ref.watch(appLockStateProvider);
          if (lockState.isLoading) {
            return const Scaffold(body: SizedBox.shrink());
          }
          if (lockState.isLocked) return const AppLockScreen();
          return child ?? const SizedBox.shrink();
        },
      ),
      error: (_, _) => MaterialApp.router(
        title: 'Ledgr',
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => MaterialApp.router(
        title: 'Ledgr',
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
