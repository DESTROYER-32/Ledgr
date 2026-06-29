import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _verifying = false;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _tryBiometrics() async {
    await ref.read(appLockControllerProvider).authenticateWithBiometrics();
  }

  Future<void> _verify() async {
    final now = DateTime.now();
    final lockedUntil = _lockedUntil;
    if (lockedUntil != null && now.isBefore(lockedUntil)) {
      setState(() {
        _error =
            'Too many attempts. Try again in ${lockedUntil.difference(now).inSeconds + 1}s';
      });
      return;
    }
    if (_verifying) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    final ok = await ref
        .read(appLockControllerProvider)
        .verifyPin(_controller.text);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _verifying = false;
        _failedAttempts = 0;
        _lockedUntil = null;
      });
      return;
    }

    _failedAttempts++;
    if (_failedAttempts >= 5) {
      final delaySeconds = (_failedAttempts - 4).clamp(1, 6) * 5;
      _lockedUntil = DateTime.now().add(Duration(seconds: delaySeconds));
    }

    final until = _lockedUntil;
    setState(() {
      _verifying = false;
      _error = until == null
          ? 'Incorrect PIN'
          : 'Too many attempts. Try again in ${until.difference(DateTime.now()).inSeconds + 1}s';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appLockStateProvider);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Budgetly is locked',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your PIN to continue',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      errorText: _error,
                      counterText: '',
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _verify(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _verifying ? null : _verify,
                      child: _verifying
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Unlock'),
                    ),
                  ),
                  if (state.biometricsEnabled) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _tryBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Use biometrics'),
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
