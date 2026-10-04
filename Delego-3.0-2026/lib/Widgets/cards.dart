import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Theme/design_tokens.dart';

/// Frosted glass surface — translucent fill + blur + hairline border.
/// Falls back gracefully on light theme (just a soft flat card, blur reads
/// poorly on light backgrounds).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppRadii.lg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.055)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? AppColors.hairline : scheme.outlineVariant,
          width: 1,
        ),
      ),
      child: child,
    );

    if (!isDark) return content;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: content,
      ),
    );
  }
}

/// Reference-matched card texture: a faint graph-paper grid plus a regular
/// halftone dot screen (each dot present with fixed probability for grain,
/// not fully random placement) — mirrors mumbaimun.com's committee cards.
class _HalftonePainter extends CustomPainter {
  final int seed;
  const _HalftonePainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..strokeWidth = 0.6;
    const gridStep = 17.0;
    for (double x = 0; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final rnd = Random(seed);
    final dotPaint = Paint()..color = Colors.black.withValues(alpha: 0.16);
    const dotStep = 7.0;
    for (double y = dotStep / 2; y < size.height; y += dotStep) {
      for (double x = dotStep / 2; x < size.width; x += dotStep) {
        if (rnd.nextDouble() > 0.55) continue;
        canvas.drawCircle(Offset(x, y), 0.7, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter oldDelegate) => false;
}

/// Public wrapper so other pages can drop the same grid+halftone grain the
/// Quick Access cards use onto their own surfaces, for a consistent texture.
class CardHalftoneTexture extends StatelessWidget {
  final int seed;
  const CardHalftoneTexture({super.key, this.seed = 1});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _HalftonePainter(seed), size: Size.infinite);
}

/// Rasterizes an [IconData]'s glyph off-screen once and reduces it to a
/// uniform grid covering the *entire* box, each cell carrying how much ink
/// the glyph has there (0 = empty, 1 = solid). Cached per icon so the
/// rasterization only happens once app-wide.
class _GlyphMask {
  static final Map<int, Future<List<List<double>>>> _cache = {};
  static const _raster = 128;
  static const grid = 10;

  static Future<List<List<double>>> forIcon(IconData icon) {
    return _cache.putIfAbsent(icon.codePoint, () => _compute(icon));
  }

  static Future<List<List<double>>> _compute(IconData icon) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: _raster.toDouble(),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: const Color(0xFFFFFFFF),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset.zero);
    final picture = recorder.endRecording();
    final image = await picture.toImage(_raster, _raster);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final blank = List.generate(grid, (_) => List.filled(grid, 0.0));
    if (bytes == null) return blank;

    final data = bytes.buffer.asUint8List();
    const cell = _raster / grid;
    final out = List.generate(grid, (_) => List.filled(grid, 0.0));
    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        // Average alpha across the whole cell, not just its center pixel,
        // so thin glyph strokes (a calendar's grid lines, a pin's outline)
        // still register instead of being missed between samples.
        var sum = 0;
        var n = 0;
        for (var oy = 0; oy < cell; oy += 3) {
          for (var ox = 0; ox < cell; ox += 3) {
            final px = (gx * cell + ox).floor().clamp(0, _raster - 1);
            final py = (gy * cell + oy).floor().clamp(0, _raster - 1);
            sum += data[(py * _raster + px) * 4 + 3];
            n++;
          }
        }
        out[gy][gx] = n == 0 ? 0 : (sum / n) / 255;
      }
    }
    return out;
  }
}

/// A light, evenly-proportioned scatter of small hollow (stroke-only,
/// unconnected) rings, one per grid cell across the *whole* icon box — every
/// cell gets a baseline chance so dots sit on all sides of the icon (not
/// just its densest strokes), nudged toward cells with more glyph ink so the
/// shape still reads through, echoing the dot treatment mumbaimun.com uses
/// over its own Gateway-of-India artwork. Every ring is the same size.
class _HollowDotsPainter extends CustomPainter {
  final int seed;
  final Color color;
  final List<List<double>> alphaGrid;
  const _HollowDotsPainter(this.seed, this.color, this.alphaGrid);

  static const ringRadius = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (alphaGrid.isEmpty) return;
    final rnd = Random(seed);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.9);

    final rows = alphaGrid.length;
    final cols = alphaGrid[0].length;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    const inkThreshold = 0.12;
    final ink = <Point<int>>[
      for (var gy = 0; gy < rows; gy++)
        for (var gx = 0; gx < cols; gx++)
          if (alphaGrid[gy][gx] > inkThreshold) Point(gx, gy),
    ];
    if (ink.isEmpty) return;

    // Nearest-neighbour distance (in cells) from every cell to the closest
    // bit of actual ink — used so "proportionate on all sides" baseline
    // dots only appear right around the artwork, never floating alone in a
    // far corner of the box that happens to share the icon's overall
    // bounding rectangle.
    const maxCellDist = 1.15;
    double nearestInkDist(int gx, int gy) {
      var best = double.infinity;
      for (final p in ink) {
        final d = sqrt(pow(gx - p.x, 2) + pow(gy - p.y, 2));
        if (d < best) best = d;
      }
      return best;
    }

    for (var gy = 0; gy < rows; gy++) {
      for (var gx = 0; gx < cols; gx++) {
        if (nearestInkDist(gx, gy) > maxCellDist) continue;

        // Baseline chance so every side of the icon gets some coverage,
        // plus a bonus where the glyph actually has ink.
        final chance = 0.06 + alphaGrid[gy][gx] * 0.34;
        if (rnd.nextDouble() > chance) continue;

        // Braille-style: every ring sits at its exact fixed lattice
        // position — no jitter — so the cluster reads as a precise dot
        // matrix rather than an organic scatter.
        final cx = (gx + 0.5) * cellW;
        final cy = (gy + 0.5) * cellH;
        canvas.drawCircle(Offset(cx, cy), ringRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HollowDotsPainter oldDelegate) =>
      oldDelegate.alphaGrid != alphaGrid;
}

/// Bento-grid action card for the home dashboard quick links — styled after
/// Mumbai MUN 2026's committee cards: a duotone gradient, halftone grain, a
/// big faint icon "stamped" in the corner, and a cluster of hollow rings
/// over it, with a bold neon-accent label.
class BentoActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;
  final VoidCallback onTap;
  final bool wide;
  final int seed;
  final bool showDots;

  const BentoActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.gradient = const [AppColors.hotPink, AppColors.violet],
    this.accent = Colors.white,
    this.wide = false,
    this.seed = 1,
    this.showDots = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: wide ? 108 : 148,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Builder(builder: (context) {
            final boxSize = wide ? 84.0 : 92.0;
            return Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _HalftonePainter(seed))),

                // Icon fully contained in its own square box — no overflow
                // past the card edge — with a grain pass on top of it so the
                // glyph itself reads as textured/distorted, and a ring
                // cluster traced from its actual glyph pixels.
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: -0.08,
                    child: SizedBox(
                      width: boxSize,
                      height: boxSize,
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(icon, size: boxSize * 0.86,
                                color: Colors.black.withValues(alpha: 0.4)),
                          ),
                          if (showDots)
                            FutureBuilder<List<List<double>>>(
                              future: _GlyphMask.forIcon(icon),
                              builder: (context, snap) {
                                final grid = snap.data ?? const [];
                                return CustomPaint(
                                  size: Size(boxSize, boxSize),
                                  painter: _HollowDotsPainter(seed, accent, grid),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: wide ? 22 : 21,
                        height: 1.02,
                        letterSpacing: 0,
                        shadows: const [
                          Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Flat colored list row — icon chip, title/subtitle, trailing chevron —
/// used for Study Guides and Rooms so those lists share the dashboard's
/// bold-color-block language instead of a plain Material list tile.
class ListRowCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ListRowCard({
    super.key,
    required this.icon,
    required this.title,
    this.accent = AppColors.hotPink,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: GlassCard(
          radius: AppRadii.md,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centered icon + message, for empty/error/loading states on inner pages.
class EmptyStateNote extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const EmptyStateNote({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
