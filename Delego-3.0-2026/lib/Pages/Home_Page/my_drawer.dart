import 'package:flutter/material.dart';
import 'package:delego/Pages/Sponsors_Page/sponsor_page.dart';
import 'package:delego/Pages/Policy_Page/policy_page.dart';
import 'package:delego/Theme/design_tokens.dart';

class MyDrawer extends StatefulWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;

  const MyDrawer({
    Key? key,
    required this.onProfileTap,
    required this.onSignoutTap,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void goToSponsorsPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SponsorPage()),
    );
  }

  void openPolicy(String policyName) {
    Navigator.pop(context);

    final pdfAsset = (policyName == 'POSH Policy')
        ? 'assets/pdfs/POSH.pdf'
        : 'assets/pdfs/ConferencePolicy.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfAsset: pdfAsset),
      ),
    );
  }

  Widget _item(IconData icon, String text, VoidCallback? onTap, {Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 21),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.void_,
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text('MUMBAI MUN', style: AppType.eyebrow(AppColors.gold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Delegate Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _item(Icons.home_rounded, 'HOME', () => Navigator.pop(context)),
                  Divider(color: AppColors.hairline, height: 1, indent: 24, endIndent: 24),
                  _item(Icons.person_rounded, 'PROFILE', widget.onProfileTap),
                  Divider(color: AppColors.hairline, height: 1, indent: 24, endIndent: 24),
                  _item(Icons.handshake_rounded, 'SPONSORS', goToSponsorsPage),
                  Divider(color: AppColors.hairline, height: 1, indent: 24, endIndent: 24),
                  _item(
                    Icons.policy_rounded,
                    'POLICIES',
                    null,
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      color: AppColors.surfaceRaised,
                      onSelected: openPolicy,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'POSH Policy',
                          child: Text('POSH Policy',
                              style: TextStyle(color: AppColors.textPrimary)),
                        ),
                        PopupMenuItem(
                          value: 'Conference Policy',
                          child: Text('Conference Policy',
                              style: TextStyle(color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                  label: const Text('LOGOUT',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                  onPressed: widget.onSignoutTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
