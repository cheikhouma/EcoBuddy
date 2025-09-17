import 'package:eco_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: AppLocalizations.of(context)!.home,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.camera_alt_outlined,
                activeIcon: Icons.camera_alt,
                label: AppLocalizations.of(context)!.arScanner,
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.emoji_events_outlined,
                activeIcon: Icons.emoji_events,
                label: AppLocalizations.of(context)!.challenges,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.auto_stories_outlined,
                activeIcon: Icons.auto_stories,
                label: AppLocalizations.of(context)!.stories,

                index: 3,
              ),
              _buildNavItem(
                icon: Icons.leaderboard_outlined,
                activeIcon: Icons.leaderboard,
                label: AppLocalizations.of(context)!.leaderboard,
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(AppConstants.primaryColor).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive
                    ? const Color(AppConstants.primaryColor)
                    : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isActive ? 12 : 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(AppConstants.primaryColor)
                    : Colors.grey[600],
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
