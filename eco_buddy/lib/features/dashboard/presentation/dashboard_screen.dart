import 'package:eco_buddy/features/leaderboard/domain/models/leaderboard_user_model.dart';
import 'package:eco_buddy/features/main/presentation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/leaderboard_provider.dart';
import '../../../shared/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/card_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting and profile
              _buildHeader(
                context,
                user?.username ?? AppLocalizations.of(context)!.user,
              ),
              const SizedBox(height: 24),

              // Location completion prompt
              FutureBuilder<bool>(
                future: _checkLocationStatus(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.data!) {
                    return Column(
                      children: [
                        _buildLocationPrompt(context),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Stats Cards Row
              _buildStatsRow(context, user?.points ?? 0),
              const SizedBox(height: 24),

              // Quick Actions Grid
              Text(
                AppLocalizations.of(context)!.quickActions,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Leaderboard Section
              _buildLeaderboardSection(context, ref),
              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivity(context),
              const SizedBox(height: 24),

              // Progress Section
              _buildProgressSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String username) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(AppConstants.primaryColor),
            Color(AppConstants.secondaryColor),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(context),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.continueEcologicalJourney,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, int points) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: AppLocalizations.of(context)!.totalPoints,
            value: points.toString(),
            icon: Icons.stars,
            color: const Color(AppConstants.accentColor),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: AppLocalizations.of(context)!.challengesCompleted,
            value: '12',
            icon: Icons.emoji_events,
            color: const Color(AppConstants.warningColor),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        QuickActionCard(
          title: AppLocalizations.of(context)!.arScanner,
          subtitle: AppLocalizations.of(context)!.discoverObjectImpact,
          icon: Icons.camera_alt,
          color: const Color(AppConstants.primaryColor),
          onTap: () => _navigateToTab(context, 3),
        ),
        QuickActionCard(
          title: AppLocalizations.of(context)!.newStory,
          subtitle: AppLocalizations.of(context)!.liveEcologicalAdventure,
          icon: Icons.auto_stories,
          color: const Color(AppConstants.secondaryColor),
          onTap: () => _navigateToTab(context, 1),
        ),
        QuickActionCard(
          title: AppLocalizations.of(context)!.dailyChallenges,
          subtitle: AppLocalizations.of(context)!.takeOnNewChallenges,
          icon: Icons.emoji_events,
          color: const Color(AppConstants.warningColor),
          onTap: () => _navigateToTab(context, 2),
        ),
        QuickActionCard(
          title: AppLocalizations.of(context)!.leaderboard,
          subtitle: AppLocalizations.of(context)!.seeYourPosition,
          icon: Icons.leaderboard,
          color: const Color(AppConstants.accentColor),
          onTap: () => _navigateToTab(context, 4),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.recentActivity,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          child: Column(
            children: [
              _buildActivityItem(
                Icons.camera_alt,
                AppLocalizations.of(context)!.plasticBottleScan,
                AppLocalizations.of(context)!.hoursAgo(2),
                AppLocalizations.of(context)!.plusPoints(5),
              ),
              const Divider(),
              _buildActivityItem(
                Icons.emoji_events,
                AppLocalizations.of(context)!.challengeRecyclingCompleted,
                AppLocalizations.of(context)!.daysAgo(1),
                AppLocalizations.of(context)!.plusPoints(20),
              ),
              const Divider(),
              _buildActivityItem(
                Icons.auto_stories,
                AppLocalizations.of(context)!.storyMagicalForestCompleted,
                AppLocalizations.of(context)!.daysAgo(2),
                AppLocalizations.of(context)!.plusPoints(15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String time,
    String points,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.primaryColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(AppConstants.primaryColor),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.progress,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ProgressCard(
          title: AppLocalizations.of(context)!.ecoCitizenLevel,
          progress: 0.6,
          progressText: '60%',
          color: const Color(AppConstants.primaryColor),
        ),
        const SizedBox(height: 16),
        ProgressCard(
          title: AppLocalizations.of(context)!.monthlyGoal,
          progress: 0.4,
          progressText: AppLocalizations.of(context)!.challengesGoal(8, 20),
          color: const Color(AppConstants.warningColor),
        ),
      ],
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppLocalizations.of(context)!.goodMorning;
    if (hour < 18) return AppLocalizations.of(context)!.goodAfternoon;
    return AppLocalizations.of(context)!.goodEvening;
  }

  Widget _buildLeaderboardSection(BuildContext context, WidgetRef ref) {
    final leaderboardState = ref.watch(leaderboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.leaderboard,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToTab(context, 4),
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: TextStyle(
                  color: Color(AppConstants.primaryColor),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        leaderboardState.when(
          data: (state) => _buildLeaderboardContent(context, state),
          loading: () => _buildLeaderboardLoading(context),
          error: (error, _) =>
              _buildLeaderboardError(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildLeaderboardContent(
    BuildContext context,
    LeaderboardState state,
  ) {
    if (state.topUsers.isEmpty) {
      return CustomCard(
        child: Column(
          children: [
            Icon(Icons.leaderboard_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.noLeaderboardData,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.completeChallengesForRanking,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return CustomCard(
      child: Column(
        children: [
          // Top 3 podium
          if (state.topUsers.length >= 3) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPodiumPosition(context, 2, state.topUsers[1]),
                _buildPodiumPosition(context, 1, state.topUsers[0]),
                _buildPodiumPosition(context, 3, state.topUsers[2]),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Rest of leaderboard
          ...state.topUsers
              .take(5)
              .map((user) => _buildLeaderboardRow(context, user)),

          if (state.topUsers.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.andOthers(state.topUsers.length - 5),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(
    BuildContext context,
    int position,
    LeaderboardUser user,
  ) {
    Color positionColor;
    double size;

    switch (position) {
      case 1:
        positionColor = const Color(0xFFFFD700); // Gold
        size = 80;
        break;
      case 2:
        positionColor = const Color(0xFFC0C0C0); // Silver
        size = 70;
        break;
      case 3:
        positionColor = const Color(0xFFCD7F32); // Bronze
        size = 60;
        break;
      default:
        positionColor = Colors.grey;
        size = 50;
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: positionColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(size / 2),
                border: Border.all(color: positionColor, width: 3),
              ),
              child: Center(
                child: Text(
                  user.username[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: positionColor,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: positionColor,
                  borderRadius: BorderRadius.circular(12.5),
                ),
                child: Center(
                  child: Text(
                    position.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.username,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          AppLocalizations.of(context)!.userPoints(user.points),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(BuildContext context, LeaderboardUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.primaryColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                user.rank.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.secondaryColor,
              ).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                user.username[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.secondaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)!.userPoints(user.points),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.accentColor),
                ),
              ),
              Text(
                AppLocalizations.of(
                  context,
                )!.userChallenges(user.challengesCompleted ?? 0),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardLoading(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(AppConstants.primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loadingLeaderboard,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardError(BuildContext context, String error) {
    return CustomCard(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.errorLoading,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    // Find the MainScreen and change tab
    if (context.mounted) {
      final mainScreenContext = context
          .findAncestorStateOfType<MainScreenState>();
      if (mainScreenContext != null) {
        mainScreenContext.onTabSelected(tabIndex);
      }
    }
  }

  Future<bool> _checkLocationStatus() async {
    try {
      return await ApiService.getLocationStatus();
    } catch (e) {
      return false; // En cas d'erreur, on considère que la localisation n'est pas complétée
    }
  }

  Widget _buildLocationPrompt(BuildContext context) {
    return CustomCard(
      backgroundColor: Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.completeProfile,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.addLocationForChallenges,
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Ignorer pour l'instant - on peut sauvegarder cette préférence
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.later),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/complete-profile');
                  },
                  label: Text(AppLocalizations.of(context)!.complete),
                  icon: const Icon(Icons.arrow_forward_ios_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.secondaryColor),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
