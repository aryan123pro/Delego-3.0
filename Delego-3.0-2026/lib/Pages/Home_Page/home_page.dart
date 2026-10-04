import 'package:delego/Pages/Login_Page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:delego/Pages/Home_Page/my_drawer.dart';
import 'package:delego/Pages/main_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Theme/theme_controller.dart';
import 'package:delego/Theme/design_tokens.dart';
import 'package:delego/Widgets/backgrounds.dart';
import 'package:delego/Widgets/cards.dart';
import 'package:delego/Pages/Qr_Page/Qr_scanner.dart';

class HomePage extends StatefulWidget {
  final ThemeController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(controller: widget.controller)),
      (route) => false,
    );
  }

  void goToPage(Widget page) async {
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.void_,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          title: Text('Delego', style: AppType.eyebrow(AppColors.textPrimary)),
          centerTitle: true,
        ),
        drawer: MyDrawer(
          onProfileTap: () => goToPage(
              MainShell(controller: widget.controller, initialIndex: 4)),
          onSignoutTap: signOut,
        ),
        body: Stack(
          children: [
            if (isDark)
              const Positioned.fill(child: ConstellationScaffoldBackdrop()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // On a tall screen the 5 Quick Access cards don't fill
                  // the viewport, which left a dead, unstyled gap between
                  // the last card and the true bottom edge. Pin the
                  // sponsors footer to the bottom of the viewport instead
                  // (via the Spacer below) so the page always reads as
                  // "filled" rather than stopping short partway down.
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight - 32),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GatewayHeroBanner(
                              height: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('MUMBAI MUN',
                                      style: AppType.eyebrow(AppColors.gold)),
                                  const SizedBox(height: 6),
                                  Text(
                                    '2026',
                                    style:
                                        AppType.numeral(Colors.white, size: 44),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'AN AXIOM APART',
                                    style: AppType.eyebrow(Colors.white
                                            .withValues(alpha: 0.75))
                                        .copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text('Quick Access',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: AppColors.textPrimary)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: BentoActionCard(
                                    title: 'Study\nGuides',
                                    icon: Icons.menu_book_rounded,
                                    gradient: const [
                                      Color(0xFFBFE416),
                                      Color(0xFF3D5A1E)
                                    ],
                                    accent: const Color(0xFFFF3B30),
                                    seed: 1,
                                    onTap: () => goToPage(MainShell(
                                        controller: widget.controller,
                                        initialIndex: 0)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: BentoActionCard(
                                    title: 'My QR\nBadge',
                                    icon: Icons.qr_code_rounded,
                                    gradient: const [
                                      AppColors.hotPink,
                                      Color(0xFF4A1240)
                                    ],
                                    accent: AppColors.gold,
                                    seed: 2,
                                    onTap: () => goToPage(MainShell(
                                        controller: widget.controller,
                                        initialIndex: 3)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: BentoActionCard(
                                    title: 'Rooms',
                                    icon: Icons.location_on_rounded,
                                    gradient: const [
                                      Color(0xFF2E6BFF),
                                      Color(0xFF0B1A4A)
                                    ],
                                    accent: const Color(0xFFB6FF3B),
                                    seed: 3,
                                    onTap: () => goToPage(MainShell(
                                        controller: widget.controller,
                                        initialIndex: 2)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: BentoActionCard(
                                    title: 'Schedule',
                                    icon: Icons.calendar_month_rounded,
                                    gradient: const [
                                      Color(0xFF15C99C),
                                      Color(0xFF0E4A48)
                                    ],
                                    accent: const Color(0xFF3BE6FF),
                                    seed: 4,
                                    onTap: () => goToPage(MainShell(
                                        controller: widget.controller,
                                        initialIndex: 1)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            BentoActionCard(
                              title: 'Scan a Delegate QR',
                              icon: Icons.qr_code_scanner_rounded,
                              gradient: const [
                                AppColors.violet,
                                Color(0xFF1A0B3D)
                              ],
                              accent: AppColors.gold,
                              seed: 5,
                              wide: true,
                              showDots: false,
                              onTap: () => goToPage(QrScanner()),
                            ),
                            const SizedBox(height: 32),
                            const Spacer(),
                            Center(
                              child: Column(
                                children: [
                                  Text('SPONSORED BY',
                                      style: AppType.eyebrow(
                                          AppColors.textTertiary)),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 16,
                                    runSpacing: 10,
                                    children: [
                                      Opacity(
                                        opacity: 0.85,
                                        child: Image.asset(
                                            'assets/icons/toshiba.png',
                                            height: 20),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
