import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (!mounted || _isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final success = await ref
        .read(appLockControllerProvider)
        .authenticate(reason: 'Unlock Ledgr');

    if (!mounted) return;
    setState(() {
      _isAuthenticating = false;
      if (!success) {
        _errorMessage = 'Authentication was cancelled or failed. Tap to retry.';
      }
    });
  }

  Future<void> _handleEmergencyDisable() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable App Lock?'),
        content: const Text(
          'Device lock is not detected on this device. Do you want to disable App Lock so you can access Ledgr?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disable Lock'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(appLockControllerProvider).disableWithoutAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appLockStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      size: 56,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ledgr is locked',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isDeviceSupported
                        ? 'Unlock with your ${state.lockTypeDescription}'
                        : 'Device lock is not detected on this device',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (state.isDeviceSupported) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isAuthenticating ? null : _authenticate,
                        icon: _isAuthenticating
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.lock_open_rounded),
                        label: Text(
                          _isAuthenticating
                              ? 'Authenticating...'
                              : 'Unlock Ledgr',
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.tonalIcon(
                        onPressed: _handleEmergencyDisable,
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: const Text('Disable App Lock'),
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
