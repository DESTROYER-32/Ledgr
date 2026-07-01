import 'dart:developer' as developer;

/// Lightweight application logging wrapper.
///
/// Keeps logging dependency-free while avoiding swallowed exceptions. Errors are
/// visible in debug/dev tooling and include stack traces when available.
class AppLogger {
  const AppLogger._();

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'Budgetly',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
