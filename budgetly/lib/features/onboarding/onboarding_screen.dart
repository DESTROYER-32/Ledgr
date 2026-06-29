import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _walletNameController = TextEditingController(text: 'Main Checking');
  final _balanceController = TextEditingController(text: '1250');
  int _currentPage = 0;
  String _selectedCurrency = 'USD';
  String _walletType = 'checking';
  bool _createWallet = true;
  bool _demoMode = false;
  bool _busy = false;

  final _currencies = const [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'INR',
    'BRL',
  ];
  final _walletTypes = const [
    ('checking', 'Checking', Icons.account_balance),
    ('savings', 'Savings', Icons.savings),
    ('cash', 'Cash', Icons.payments),
    ('credit_card', 'Credit Card', Icons.credit_card),
    ('loan', 'Loan', Icons.account_balance_wallet),
  ];

  List<_OnboardingStep> get _steps => const [
    _OnboardingStep(
      icon: Icons.account_balance_wallet,
      title: 'Welcome to Budgetly',
      subtitle:
          'A calmer way to understand money, plan ahead, and keep every account in sync.',
      bullets: [
        'Private by default',
        'Budgets, goals, subscriptions',
        'Multi-wallet tracking',
      ],
      accent: Color(0xFF1A6D4A),
    ),
    _OnboardingStep(
      icon: Icons.auto_graph,
      title: 'See your month at a glance',
      subtitle:
          'Dashboard cards surface balance, cashflow, recent activity, and what needs attention.',
      bullets: ['Income vs expenses', 'Recent transactions', 'Upcoming bills'],
      accent: Color(0xFF1976D2),
    ),
    _OnboardingStep(
      icon: Icons.savings,
      title: 'Plan with budgets and goals',
      subtitle:
          'Create limits for categories, pin important goals, and spot overspending before it hurts.',
      bullets: ['Category limits', 'Savings objectives', 'Pinned priorities'],
      accent: Color(0xFFFF8F00),
    ),
    _OnboardingStep(
      icon: Icons.repeat,
      title: 'Never miss recurring money',
      subtitle:
          'Track rent, subscriptions, paychecks, and transfers as repeating items.',
      bullets: ['Recurring expenses', 'Subscriptions', 'Scheduled income'],
      accent: Color(0xFF8E24AA),
    ),
    _OnboardingStep(
      icon: Icons.query_stats,
      title: 'Understand spending patterns',
      subtitle:
          'Analytics, search, smart labels, and activity history help you find where money goes.',
      bullets: ['Analytics', 'Search', 'Smart labels'],
      accent: Color(0xFFD81B60),
    ),
    _OnboardingStep(
      icon: Icons.waving_hand,
      title: 'What should we call you?',
      subtitle:
          'Add a name for a friendlier dashboard greeting, or skip it if you prefer.',
      accent: Color(0xFF5E35B1),
      custom: _StepCustom.name,
    ),
    _OnboardingStep(
      icon: Icons.currency_exchange,
      title: 'Pick your currency',
      subtitle:
          'Choose the display currency Budgetly should use first. You can add more later.',
      accent: Color(0xFF00897B),
      custom: _StepCustom.currency,
    ),
    _OnboardingStep(
      icon: Icons.account_balance,
      title: 'Create your first account',
      subtitle: 'Start with a wallet, bank account, card, or savings account.',
      accent: Color(0xFF3949AB),
      custom: _StepCustom.wallet,
    ),
    _OnboardingStep(
      icon: Icons.science,
      title: 'Try test mode first',
      subtitle:
          'Not ready to enter real data? Load a Cashew-style demo workspace with realistic dummy data.',
      bullets: [
        'Sample wallets',
        'Budgets and goals',
        'Transactions and subscriptions',
      ],
      accent: Color(0xFF6D4C41),
      custom: _StepCustom.demo,
    ),
    _OnboardingStep(
      icon: Icons.rocket_launch,
      title: 'You are ready',
      subtitle:
          'Budgetly will seed helpful categories and open your dashboard. You can change everything later.',
      bullets: ['Local data', 'Editable setup', 'No account required'],
      accent: Color(0xFF2E7D32),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _walletNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final settings = ref.read(settingsRepositoryProvider);
      await ref.read(categoryRepositoryProvider).seedDefaults();
      final userName = _nameController.text.trim();
      if (userName.isNotEmpty) {
        await settings.set('user_name', userName);
      } else {
        await settings.remove('user_name');
      }
      if (_demoMode) {
        await _DemoDataSeeder(
          ref.read(appDatabaseProvider),
        ).seed(_selectedCurrency);
        await settings.set('budgetly_demo_mode', 'true');
      } else if (_createWallet) {
        final balance = double.tryParse(_balanceController.text.trim()) ?? 0;
        final walletId = await ref
            .read(walletRepositoryProvider)
            .insert(
              WalletsCompanion.insert(
                name: _walletNameController.text.trim().isEmpty
                    ? 'Main Wallet'
                    : _walletNameController.text.trim(),
                type: _walletType,
                currencyCode: _selectedCurrency,
                initialBalanceMinor: (balance * 100).round(),
                sortOrder: const Value(0),
              ),
            );
        await settings.set('default_wallet_id', walletId.toString());
        await settings.set('budgetly_demo_mode', 'false');
      } else {
        await settings.remove('default_wallet_id');
        await settings.set('budgetly_demo_mode', 'false');
      }
      await settings.set('display_currency', _selectedCurrency);
      await settings.completeOnboarding();
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipCurrentStep() {
    final step = _steps[_currentPage];
    switch (step.custom) {
      case _StepCustom.name:
        _nameController.clear();
      case _StepCustom.wallet:
        _createWallet = false;
      case _StepCustom.demo:
        _demoMode = false;
      case _StepCustom.currency:
      case null:
        break;
    }
    if (_currentPage == _steps.length - 1) {
      _completeOnboarding();
    } else {
      setState(() {});
      _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: _ProgressHeader(
                current: _currentPage,
                total: _steps.length,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _steps.length,
                itemBuilder: (context, index) =>
                    _buildStep(theme, _steps[index]),
              ),
            ),
            _buildBottomBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(ThemeData theme, _OnboardingStep step) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 12),
        Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [step.accent, step.accent.withValues(alpha: .55)],
            ),
            boxShadow: [
              BoxShadow(
                color: step.accent.withValues(alpha: .28),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Icon(
                  step.icon,
                  size: 180,
                  color: Colors.white.withValues(alpha: .16),
                ),
              ),
              Center(child: Icon(step.icon, size: 76, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          step.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          step.subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        if (step.custom == _StepCustom.currency) _buildCurrencyPicker(theme),
        if (step.custom == _StepCustom.name) _buildNameStep(theme),
        if (step.custom == _StepCustom.wallet) _buildWalletSetup(theme),
        if (step.custom == _StepCustom.demo) _buildDemoToggle(theme),
        if (step.custom == null)
          ...step.bullets.map(
            (b) => _FeatureBullet(text: b, color: step.accent),
          ),
      ],
    );
  }

  Widget _buildCurrencyPicker(ThemeData theme) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: _currencies.map((currency) {
      final selected = _selectedCurrency == currency;
      return ChoiceChip(
        label: Text(currency),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCurrency = currency),
      );
    }).toList(),
  );

  Widget _buildNameStep(ThemeData theme) => TextField(
    controller: _nameController,
    decoration: const InputDecoration(
      labelText: 'Name',
      hintText: 'Alex',
      helperText: 'Optional. Used only to personalize your home screen.',
      prefixIcon: Icon(Icons.person_outline),
    ),
    textCapitalization: TextCapitalization.words,
    textInputAction: TextInputAction.done,
  );

  Widget _buildWalletSetup(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Create a starter account now'),
        subtitle: const Text('Turn this off to set up accounts later.'),
        value: _createWallet,
        onChanged: (value) => setState(() => _createWallet = value),
      ),
      if (!_createWallet)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'No problem. Budgetly will still save your currency and open the dashboard.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      if (_createWallet) ...[
        TextField(
          controller: _walletNameController,
          decoration: const InputDecoration(
            labelText: 'Account name',
            hintText: 'Main Checking',
          ),
        ),
        const SizedBox(height: 16),
        Text('Account type', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _walletTypes
              .map(
                (wt) => ChoiceChip(
                  label: Text(wt.$2),
                  avatar: Icon(wt.$3, size: 18),
                  selected: _walletType == wt.$1,
                  onSelected: (_) => setState(() => _walletType = wt.$1),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _balanceController,
          decoration: InputDecoration(
            labelText: 'Current balance',
            hintText: '0.00',
            prefixText: '$_selectedCurrency ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    ],
  );

  Widget _buildDemoToggle(ThemeData theme) => Column(
    children: [
      _ModeCard(
        selected: !_demoMode,
        icon: Icons.edit_note,
        title: 'Use my own data',
        subtitle:
            'Create one starter account and begin from a clean workspace.',
        onTap: () => setState(() => _demoMode = false),
      ),
      const SizedBox(height: 12),
      _ModeCard(
        selected: _demoMode,
        icon: Icons.auto_awesome,
        title: 'Use test mode with dummy data',
        subtitle:
            'Explore Budgetly instantly with sample accounts, budgets, goals, and transactions.',
        onTap: () => setState(() => _demoMode = true),
      ),
    ],
  );

  Widget _buildBottomBar(ThemeData theme) {
    final isLast = _currentPage == _steps.length - 1;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          TextButton(
            onPressed: _currentPage == 0 || _busy
                ? null
                : () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                  ),
            child: const Text('Back'),
          ),
          const Spacer(),
          TextButton(
            onPressed: _busy ? null : _skipCurrentStep,
            child: Text(isLast ? 'Skip and finish' : 'Skip'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _busy ? null : (isLast ? _completeOnboarding : _next),
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isLast ? Icons.check : Icons.arrow_forward),
            label: Text(
              isLast ? (_demoMode ? 'Open demo' : 'Get started') : 'Next',
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepCustom { name, currency, wallet, demo }

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final Color accent;
  final _StepCustom? custom;
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.bullets = const [],
    required this.accent,
    this.custom,
  });
}

class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressHeader({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: LinearProgressIndicator(
          value: (current + 1) / total,
          minHeight: 8,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        '${current + 1}/$total',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    ],
  );
}

class _FeatureBullet extends StatelessWidget {
  final String text;
  final Color color;
  const _FeatureBullet({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: color.withValues(alpha: .14),
          child: Icon(Icons.check, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    ),
  );
}

class _ModeCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: selected ? 3 : 0,
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoDataSeeder {
  final AppDatabase _db;
  _DemoDataSeeder(this._db);

  Future<void> seed(String currency) async {
    final existing = await _db.wallets.select().get();
    if (existing.isNotEmpty) return;

    final checkingId = await _db
        .into(_db.wallets)
        .insert(
          WalletsCompanion.insert(
            name: 'Demo Checking',
            type: 'checking',
            currencyCode: currency,
            initialBalanceMinor: 248500,
            sortOrder: const Value(0),
            color: const Value(0xFF1A6D4A),
            icon: const Value('account_balance'),
          ),
        );
    final savingsId = await _db
        .into(_db.wallets)
        .insert(
          WalletsCompanion.insert(
            name: 'Emergency Savings',
            type: 'savings',
            currencyCode: currency,
            initialBalanceMinor: 520000,
            sortOrder: const Value(1),
            color: const Value(0xFF1976D2),
            icon: const Value('savings'),
          ),
        );
    final cashId = await _db
        .into(_db.wallets)
        .insert(
          WalletsCompanion.insert(
            name: 'Cash Wallet',
            type: 'cash',
            currencyCode: currency,
            initialBalanceMinor: 8600,
            sortOrder: const Value(2),
            color: const Value(0xFFFF8F00),
            icon: const Value('payments'),
          ),
        );

    final cats = {
      for (final c in await _db.categories.select().get()) c.name: c.id,
    };
    int? cat(String name) => cats[name];
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59);

    final budgetId = await _db
        .into(_db.budgets)
        .insert(
          BudgetsCompanion.insert(
            name: 'Demo Monthly Budget',
            periodStart: monthStart,
            periodEnd: monthEnd,
            currencyCode: currency,
            plannedAmountMinor: const Value(260000),
            pinned: const Value(true),
            color: const Value(0xFF1A6D4A),
          ),
        );
    await _db
        .into(_db.budgetWallets)
        .insert(
          BudgetWalletsCompanion.insert(
            budgetId: budgetId,
            walletId: checkingId,
          ),
        );
    for (final item in [
      ('Groceries', 52000),
      ('Dining Out', 24000),
      ('Transport', 18000),
      ('Entertainment', 16000),
      ('Subscriptions', 4500),
    ]) {
      final id = cat(item.$1);
      if (id != null) {
        await _db
            .into(_db.budgetCategoryLimits)
            .insert(
              BudgetCategoryLimitsCompanion.insert(
                budgetId: budgetId,
                categoryId: id,
                plannedAmountMinor: item.$2,
              ),
            );
      }
    }

    await _db
        .into(_db.objectives)
        .insert(
          ObjectivesCompanion.insert(
            name: 'Vacation fund',
            type: 'goal',
            amountMinor: 200000,
            walletId: Value(savingsId),
            currencyCode: currency,
            deadline: Value(now.add(const Duration(days: 160))),
            pinned: const Value(true),
            color: const Value(0xFF00ACC1),
            icon: const Value('flight_takeoff'),
          ),
        );
    await _db
        .into(_db.objectives)
        .insert(
          ObjectivesCompanion.insert(
            name: 'Pay down credit card',
            type: 'debt',
            amountMinor: 85000,
            walletId: Value(checkingId),
            currencyCode: currency,
            deadline: Value(now.add(const Duration(days: 90))),
            color: const Value(0xFFD81B60),
            icon: const Value('credit_card'),
          ),
        );

    Future<void> txOn(
      String type,
      int amount,
      int wallet,
      int? category,
      String title,
      DateTime date, {
      int? transferWallet,
      String specialType = 'none',
    }) async {
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: type,
              specialType: Value(specialType),
              amountMinor: amount,
              currencyCode: currency,
              date: date,
              walletId: wallet,
              transferWalletId: Value(transferWallet),
              categoryId: Value(category),
              title: Value(title),
              methodAdded: const Value('demo'),
            ),
          );
    }

    Future<void> tx(
      String type,
      int amount,
      int wallet,
      int? category,
      String title,
      int daysAgo, {
      int? transferWallet,
      String specialType = 'none',
    }) async {
      await txOn(
        type,
        amount,
        wallet,
        category,
        title,
        now.subtract(Duration(days: daysAgo)),
        transferWallet: transferWallet,
        specialType: specialType,
      );
    }

    await tx('income', 420000, checkingId, cat('Salary'), 'Paycheck', 5);
    await tx('expense', 145000, checkingId, cat('Rent'), 'Apartment rent', 3);
    await tx('expense', 8420, checkingId, cat('Groceries'), 'Fresh Market', 2);
    await tx('expense', 3260, checkingId, cat('Dining Out'), 'Noodle Bar', 1);
    await tx('expense', 1850, cashId, cat('Transport'), 'Metro card', 4);
    await tx('expense', 1299, checkingId, cat('Subscriptions'), 'StreamBox', 7);
    await tx('expense', 2440, checkingId, cat('Health'), 'Pharmacy', 8);
    await tx(
      'transfer',
      35000,
      checkingId,
      null,
      'Move to savings',
      6,
      transferWallet: savingsId,
    );
    await tx(
      'income',
      65000,
      checkingId,
      cat('Freelance'),
      'Design project',
      12,
    );
    await tx('expense', 7590, checkingId, cat('Shopping'), 'New shoes', 10);

    for (final offset in [1, 2]) {
      await txOn(
        'income',
        420000,
        checkingId,
        cat('Salary'),
        'Paycheck',
        DateTime(now.year, now.month - offset, 5),
      );
      await txOn(
        'expense',
        145000,
        checkingId,
        cat('Rent'),
        'Apartment rent',
        DateTime(now.year, now.month - offset, 1),
      );
      await txOn(
        'expense',
        offset == 1 ? 23870 : 18450,
        checkingId,
        cat('Groceries'),
        offset == 1 ? 'Monthly groceries' : 'SuperMart',
        DateTime(now.year, now.month - offset, offset == 1 ? 12 : 9),
      );
      await txOn(
        'expense',
        offset == 1 ? 9600 : 6200,
        offset == 1 ? checkingId : cashId,
        offset == 1 ? cat('Entertainment') : cat('Transport'),
        offset == 1 ? 'Movie night' : 'Fuel refill',
        DateTime(now.year, now.month - offset, offset == 1 ? 18 : 16),
      );
    }

    await txOn(
      'expense',
      4100,
      cashId,
      cat('Dining Out'),
      'Coffee catchups',
      DateTime(now.year, now.month - 1, 22),
    );
    await txOn(
      'expense',
      145000,
      checkingId,
      cat('Rent'),
      'Scheduled rent',
      DateTime(now.year, now.month + 1, 1),
      specialType: 'upcoming',
    );
    await txOn(
      'income',
      420000,
      checkingId,
      cat('Salary'),
      'Scheduled paycheck',
      DateTime(now.year, now.month + 1, 5),
      specialType: 'upcoming',
    );
    await txOn(
      'expense',
      1299,
      checkingId,
      cat('Subscriptions'),
      'StreamBox subscription',
      DateTime(now.year, now.month + 1, 7),
      specialType: 'subscription',
    );
    await txOn(
      'expense',
      999,
      checkingId,
      cat('Subscriptions'),
      'Cloud backup subscription',
      DateTime(now.year, now.month + 2, 14),
      specialType: 'subscription',
    );

    await _db
        .into(_db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            transactionType: 'expense',
            amountMinor: 145000,
            walletId: checkingId,
            categoryId: Value(cat('Rent')),
            title: const Value('Rent'),
            scheduleRule: 'monthly',
            startDate: monthStart,
            nextDueDate: Value(DateTime(now.year, now.month + 1, 1)),
          ),
        );
    await _db
        .into(_db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            transactionType: 'income',
            amountMinor: 420000,
            walletId: checkingId,
            categoryId: Value(cat('Salary')),
            title: const Value('Paycheck'),
            scheduleRule: 'monthly',
            startDate: monthStart,
            nextDueDate: Value(DateTime(now.year, now.month + 1, 5)),
          ),
        );

    await _db
        .into(_db.associatedTitles)
        .insert(
          AssociatedTitlesCompanion.insert(
            title: 'Fresh Market',
            categoryId: cat('Groceries') ?? cats.values.first,
          ),
        );
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'default_wallet_id',
            value: checkingId.toString(),
          ),
        );
  }
}
