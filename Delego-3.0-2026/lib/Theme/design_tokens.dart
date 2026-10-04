import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mumbai MUN 2026 design language: near-black void, a violet→hot-pink
/// gradient carried over from the Gateway of India mark, and a warm gold
/// accent for emphasis (countdowns, highlights, active states).
class AppColors {
  AppColors._();

  /// Flipped by [ThemeController] (via main.dart) whenever the active
  /// theme changes. Every surface/text token below reads this instead of
  /// threading BuildContext through the many CustomPainters and shared
  /// widgets that reference AppColors directly — the tradeoff is a
  /// mutable global, kept only for this one flag. Dark is the default —
  /// Mumbai MUN's identity is a near-black void unless the user opts into
  /// light mode from Profile.
  static bool isLight = false;

  // Surfaces — dark ("void", the default/brand look) and light variants.
  static const darkVoid = Color(0xFF0A0910);
  static const darkSurface = Color(0xFF141220);
  static const darkSurfaceRaised = Color(0xFF1C1A2A);

  static const lightVoid = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceRaised = Color(0xFFF2F1F5);

  static Color get void_ => isLight ? lightVoid : darkVoid;
  static Color get surface => isLight ? lightSurface : darkSurface;
  static Color get surfaceRaised => isLight ? lightSurfaceRaised : darkSurfaceRaised;

  // Brand — the violet→hot-pink→gold identity doesn't change with theme.
  static const violet = Color(0xFF7B2FF7);
  static const magenta = Color(0xFFE0299E);
  static const hotPink = Color(0xFFFF2E9A);
  static const gold = Color(0xFFFFD60A);
  static const goldDeep = Color(0xFFFFB300);

  // Text
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFAFA9C2);
  static const darkTextTertiary = Color(0xFF716C87);

  static const lightTextPrimary = Color(0xFF17151F);
  static const lightTextSecondary = Color(0xFF5C5770);
  static const lightTextTertiary = Color(0xFF938DAA);

  static Color get textPrimary => isLight ? lightTextPrimary : darkTextPrimary;
  static Color get textSecondary => isLight ? lightTextSecondary : darkTextSecondary;
  static Color get textTertiary => isLight ? lightTextTertiary : darkTextTertiary;

  // Status
  static const success = Color(0xFF34D399);
  static const error = Color(0xFFFF4D6D);

  static Color get hairline =>
      isLight ? const Color(0x1F17151F) : const Color(0x1FFFFFFF);
}

class AppGradients {
  AppGradients._();

  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.violet, AppColors.hotPink],
  );

  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gold, AppColors.goldDeep],
  );

  static LinearGradient get heroBackdrop => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.isLight ? const Color(0xFFEDE6FA) : const Color(0xFF2A1250),
          AppColors.void_,
        ],
      );
}

class AppRadii {
  AppRadii._();
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

class AppSpacing {
  AppSpacing._();
  static const xs = 6.0;
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 28.0;
  static const xl = 40.0;
}

/// Display type rides on Space Grotesk (bold, geometric, great for big
/// numerals like the countdown); UI/body copy rides on Inter for clean,
/// system-grade legibility.
class AppType {
  AppType._();

  static TextTheme textTheme(Color base, Color muted) {
    final display = GoogleFonts.spaceGroteskTextTheme();
    final body = GoogleFonts.interTextTheme();

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
          color: base, fontWeight: FontWeight.w700, letterSpacing: -1.5),
      displayMedium: display.displayMedium?.copyWith(
          color: base, fontWeight: FontWeight.w700, letterSpacing: -1),
      headlineLarge: display.headlineLarge?.copyWith(
          color: base, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: display.headlineMedium?.copyWith(
          color: base, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: display.headlineSmall
          ?.copyWith(color: base, fontWeight: FontWeight.w700),
      titleLarge: display.titleLarge
          ?.copyWith(color: base, fontWeight: FontWeight.w600),
      titleMedium: body.titleMedium
          ?.copyWith(color: base, fontWeight: FontWeight.w600),
      titleSmall: body.titleSmall
          ?.copyWith(color: base, fontWeight: FontWeight.w600),
      bodyLarge: body.bodyLarge?.copyWith(color: base),
      bodyMedium: body.bodyMedium?.copyWith(color: muted),
      bodySmall: body.bodySmall?.copyWith(color: muted),
      labelLarge: body.labelLarge
          ?.copyWith(color: base, fontWeight: FontWeight.w600),
      labelMedium: body.labelMedium?.copyWith(color: muted),
      labelSmall: body.labelSmall?.copyWith(color: muted, letterSpacing: 0.8),
    );
  }

  /// Eyebrow / kicker style — small tracked uppercase label used above
  /// section titles ("MUMBAI MUN 2026").
  static TextStyle eyebrow(Color color) => GoogleFonts.inter(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.4,
      );

  /// Big tabular numerals for countdowns / stats.
  static TextStyle numeral(Color color, {double size = 34}) =>
      GoogleFonts.spaceGrotesk(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.0,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
