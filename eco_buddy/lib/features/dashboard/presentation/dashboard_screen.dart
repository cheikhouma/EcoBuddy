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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showLocationPrompt = true;
  Future<bool>? _locationStatusFuture;

  @override
  void initState() {
    super.initState();
    _locationStatusFuture = _checkLocationStatus();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Debug location completion status
    print('🔍 User location completed: ${user?.isLocationCompleted}');
    print('🔍 Show location prompt: $_showLocationPrompt');

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting and profile
              _buildHeader(
                context,
                user?.username.toUpperCase() ??
                    AppLocalizations.of(context)!.user,
              ),
              const SizedBox(height: 24),

              // Location completion prompt
              if (_showLocationPrompt && !(user?.isLocationCompleted ?? false))
                FutureBuilder<bool>(
                  future: _locationStatusFuture,
                  builder: (context, snapshot) {
                    // Si l'utilisateur local indique que c'est complété, ne pas montrer le prompt
                    if (user?.isLocationCompleted == true) {
                      return const SizedBox.shrink();
                    }

                    // Sinon, vérifier avec l'API
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
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(AppConstants.accentColor),
                            Color(AppConstants.primaryColor),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Statistics",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Stats Cards Row
              _buildStatsRow(context, user?.points ?? 0),
              const SizedBox(height: 24),

              // Quick Actions
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(AppConstants.primaryColor),
                            const Color(AppConstants.accentColor),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.quickActions,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppConstants.primaryColor),
            const Color(AppConstants.primaryColor).withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(
              AppConstants.primaryColor,
            ).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.continueEcologicalJourney,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/settings'),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTimeIcon(),
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTimeMessage(context),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
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
            value: '0',
            icon: Icons.emoji_events,
            color: const Color(AppConstants.warningColor),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: AppLocalizations.of(context)!.arScanner,
                subtitle: AppLocalizations.of(context)!.discoverObjectImpact,
                icon: Icons.camera_alt,
                color: const Color(AppConstants.primaryColor),
                onTap: () => _navigateToTab(context, 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: AppLocalizations.of(context)!.newStory,
                subtitle: AppLocalizations.of(context)!.liveEcologicalAdventure,
                icon: Icons.auto_stories,
                color: const Color(AppConstants.secondaryColor),
                onTap: () => _navigateToTab(context, 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: AppLocalizations.of(context)!.dailyChallenges,
                subtitle: AppLocalizations.of(context)!.takeOnNewChallenges,
                icon: Icons.emoji_events,
                color: const Color(AppConstants.warningColor),
                onTap: () => _navigateToTab(context, 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: AppLocalizations.of(context)!.leaderboard,
                subtitle: AppLocalizations.of(context)!.seeYourPosition,
                icon: Icons.leaderboard,
                color: const Color(AppConstants.accentColor),
                onTap: () => _navigateToTab(context, 4),
              ),
            ),
          ],
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              Center(child: Text("There is no recents activity for you.")),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            "There is no progress for you. Let's start a challenges to see your progress",
          ),
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

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour < 6) return Icons.nights_stay;
    if (hour < 12) return Icons.wb_sunny;
    if (hour < 18) return Icons.wb_sunny_outlined;
    return Icons.brightness_3;
  }

  String _getTimeMessage(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Calm night';
    if (hour < 12) return 'Productive morning';
    if (hour < 18) return 'Active afternoon';
    return 'Relaxing evening';
  }

  Widget _buildLeaderboardSection(BuildContext context, WidgetRef ref) {
    final leaderboardState = ref.watch(leaderboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(AppConstants.accentColor),
                      Color(AppConstants.primaryColor),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.leaderboard,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
            Icon(Icons.leaderboard_outlined, size: 40, color: Colors.grey[400]),
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
          // Simple list without podium
          ...state.topUsers
              .take(3)
              .map((user) => _buildSimpleLeaderboardRow(context, user)),

          if (state.topUsers.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.andOthers(state.topUsers.length - 3),
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

  Widget _buildSimpleLeaderboardRow(
    BuildContext context,
    LeaderboardUser user,
  ) {
    // Simple row inspired by login/signup simplicity
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Simple rank circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.primaryColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                user.rank.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Simple avatar
          const SizedBox(width: 12),

          // Username and points in simple layout
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.userPoints(user.points),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
      print('❌ Error checking location status: $e');
      return false; // En cas d'erreur, on considère que la localisation n'est pas complétée
    }
  }

  void _refreshLocationStatus() {
    setState(() {
      _locationStatusFuture = _checkLocationStatus();
    });
  }

  Widget _buildLocationPrompt(BuildContext context) {
    return CustomCard(
      backgroundColor: const Color.fromARGB(255, 220, 217, 217),
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
                    setState(() {
                      _showLocationPrompt = false;
                    });
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
                  onPressed: () async {
                    final result = await Navigator.of(
                      context,
                    ).pushNamed('/complete-profile');
                    if (result == true) {
                      // Profile was completed successfully, refresh location status
                      // Add a small delay to ensure server has processed the update
                      await Future.delayed(const Duration(milliseconds: 500));
                      setState(() {
                        _showLocationPrompt = false; // Hide immediately
                        _locationStatusFuture = _checkLocationStatus();
                      });

                      // Double check after a longer delay in case of server lag
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _locationStatusFuture = _checkLocationStatus();
                          });
                        }
                      });
                    }
                  },
                  label: Text(AppLocalizations.of(context)!.complete),
                  icon: const Icon(Icons.arrow_forward_ios_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.secondaryColor),
                    foregroundColor: Colors.white,
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
