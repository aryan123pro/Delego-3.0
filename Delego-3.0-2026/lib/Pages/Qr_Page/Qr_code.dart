import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Theme/design_tokens.dart';
import 'package:delego/Widgets/cards.dart';
import 'package:delego/Widgets/hollow_qr.dart';
import 'package:delego/Widgets/page_header.dart';

/// A duotone the badge can be drawn in: the exact gradient + accent pair
/// from one of the Home dashboard's Quick Access cards, so the badge reads
/// as part of that same family instead of its own one-off style.
class _Duotone {
  final List<Color> gradient;
  final Color accent;
  const _Duotone(this.gradient, this.accent);
}

/// The 4 Quick Access card duotones (Study Guides, QR Badge, Rooms,
/// Schedule) — one picked at random each time the page loads.
const _duotones = [
  _Duotone([Color(0xFFBFE416), Color(0xFF3D5A1E)], Color(0xFFFF3B30)),
  _Duotone([AppColors.hotPink, Color(0xFF4A1240)], AppColors.gold),
  _Duotone([Color(0xFF2E6BFF), Color(0xFF0B1A4A)], Color(0xFFB6FF3B)),
  _Duotone([Color(0xFF15C99C), Color(0xFF0E4A48)], Color(0xFF3BE6FF)),
];

class QrCode extends StatefulWidget {
  final bool embedded;
  const QrCode({super.key, this.embedded = false});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  String _name = '';
  String _id = '';
  late final _Duotone _duotone = _duotones[Random().nextInt(_duotones.length)];

  @override
  void initState() {
    super.initState();
    _loadDelegate();
  }

  Future<void> _loadDelegate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      final first = prefs.getString('firstname') ?? '';
      final last = prefs.getString('lastname') ?? '';
      _name = '$first $last'.trim();
      _id = prefs.getString('id') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackdrop(
      standalone: !widget.embedded,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          const SectionHeaderBar(title: 'My QR Badge'),
          const SizedBox(height: 12),
          const PlainSectionHeader(
            eyebrow: 'DELEGATE PASS',
            title: 'Food QR Code',
            accent: AppColors.gold,
          ),
          const SizedBox(height: 28),
          if (_id.isNotEmpty)
            _DelegateBadge(name: _name, id: _id, duotone: _duotone)
          else
            const GlassCard(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: EmptyStateNote(
                icon: Icons.qr_code_rounded,
                title: 'No QR code available',
                message: 'Contact the Organizing Committee if this keeps happening.',
              ),
            ),
        ],
      ),
    );
  }
}

/// Event-badge styled QR card — built from the exact same duotone + grain
/// language as the Home dashboard's Quick Access cards, so it reads as one
/// family instead of a one-off design: the delegate's name up top, a
/// perforated "ticket stub" divider, then the QR in a matching-accent
/// white plate.
class _DelegateBadge extends StatelessWidget {
  final String name;
  final String id;
  final _Duotone duotone;

  const _DelegateBadge({required this.name, required this.id, required this.duotone});

  @override
  Widget build(BuildContext context) {
    final ink = duotone.accent;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: duotone.gradient,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CardHalftoneTexture(seed: 3)),
            Positioned.fill(child: CustomPaint(painter: _GrungeNoise(seed: 7))),
            // Faint Gateway watermark behind the header text.
            Positioned(
              right: -18,
              top: -10,
              child: Opacity(
                opacity: 0.16,
                child: Image.asset('assets/icons/gateway_mark.png',
                    width: 130, height: 130, fit: BoxFit.contain),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DELEGATE PASS', style: AppType.eyebrow(ink)),
                            const SizedBox(height: 4),
                            Text(
                              name.isEmpty ? 'Delegate' : name,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 19),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _TicketPerforation(color: Theme.of(context).scaffoldBackgroundColor),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SHOW THIS AT THE FOOD COUNTER',
                        textAlign: TextAlign.center,
                        style: AppType.eyebrow(Colors.white.withValues(alpha: 0.85)).copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 18),
                      // No plate — it stands directly on the badge's own
                      // gradient, in the same accent already proven
                      // readable against it (the card's own label color).
                      // Regenerated client-side from the same delegate id
                      // the backend encodes, so it stays fully scannable —
                      // data modules as small hollow rings (matching the
                      // dot-cluster motif everywhere else in the app),
                      // classic square finder eyes.
                      Center(child: HollowRingQr(data: id, size: 250, color: ink)),
                      const SizedBox(height: 16),
                      if (id.isNotEmpty)
                        Text(
                          'ID · ${id.length > 10 ? id.substring(0, 10).toUpperCase() : id.toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              letterSpacing: 1),
                        ),
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Bon appétit! Enjoy your meal',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A dashed divider with two half-circle "punch" notches on either edge,
/// mimicking a torn event-ticket stub between the badge header and the QR.
class _TicketPerforation extends StatelessWidget {
  final Color color;
  const _TicketPerforation({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: -10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashedLinePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.4;
    const dash = 6.0;
    const gap = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}

/// A denser, more visible grunge pass layered on top of the shared card
/// halftone — coarse dark speckle plus a few faint diagonal scratches — so
/// the badge reads as distressed/printed like the reference committee
/// cards, not just faintly gridded.
class _GrungeNoise extends CustomPainter {
  final int seed;
  const _GrungeNoise({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);

    final speckle = Paint();
    final count = (size.width * size.height / 42).round();
    for (var i = 0; i < count; i++) {
      final dark = rnd.nextBool();
      speckle.color = (dark ? Colors.black : Colors.white)
          .withValues(alpha: rnd.nextDouble() * 0.10 + 0.03);
      final p = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      canvas.drawCircle(p, rnd.nextDouble() * 1.1 + 0.3, speckle);
    }

    final scratch = Paint()
      ..color = Colors.black.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = rnd.nextDouble() * size.height;
      final len = rnd.nextDouble() * size.width * 0.4 + size.width * 0.1;
      final x = rnd.nextDouble() * size.width;
      canvas.drawLine(Offset(x, y), Offset(x + len, y + (rnd.nextDouble() - 0.5) * 14), scratch);
    }
  }

  @override
  bool shouldRepaint(covariant _GrungeNoise oldDelegate) => false;
}
