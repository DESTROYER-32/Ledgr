import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/database/repositories/settings_repository.dart';
import 'core/router/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  final db = AppDatabase();
  final settingsRepo = SettingsRepository(db);
  final onboarded = await settingsRepo.isOnboardingComplete();
  final appLock = await settingsRepo.get('app_lock');

  if (appLock == 'true' && onboarded) {
    final authed = await AuthService.authenticate();
    if (!authed) {
      return;
    }
  }

  await db.close();

  runApp(
    ProviderScope(
      child: BudgetlyApp(
        initialRoute: onboarded ? '/' : '/onboarding',
      ),
    ),
  );
}

class BudgetlyApp extends ConsumerWidget {
  final String initialRoute;

  const BudgetlyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Budgetly',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
