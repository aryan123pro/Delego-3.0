import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:delego/Theme/design_tokens.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final MobileScannerController controller = MobileScannerController();

  bool dialogShowing = false;
  bool torchOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void showQRResult(String value) {
    if (dialogShowing) return;
    dialogShowing = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceRaised,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
              const SizedBox(width: 10),
              Text('QR Code Found',
                  style: AppType.eyebrow(AppColors.textPrimary).copyWith(fontSize: 14)),
            ],
          ),
          content: SelectableText(value, style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    ).then((_) {
      dialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text('Scan Delegate QR', style: AppType.eyebrow(Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final value = barcode.rawValue;
                if (value != null && value.isNotEmpty) {
                  showQRResult(value);
                  break;
                }
              }
            },
          ),
          // Dimmed frame overlay so the scan target reads clearly.
          IgnorePointer(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 2.5),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: Text(
                'Line up the QR code within the frame',
                style: AppType.eyebrow(Colors.white.withValues(alpha: 0.85)).copyWith(fontSize: 11.5),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.hotPink,
        onPressed: () {
          controller.toggleTorch();
          setState(() => torchOn = !torchOn);
        },
        child: Icon(torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white),
      ),
    );
  }
}
