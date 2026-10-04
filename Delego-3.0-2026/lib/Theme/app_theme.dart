import 'package:flutter/material.dart';
import 'design_tokens.dart';

// Kept for anything that still imports kBrandSeed directly.
const kBrandSeed = AppColors.violet;

ThemeData getDarkTheme() {
  final scheme = ColorScheme.dark(
    primary: AppColors.hotPink,
    onPrimary: Colors.white,
    secondary: AppColors.violet,
    onSecondary: Colors.white,
    tertiary: AppColors.gold,
    surface: AppColors.darkVoid,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceRaised,
    onSurfaceVariant: AppColors.darkTextSecondary,
    primaryContainer: const Color(0xFF32123F),
    onPrimaryContainer: Colors.white,
    secondaryContainer: AppColors.darkSurface,
    onSecondaryContainer: AppColors.darkTextSecondary,
    outlineVariant: const Color(0x1FFFFFFF),
    error: AppColors.error,
    shadow: Colors.black,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: AppType.textTheme(scheme.onSurface, scheme.onSurfaceVariant),
    extensions: [
      const AppTokens(success: AppColors.success, warning: AppColors.gold)
    ],
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.darkSurfaceRaised,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      hoverColor: const Color(0xFF2A0050),
    ),
  );
}

/// The light counterpart — same violet/hot-pink/gold identity, near-white
/// surfaces and dark ink text instead of the void/white pairing. Opt-in
/// from Profile; dark stays the default everywhere else.
ThemeData getLightTheme() {
  final scheme = ColorScheme.light(
    primary: AppColors.hotPink,
    onPrimary: Colors.white,
    secondary: AppColors.violet,
    onSecondary: Colors.white,
    tertiary: AppColors.goldDeep,
    surface: AppColors.lightVoid,
    onSurface: AppColors.lightTextPrimary,
    surfaceContainerHighest: AppColors.lightSurfaceRaised,
    onSurfaceVariant: AppColors.lightTextSecondary,
    primaryContainer: const Color(0xFFFCD9EE),
    onPrimaryContainer: const Color(0xFF4A0F33),
    secondaryContainer: AppColors.lightSurface,
    onSecondaryContainer: AppColors.lightTextSecondary,
    outlineVariant: const Color(0x1F17151F),
    error: AppColors.error,
    shadow: Colors.black,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: AppType.textTheme(scheme.onSurface, scheme.onSurfaceVariant),
    extensions: [
      const AppTokens(success: AppColors.success, warning: AppColors.goldDeep)
    ],
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.lightSurfaceRaised,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      hoverColor: const Color(0xFFF0E6FA),
    ),
  );
}

class AppTokens extends ThemeExtension<AppTokens> {
  final Color success;
  final Color warning;

  const AppTokens({required this.success, required this.warning});

  @override
  AppTokens copyWith({Color? success, Color? warning}) =>
      AppTokens(success: success ?? this.success, warning: warning ?? this.warning);

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
