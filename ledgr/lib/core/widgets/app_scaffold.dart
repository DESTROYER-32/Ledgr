import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/budgets')) return 1;
    if (location.startsWith('/wallets')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/');
      case 1: context.go('/budgets');
      case 2: context.go('/wallets');
      case 3: context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final index = _currentIndex(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          child,
          Positioned(
            right: 16,
            bottom: 68 + bottomPadding + 4,
            child: SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                heroTag: 'shell_fab',
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                onPressed: () => _showQuickEntry(context),
                child: const Icon(Icons.add, size: 30),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _onTap(context, i),
        height: 68,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: cs.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes, color: cs.primary),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: cs.primary),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: cs.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showQuickEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => _QuickEntrySheet(rootNavigator: context),
    );
  }
}

class _QuickEntrySheet extends StatefulWidget {
  final BuildContext rootNavigator;
  const _QuickEntrySheet({required this.rootNavigator});

  @override
  State<_QuickEntrySheet> createState() => _QuickEntrySheetState();
}

class _QuickEntrySheetState extends State<_QuickEntrySheet> {
  String _type = 'expense';

  void _navigateToForm() {
    Navigator.pop(context);
    widget.rootNavigator.push('/transactions/new',
        extra: <String, dynamic>{'type': _type});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text('Quick Add Transaction',
              style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 20),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
              ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.arrow_downward)),
              ButtonSegment(value: 'transfer', label: Text('Transfer'), icon: Icon(Icons.swap_horiz)),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _navigateToForm,
            icon: const Icon(Icons.add),
            label: const Text('Continue'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _navigateToForm,
            child: const Text('Open Full Form'),
          ),
        ],
      ),
    );
  }
}
