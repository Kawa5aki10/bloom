import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'learn_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'relax_screen.dart';
import 'today_screen.dart';

/// Main screen with the bottom menu.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.colors;
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          TodayScreen(),
          RelaxScreen(),
          LearnScreen(),
          ProgressScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border, width: 2))),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny_rounded, color: c.primary),
              label: s.t('tab_today'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.spa_outlined),
              selectedIcon: Icon(Icons.spa_rounded, color: c.primary),
              label: s.t('tab_relax'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded, color: c.primary),
              label: s.t('tab_learn'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: c.primary),
              label: s.t('tab_progress'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: c.primary),
              label: s.t('tab_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
