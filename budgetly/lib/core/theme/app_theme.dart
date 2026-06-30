import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _defaultSeed = Color(0xFF1A6D4A);

  static ThemeData light({Color? seedOverride}) {
    final seed = seedOverride ?? _defaultSeed;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xFFF8FAF9),
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData dark({Color? seedOverride}) {
    final seed = seedOverride ?? _defaultSeed;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData amoled({Color? seedOverride}) {
    final seed = seedOverride ?? _defaultSeed;
    final colorScheme = ColorScheme.dark(
      primary: seed,
      onPrimary: Colors.white,
      primaryContainer: _darken(seed, .35),
      onPrimaryContainer: Colors.white,
      secondary: _soften(seed),
      onSecondary: Colors.white,
      secondaryContainer: _darken(seed, .45),
      onSecondaryContainer: Colors.white,
      tertiary: _rotateHue(seed, 45),
      onTertiary: Colors.white,
      tertiaryContainer: _darken(_rotateHue(seed, 45), .45),
      onTertiaryContainer: Colors.white,
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: Colors.black,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFE0E0E0),
      outline: const Color(0xFF8A8A8A),
      surfaceDim: Colors.black,
      surfaceBright: const Color(0xFF121212),
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: Colors.black,
      surfaceContainer: Colors.black,
      surfaceContainerHigh: const Color(0xFF080808),
      surfaceContainerHighest: const Color(0xFF101010),
      outlineVariant: const Color(0xFF2A2A2A),
      shadow: Colors.black,
      scrim: Colors.black,
    );
    return _buildTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
    );
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * (1 - amount)).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _soften(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation((hsl.saturation * .72).clamp(0.0, 1.0)).toColor();
  }

  static Color _rotateHue(Color color, double degrees) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withHue((hsl.hue + degrees) % 360).toColor();
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
        indicatorColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 0.5,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class AppColors {
  AppColors._();

  static const expense = Color(0xFFE53935);
  static const income = Color(0xFF43A047);
  static const transfer = Color(0xFF1E88E5);

  static Color expenseSoft(ColorScheme cs) => cs.errorContainer;
  static Color incomeSoft(ColorScheme cs) => cs.primaryContainer;
  static Color transferSoft(ColorScheme cs) => cs.secondaryContainer;

  static Color expenseContainer(ColorScheme cs) => cs.errorContainer;
  static Color incomeContainer(ColorScheme cs) => cs.primaryContainer;

  static Color fromStored(int? value, Color fallback) {
    if (value == null) return fallback;
    final color = Color(value);
    return color.a == 0 ? fallback : color;
  }

  static const categoryColors = [
    Color(0xFFE53935),
    Color(0xFFFF8F00),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF00ACC1),
    Color(0xFF1E88E5),
    Color(0xFF5E35B1),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
    Color(0xFFFF7043),
    Color(0xFF8BC34A),
    Color(0xFF00897B),
    Color(0xFFC0CA33),
    Color(0xFF3949AB),
    Color(0xFFAD1457),
    Color(0xFF7CB342),
    Color(0xFF039BE5),
    Color(0xFF8D6E63),
    Color(0xFF6A1B9A),
    Color(0xFFFFB300),
    Color(0xFF00838F),
    Color(0xFFE64A19),
    Color(0xFF455A64),
  ];
}
