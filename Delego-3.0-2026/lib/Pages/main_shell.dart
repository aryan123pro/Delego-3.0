import 'package:flutter/material.dart';
import 'package:delego/Theme/theme_controller.dart';
import 'package:delego/Widgets/glass_nav_bar.dart';
import 'Study Guides/study_guidespage.dart';
import 'Schedule_Page/schedule_page.dart';
import 'Room_Page/room_page.dart';
import 'Qr_Page/Qr_code.dart';
import 'Profile_Page/profile_page.dart';

/// A section shell you *push* on top of Home — not something Home lives
/// inside. Home stays the bare, chrome-free landing page; this shell (with
/// its sleek, flush bottom bar) only appears once a delegate has gone
/// into one of these sections, so they can jump laterally between Study
/// Guides / Schedule / Rooms / QR Badge / Profile without popping back to
/// Home first. The existing back arrow on each page still pops the whole
/// shell and returns to Home.
class MainShell extends StatefulWidget {
  final ThemeController controller;
  final int initialIndex;
  const MainShell({super.key, required this.controller, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  late final List<Widget> _pages = [
    const StudyGuidespage(embedded: true),
    const SchedulePage(embedded: true),
    const RoomPage(embedded: true),
    const QrCode(embedded: true),
    ProfilePage(controller: widget.controller, embedded: true),
  ];

  static const _items = [
    GlassNavItem(
        icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Guides'),
    GlassNavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        label: 'Schedule'),
    GlassNavItem(
        icon: Icons.location_on_outlined, activeIcon: Icons.location_on_rounded, label: 'Rooms'),
    GlassNavItem(icon: Icons.qr_code_outlined, activeIcon: Icons.qr_code_rounded, label: 'QR'),
    GlassNavItem(
        icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // A real bottomNavigationBar now that the bar is an opaque, flat dock
    // rather than glass content needs to show through — Scaffold reserves
    // its layout slot for it and the page body sizes around it correctly.
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _index,
        items: _items,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
