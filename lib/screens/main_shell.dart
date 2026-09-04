import 'package:flutter/material.dart';
import 'package:houra_app/screens/entries_screen.dart';
import 'package:houra_app/screens/home_screen.dart';
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

  static const _pages = [
    HomeScreen(),
    EntriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: HouraBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        onAdd: () => showAddEntrySheet(context),
      ),
    );
  }
}