import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Widget? bottom;
  final List<Widget>? actions;
  final Color? accentColor;

  const BalanceCard({
    super.key,
    required this.label,
    required this.amount,
    this.icon = Icons.account_balance_wallet,
    this.bottom,
    this.actions,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = accentColor ?? cs.primary;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.08),
              accent.withValues(alpha: 0.02),
              cs.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Text(label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    )),
                const Spacer(),
                ...?actions,
              ],
            ),
            const SizedBox(height: 16),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: (theme.textTheme.headlineLarge ??
                      theme.textTheme.headlineMedium ??
                      const TextStyle())
                  .copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
                height: 1.1,
              ),
              child: Text(amount),
            ),
            if (bottom != null) ...[
              const SizedBox(height: 16),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }
}
