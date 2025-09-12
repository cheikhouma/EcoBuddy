import 'package:eco_buddy/core/widgets/bottom_navbar.dart';
import 'package:eco_buddy/features/challenges/presentation/challenges_screen.dart';
import 'package:eco_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:eco_buddy/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:eco_buddy/features/narration/presentation/narration_screen.dart';
import 'package:eco_buddy/features/scanner/presentation/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    NarrationScreen(),
    ChallengesScreen(),
    ScannerScreen(),
    LeaderboardScreen(),
  ];

  void onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: onTabSelected,
      ),
    );
  }
}
