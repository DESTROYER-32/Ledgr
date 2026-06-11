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
  int _currentPage = 0;
  String _selectedCurrency = 'USD';
  final _walletNameController = TextEditingController();
  String _walletType = 'checking';
  final _balanceController = TextEditingController();

  final _currencies = [
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

  final _walletTypes = [
    ('checking', 'Checking', Icons.account_balance),
    ('savings', 'Savings', Icons.savings),
    ('cash', 'Cash', Icons.money),
    ('credit_card', 'Credit Card', Icons.credit_card),
    ('loan', 'Loan', Icons.account_balance_wallet),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _walletNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final walletRepo = ref.read(walletRepositoryProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);

    await categoryRepo.seedDefaults();

    final balance = _balanceController.text.isEmpty
        ? 0
        : (double.tryParse(_balanceController.text) ?? 0);
    await walletRepo.insert(
      WalletsCompanion.insert(
        name: _walletNameController.text.isEmpty
            ? 'Main Wallet'
            : _walletNameController.text,
        type: _walletType,
        currencyCode: _selectedCurrency,
        initialBalanceMinor: (balance * 100).round(),
      ),
    );

    await ref
        .read(settingsRepositoryProvider)
        .set('display_currency', _selectedCurrency);
    await ref.read(settingsRepositoryProvider).completeOnboarding();

    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [_buildWelcomeStep(theme), _buildWalletStep(theme)],
              ),
            ),
            _buildBottomBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Budgetly',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Track your spending, stay on budget, and reach your financial goals.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Text('Select your currency', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: _currencies.length,
              itemBuilder: (context, i) {
                final currency = _currencies[i];
                final selected = _selectedCurrency == currency;
                return Material(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedCurrency = currency),
                    child: Center(
                      child: Text(
                        currency,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? theme.colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildWalletStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Icon(
            Icons.account_balance,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Create your first account',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set up a wallet or account to start tracking.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _walletNameController,
            decoration: const InputDecoration(
              labelText: 'Account name',
              hintText: 'e.g. Main Checking',
            ),
          ),
          const SizedBox(height: 16),
          Text('Account type', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _walletTypes.map((wt) {
              final selected = _walletType == wt.$1;
              return ChoiceChip(
                label: Text(wt.$2),
                selected: selected,
                avatar: Icon(wt.$3, size: 18),
                onSelected: (_) => setState(() => _walletType = wt.$1),
              );
            }).toList(),
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
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text('Back'),
            )
          else
            const SizedBox(),
          const Spacer(),
          if (_currentPage < 1)
            FilledButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text('Next'),
            )
          else
            FilledButton(
              onPressed: _completeOnboarding,
              child: const Text('Get Started'),
            ),
        ],
      ),
    );
  }
}
