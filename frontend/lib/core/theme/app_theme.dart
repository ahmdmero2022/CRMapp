import 'package:flutter/material.dart';

/// Spacing scale used across the app instead of ad-hoc [EdgeInsets] values —
/// screen padding is [lg], card padding [md], gaps between related elements
/// [sm]/[md].
class AppSpacing {
  const AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Corner-radius scale mirroring the values already hardcoded in [AppTheme]'s
/// component themes (cards, dialogs, inputs) so new widgets can match them.
class AppRadius {
  const AppRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 18.0;
  static const xl = 20.0;
}

/// Central design tokens + ThemeData for the CRM. Material 3 built on a
/// single-hue blue ramp for a calm, elegant, data-heavy business look
/// (tighter paddings, card-based surfaces) rather than a typical mobile app.
class AppTheme {
  // Blue ramp — the app's one accent hue, used for brand, nav, charts and
  // gradients so every "colored" surface reads as a deliberate shade of blue.
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue300 = Color(0xFF93C5FD);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue800 = Color(0xFF1E40AF);
  static const blue900 = Color(0xFF1E3A8A);

  static const seed = blue600;

  // Semantic colors keep their conventional meaning (positive/caution/
  // negative); "info" is a distinct blue tone so it still reads as part of
  // the same family instead of clashing with it.
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = blue400;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  /// Two-tone brand gradient used on hero/auth surfaces.
  static LinearGradient heroGradient(Brightness brightness) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: brightness == Brightness.light
            ? [blue800, blue500]
            : [blue900, blue700],
      );

  static ThemeData _base(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor:
          isLight ? const Color(0xFFF5F8FF) : const Color(0xFF0A0F1E),
      textTheme: ThemeData(brightness: scheme.brightness)
          .textTheme
          .apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
            fontFamilyFallback: const ['NotoSansArabic'],
          )
          .copyWith(
            headlineMedium: const TextStyle(
                fontWeight: FontWeight.w700, letterSpacing: -0.4),
            headlineSmall: const TextStyle(
                fontWeight: FontWeight.w700, letterSpacing: -0.2),
            titleLarge:
                const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
            titleMedium: const TextStyle(fontWeight: FontWeight.w600),
          ),
      cardTheme: CardTheme(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isLight
                ? blue900.withOpacity(0.06)
                : blue100.withOpacity(0.08),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: blue900.withOpacity(0.15),
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: isLight ? blue100 : blue800.withOpacity(0.45),
        indicatorShape: const StadiumBorder(),
        selectedIconTheme: IconThemeData(color: isLight ? blue700 : blue200),
        selectedLabelTextStyle: TextStyle(
          color: isLight ? blue700 : blue200,
          fontWeight: FontWeight.w600,
        ),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isLight ? blue100 : blue800.withOpacity(0.45),
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? (isLight ? blue700 : blue200)
                : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? (isLight ? blue700 : blue200)
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? blue900.withOpacity(0.035)
            : scheme.surfaceContainerHighest.withOpacity(0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? blue900.withOpacity(0.05)
            : scheme.surfaceContainerHighest.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: isLight ? blue900.withOpacity(0.08) : blue100.withOpacity(0.1),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? blue900 : blue700,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  static Color stageColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return danger;
      case 'low':
        return info;
      default:
        return warning;
    }
  }
}
