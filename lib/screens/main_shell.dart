import 'package:flutter/material.dart';

import 'package:houra_app/screens/entries_screen.dart';
import 'package:houra_app/screens/home_screen.dart';
import 'package:houra_app/screens/profile_screen.dart';
import 'package:houra_app/screens/stats_screen.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/widgets/add_entry_sheet.dart';
import 'package:houra_app/widgets/hour_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  void _goToProfile() => setState(() => _tab = 3);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onProfileTap: _goToProfile),
      const EntriesScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_tab), child: pages[_tab]),
      ),
      bottomNavigationBar: HouraBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        onAdd: () => showAddEntrySheet(context),
      ),
    );
  }
}