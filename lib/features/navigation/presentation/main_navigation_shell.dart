import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import '../../workout/presentation/active_workout_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;
  const MainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    ActiveWorkoutScreen(),
    HistoryScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withAlpha(50),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'HOME',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(
              Icons.fitness_center_rounded,
              color: AppColors.primary,
            ),
            label: 'WORKOUT',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(
              Icons.history_toggle_off_rounded,
              color: AppColors.primary,
            ),
            label: 'HISTORY',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_rounded),
            selectedIcon: Icon(
              Icons.show_chart_rounded,
              color: AppColors.primary,
            ),
            label: 'PROGRESS',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}
