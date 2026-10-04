import 'package:flutter/material.dart';

import 'package:delego/Pages/Study Guides/guide_pdf_viewer.dart';
import 'package:delego/Theme/design_tokens.dart';
import 'package:delego/Widgets/page_header.dart';

class _Committee {
  final String code;
  final String name;
  final String image;
  final String asset;

  const _Committee({
    required this.code,
    required this.name,
    required this.image,
    required this.asset,
  });
}

/// The 8 committees currently live on mumbaimun.com/committees. `image`
/// points at that site's own committee card artwork (downloaded as-is), so
/// these render pixel-identical to the real cards. Every card opens a
/// placeholder PDF for now — swap `asset` for the real guide as each one is
/// finalized.
const _committees = [
  _Committee(
    code: 'UNSC',
    name: 'UN Security Council',
    image: 'assets/icons/committees/unsc.jpg',
    asset: 'assets/pdfs/UNSC.pdf',
  ),
  _Committee(
    code: 'UNODC',
    name: 'UN Office on Drugs and Crime',
    image: 'assets/icons/committees/unodc.jpg',
    asset: 'assets/pdfs/UNODC.pdf',
  ),
  _Committee(
    code: 'WTO',
    name: 'World Trade Organization',
    image: 'assets/icons/committees/wto.jpg',
    asset: 'assets/pdfs/G20.pdf',
  ),
  _Committee(
    code: 'ECOSOC',
    name: 'Economic and Social Council',
    image: 'assets/icons/committees/ecosoc.jpg',
    asset: 'assets/pdfs/UNEA.pdf',
  ),
  _Committee(
    code: 'UNICEF',
    name: "UN Children's Fund",
    image: 'assets/icons/committees/unicef.jpg',
    asset: 'assets/pdfs/UNCSW.pdf',
  ),
  _Committee(
    code: 'IPC',
    name: 'Indian Penal Code',
    image: 'assets/icons/committees/ipc.jpg',
    asset: 'assets/pdfs/IPC.pdf',
  ),
  _Committee(
    code: 'CCC',
    name: 'Continuous Crisis Committee',
    image: 'assets/icons/committees/ccc.jpg',
    asset: 'assets/pdfs/LokSabha.pdf',
  ),
  _Committee(
    code: 'PSC',
    name: 'Political and Security Committee',
    image: 'assets/icons/committees/psc.jpg',
    asset: 'assets/pdfs/UNEA.pdf',
  ),
];

class StudyGuidespage extends StatelessWidget {
  final bool embedded;
  const StudyGuidespage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackdrop(
      standalone: !embedded,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          SectionHeaderBar(title: 'Study Guides'),
          const SizedBox(height: 12),
          const PlainSectionHeader(
            eyebrow: 'MUMBAI MUN 2026',
            title: 'Committees & Agendas',
            accent: AppColors.goldDeep,
          ),
          const SizedBox(height: 8),
          Text(
            '${_committees.length} committees — tap a card for its study guide.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _committees.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final c = _committees[index];
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GuidePdfViewer(title: '${c.code} — ${c.name}', assetPath: c.asset),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: Image.asset(c.image, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
