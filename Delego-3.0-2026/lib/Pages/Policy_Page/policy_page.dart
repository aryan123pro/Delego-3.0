import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Policies",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF114C90),
      ),
      body: const Center(
        child: Text("Select a policy from the drawer dropdown."),
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String pdfAsset;

  const PdfViewerPage({super.key, required this.pdfAsset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Policy')),
      body: SfPdfViewer.asset(pdfAsset),
    );
  }
}

