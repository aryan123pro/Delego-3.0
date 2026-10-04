import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/Login_Page/login_page.dart';
import 'Pages/Home_Page/home_page.dart';

import 'Theme/app_theme.dart';
import 'Theme/theme_controller.dart';
import 'Theme/design_tokens.dart';
import 'Widgets/backgrounds.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = ThemeController();
  await controller.loadThemeMode();

  runApp(MyApp(controller: controller));
}

class MyApp extends StatefulWidget {
  final ThemeController controller;
  const MyApp({super.key, required this.controller});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showLaunchScreen = true;
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (!mounted) return;
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() => showLaunchScreen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        // Kept in sync with the resolved theme so the many shared widgets
        // that read AppColors.void_/textPrimary directly (rather than
        // Theme.of(context)) stay theme-aware too.
        AppColors.isLight = widget.controller.isLight;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: widget.controller.mode,
          home: showLaunchScreen
              ? LaunchScreen(onLaunchComplete: _onLaunchComplete)
              : (isLoggedIn == true
                  ? HomePage(controller: widget.controller)
                  : LoginPage(controller: widget.controller)),
        );
      },
    );
  }

  void _onLaunchComplete() {
    if (!mounted) return;
    setState(() => showLaunchScreen = false);
  }
}

class LaunchScreen extends StatefulWidget {
  final VoidCallback onLaunchComplete;
  const LaunchScreen({super.key, required this.onLaunchComplete});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mark;
  late final AnimationController _word;

  @override
  void initState() {
    super.initState();

    _mark = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _word = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _mark.addStatusListener((status) {
      if (status == AnimationStatus.completed) _word.forward();
    });

    _word.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          widget.onLaunchComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _mark.dispose();
    _word.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.heroBackdrop)),
          const ConstellationScaffoldBackdrop(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: _mark, curve: Curves.easeOutBack),
                  child: FadeTransition(
                    opacity: _mark,
                    child: SizedBox(
                      height: 150,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (rect) => AppGradients.brand.createShader(rect),
                        child: Image.asset('assets/icons/gateway_mark.png', fit: BoxFit.fitHeight),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _word,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: _word, curve: Curves.easeOutCubic)),
                    child: Column(
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (rect) => AppGradients.brand.createShader(rect),
                          child: Text(
                            'DELEGO',
                            style: AppType.numeral(Colors.white, size: 40)
                                .copyWith(letterSpacing: 4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'MUMBAI MUN 2026 — AN AXIOM APART',
                          style: AppType.eyebrow(AppColors.gold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
