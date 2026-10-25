import 'dart:async';

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
  DateTime? _lockedUntil;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAttemptState();
      await _tryBiometrics();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdownIfNeeded() {
    _countdownTimer?.cancel();
    final until = _lockedUntil;
    if (until == null) return;
    final remaining = until.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      setState(() {
        _lockedUntil = null;
        _error = null;
      });
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final rem = _lockedUntil?.difference(DateTime.now()).inSeconds ?? 0;
      if (rem <= 0) {
        timer.cancel();
        setState(() {
          _lockedUntil = null;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Too many attempts. Try again in ${rem + 1}s';
        });
      }
    });
  }

  Future<void> _tryBiometrics() async {
    await ref.read(appLockControllerProvider).authenticateWithBiometrics();
  }

  Future<void> _loadAttemptState() async {
    final attemptState = await ref
        .read(appLockControllerProvider)
        .loadAttemptState();
    if (!mounted) return;
    setState(() {
      _lockedUntil = attemptState.lockedUntil;
    });
    if (_lockedUntil != null) {
      _startCountdownIfNeeded();
    }
  }

  Future<void> _verify() async {
    final now = DateTime.now();
    final lockedUntil = _lockedUntil;
    if (lockedUntil != null && now.isBefore(lockedUntil)) {
      setState(() {
        _error =
            'Too many attempts. Try again in ${lockedUntil.difference(now).inSeconds + 1}s';
      });
      _startCountdownIfNeeded();
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
      _countdownTimer?.cancel();
      await ref.read(appLockControllerProvider).clearAttemptState();
      setState(() {
        _verifying = false;
        _lockedUntil = null;
      });
      return;
    }

    final attemptState = await ref
        .read(appLockControllerProvider)
        .recordFailedAttempt();
    _lockedUntil = attemptState.lockedUntil;
    final until = _lockedUntil;
    setState(() {
      _verifying = false;
      _error = until == null
          ? 'Incorrect PIN'
          : 'Too many attempts. Try again in ${until.difference(DateTime.now()).inSeconds + 1}s';
      _controller.clear();
    });
    if (until != null) {
      _startCountdownIfNeeded();
    }
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
                    'Ledgr is locked',
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
