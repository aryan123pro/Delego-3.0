import 'package:flutter/material.dart';
import '../Theme/design_tokens.dart';
import 'backgrounds.dart';

/// Shared back-button + eyebrow title row used at the top of every inner
/// page, matching the Profile page's pattern — keeps every screen under
/// Quick Access visually consistent with the Home dashboard instead of
/// falling back to a plain Material AppBar.
class SectionHeaderBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const SectionHeaderBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          )
        else
          const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: AppType.eyebrow(AppColors.textPrimary)),
        ),
        if (actions != null) ...actions!,
        if (actions == null) const SizedBox(width: 48),
      ],
    );
  }
}

/// Plain text section header — small grey eyebrow over a bold colored
/// headline — mirroring how mumbaimun.com actually headers its inner pages
/// ("MUMBAI MUN 2026" / "Mumbai MUN Schedule"). Used instead of the Gateway
/// hero banner so that image isn't repeated on every single screen; the
/// banner stays reserved for Home and the auth flow.
class PlainSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Color accent;

  const PlainSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.accent = AppColors.hotPink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppType.eyebrow(AppColors.textTertiary)),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppType.numeral(accent, size: 30).copyWith(letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }
}

/// Standard dark scaffold shell — void background + constellation dust —
/// used by every inner page reached from Quick Access. Pass
/// `standalone: false` when the page is embedded as a tab inside
/// [MainShell] (which already owns the real Scaffold) so it doesn't nest
/// a second one — just paints the same background and content in place.
class AppScaffoldBackdrop extends StatelessWidget {
  final Widget child;
  final bool standalone;
  const AppScaffoldBackdrop({super.key, required this.child, this.standalone = true});

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      children: [
        const Positioned.fill(child: ConstellationScaffoldBackdrop()),
        SafeArea(child: child),
      ],
    );

    if (!standalone) {
      return Container(color: AppColors.void_, child: content);
    }

    return Scaffold(backgroundColor: AppColors.void_, body: content);
  }
}
