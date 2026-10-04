import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// A QR code drawn in the app's own visual language: data modules as small
/// hollow rings (the same dot-cluster motif used on every Quick Access
/// card), with classic rounded-square finder "eyes" — not the big filled
/// circles qr_flutter's circle style produces. No plate needed — it's
/// designed to sit directly on a colored card background, using whatever
/// [backgroundColor] is passed (defaulting to fully transparent) rather
/// than forcing white behind it.
class HollowRingQr extends StatelessWidget {
  final String data;
  final double size;
  final Color color;
  final Color backgroundColor;

  const HollowRingQr({
    super.key,
    required this.data,
    required this.size,
    required this.color,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final qrCode = QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M);
    final qrImage = QrImage(qrCode);
    return CustomPaint(
      size: Size(size, size),
      painter: _HollowRingQrPainter(qrImage, color, backgroundColor),
    );
  }
}

class _HollowRingQrPainter extends CustomPainter {
  final QrImage qr;
  final Color color;
  final Color backgroundColor;

  _HollowRingQrPainter(this.qr, this.color, this.backgroundColor);

  bool _inEye(int row, int col, int n) {
    final tl = row < 7 && col < 7;
    final tr = row < 7 && col >= n - 7;
    final bl = row >= n - 7 && col < 7;
    return tl || tr || bl;
  }

  void _drawEye(Canvas canvas, double cell, int topRow, int topCol) {
    final outerRect = Rect.fromLTWH(topCol * cell, topRow * cell, cell * 7, cell * 7);
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.55;
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect.deflate(cell * 0.52), Radius.circular(cell * 1.6)),
      ringPaint,
    );

    final innerRect = Rect.fromLTWH(
      (topCol + 2) * cell,
      (topRow + 2) * cell,
      cell * 3,
      cell * 3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(cell * 0.9)),
      Paint()..color = color,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = qr.moduleCount;
    final cell = size.width / n;

    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.22;
    const outerRadiusFactor = 0.32;

    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        if (!qr.isDark(row, col)) continue;
        if (_inEye(row, col, n)) continue;
        final center = Offset((col + 0.5) * cell, (row + 0.5) * cell);
        canvas.drawCircle(center, cell * outerRadiusFactor, ringPaint);
      }
    }

    _drawEye(canvas, cell, 0, 0);
    _drawEye(canvas, cell, 0, n - 7);
    _drawEye(canvas, cell, n - 7, 0);
  }

  @override
  bool shouldRepaint(covariant _HollowRingQrPainter oldDelegate) =>
      oldDelegate.qr != qr || oldDelegate.color != color;
}
