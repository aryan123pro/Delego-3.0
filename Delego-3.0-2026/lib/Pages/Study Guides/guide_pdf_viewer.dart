import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:delego/Theme/design_tokens.dart';

/// Single reusable study-guide PDF viewer — every committee points here with
/// its own title and asset instead of a hand-duplicated wrapper per guide.
class GuidePdfViewer extends StatelessWidget {
  final String title;
  final String assetPath;

  const GuidePdfViewer({super.key, required this.title, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.void_,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(title, style: AppType.eyebrow(AppColors.textPrimary)),
      ),
      body: SfPdfViewer.asset(assetPath),
    );
  }
}
