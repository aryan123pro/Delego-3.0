import 'dart:math';
import 'package:flutter/material.dart';
import '../Theme/design_tokens.dart';

/// Scattered "connect the dots" constellation, echoing the Mumbai MUN mark.
/// Deterministic (fixed seed) so it doesn't repaint differently each build.
class ConstellationPainter extends CustomPainter {
  final Color dotColor;
  final Color lineColor;
  final int density;

  ConstellationPainter({
    this.dotColor = AppColors.gold,
    Color? lineColor,
    this.density = 46,
  }) : lineColor = lineColor ?? dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(7);
    final points = List.generate(
      density,
      (_) => Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
    );

    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final d = (points[i] - points[j]).distance;
        if (d < size.width * 0.11) {
          canvas.drawLine(points[i], points[j], linePaint);
        }
      }
    }

    for (final p in points) {
      final r = rnd.nextDouble() * 1.6 + 0.8;
      canvas.drawCircle(
        p,
        r,
        Paint()..color = dotColor.withValues(alpha: rnd.nextDouble() * 0.5 + 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) => false;
}

/// Full hero backdrop using Mumbai MUN 2026's own Gateway-of-India-with-dots
/// artwork (pulled straight from mumbaimun.com), with a left-side scrim so
/// our own headline text stays legible over it.
class GatewayHeroBanner extends StatelessWidget {
  final double height;
  final EdgeInsets padding;
  final Widget child;

  const GatewayHeroBanner({
    super.key,
    required this.child,
    this.height = 260,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 24),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.magenta,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/icons/gateway_hero.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
            // Always a dark scrim, regardless of theme — the headline text
            // laid over this banner is always white, so the scrim can't
            // flip to a light color just because the page around it did.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xBF0A0910),
                    Color(0x260A0910),
                  ],
                  stops: [0.0, 0.75],
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Subtle full-screen constellation wash for plain dark surfaces
/// (auth screens, splash).
class ConstellationScaffoldBackdrop extends StatelessWidget {
  const ConstellationScaffoldBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    // Light mode wants a plain, full-white background — the dot/glow
    // atmosphere is part of the dark "void" identity only.
    if (AppColors.isLight) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A faint violet glow rising from the true bottom edge so that
          // region never reads as a flat, undecorated black slab — it
          // stays part of the same lit atmosphere as the rest of the
          // page, all the way to the screen edge.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomCenter,
                radius: 1.2,
                colors: [
                  Color(0x2E7B2FF7),
                  Color(0x00000000),
                ],
              ),
            ),
          ),
          Opacity(
            opacity: 0.35,
            child: CustomPaint(
              painter: ConstellationPainter(dotColor: AppColors.gold, density: 70),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}
