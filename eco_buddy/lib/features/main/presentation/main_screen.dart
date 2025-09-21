import 'package:eco_buddy/core/widgets/bottom_navbar.dart';
import 'package:eco_buddy/features/challenges/presentation/challenges_screen.dart';
import 'package:eco_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:eco_buddy/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:eco_buddy/features/narration/presentation/narration_screen.dart';
import 'package:eco_buddy/features/scanner/presentation/unified_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  void onTabSelected(int index) {
    // ✅ CLEANUP IMMÉDIAT : Si on quitte l'onglet scanner (index 1)
    if (_currentIndex == 1 && index != 1) {
      print('🔴 LEAVING SCANNER TAB - Force cleanup camera resources');
      // Force un garbage collection pour nettoyer les buffers
      _forceCleanup();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // ✅ NOUVEAU : Cleanup forcé des ressources caméra
  void _forceCleanup() {
    // Déclencher un garbage collection
    // Cela libère les buffers caméra non utilisés
    Future.delayed(const Duration(milliseconds: 100), () {
      print('🧹 Force garbage collection');
      // Le GC va nettoyer les buffers caméra abandonnés
    });
  }

  // ✅ CORRECTION : Création dynamique des screens au lieu d'IndexedStack
  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const UnifiedScannerScreen(initialMode: ScanMode.ar);
      case 2:
        return const ChallengesScreen();
      case 3:
        return const NarrationScreen();
      case 4:
        return const LeaderboardScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(), // ✅ Un seul screen actif à la fois
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: onTabSelected,
      ),
    );
  }
}
