import 'package:eco_buddy/features/leaderboard/domain/models/leaderboard_user_model.dart';
import 'package:eco_buddy/features/main/presentation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              _buildHeader(context, user?.username ?? 'Utilisateur'),
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
              _buildStatsRow(user?.points ?? 0),
              const SizedBox(height: 24),

              // Quick Actions Grid
              const Text(
                'Actions rapides',
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
              _buildRecentActivity(),
              const SizedBox(height: 24),

              // Progress Section
              _buildProgressSection(),
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
                  _getGreeting(),
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
                  'Continuez votre parcours écologique !',
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

  Widget _buildStatsRow(int points) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Points totaux',
            value: points.toString(),
            icon: Icons.stars,
            color: const Color(AppConstants.accentColor),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Défis réalisés',
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
          title: 'Scanner AR',
          subtitle: 'Découvrez l\'impact de vos objets',
          icon: Icons.camera_alt,
          color: const Color(AppConstants.primaryColor),
          onTap: () => _navigateToTab(context, 3),
        ),
        QuickActionCard(
          title: 'Nouvelle histoire',
          subtitle: 'Vivez une aventure écologique',
          icon: Icons.auto_stories,
          color: const Color(AppConstants.secondaryColor),
          onTap: () => _navigateToTab(context, 1),
        ),
        QuickActionCard(
          title: 'Défis du jour',
          subtitle: 'Relevez de nouveaux défis',
          icon: Icons.emoji_events,
          color: const Color(AppConstants.warningColor),
          onTap: () => _navigateToTab(context, 2),
        ),
        QuickActionCard(
          title: 'Classement',
          subtitle: 'Voir votre position',
          icon: Icons.leaderboard,
          color: const Color(AppConstants.accentColor),
          onTap: () => _navigateToTab(context, 4),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité récente',
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
                'Scan d\'une bouteille plastique',
                'Il y a 2 heures',
                '+5 points',
              ),
              const Divider(),
              _buildActivityItem(
                Icons.emoji_events,
                'Défi "Recyclage" terminé',
                'Il y a 1 jour',
                '+20 points',
              ),
              const Divider(),
              _buildActivityItem(
                Icons.auto_stories,
                'Histoire "La Forêt Magique" complétée',
                'Il y a 2 jours',
                '+15 points',
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

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progression',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ProgressCard(
          title: 'Niveau Éco-Citoyen',
          progress: 0.6,
          progressText: '60%',
          color: const Color(AppConstants.primaryColor),
        ),
        const SizedBox(height: 16),
        ProgressCard(
          title: 'Objectif mensuel',
          progress: 0.4,
          progressText: '8/20 défis',
          color: const Color(AppConstants.warningColor),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  Widget _buildLeaderboardSection(BuildContext context, WidgetRef ref) {
    final leaderboardState = ref.watch(leaderboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Classement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToTab(context, 4),
              child: const Text(
                'Voir tout',
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
          data: (state) => _buildLeaderboardContent(state),
          loading: () => _buildLeaderboardLoading(),
          error: (error, _) => _buildLeaderboardError(error.toString()),
        ),
      ],
    );
  }

  Widget _buildLeaderboardContent(LeaderboardState state) {
    if (state.topUsers.isEmpty) {
      return CustomCard(
        child: Column(
          children: [
            Icon(Icons.leaderboard_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Aucune donnée de classement',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complétez des défis pour apparaître dans le classement !',
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
                _buildPodiumPosition(2, state.topUsers[1]),
                _buildPodiumPosition(1, state.topUsers[0]),
                _buildPodiumPosition(3, state.topUsers[2]),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Rest of leaderboard
          ...state.topUsers
              .take(5)
              .map((user) => _buildLeaderboardRow(user))
              .toList(),

          if (state.topUsers.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              'et ${state.topUsers.length - 5} autres...',
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

  Widget _buildPodiumPosition(int position, LeaderboardUser user) {
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
          '${user.points} pts',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(LeaderboardUser user) {
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
                '${user.points} pts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.accentColor),
                ),
              ),
              Text(
                '${user.challengesCompleted ?? 0} défis',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardLoading() {
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
            'Chargement du classement...',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardError(String error) {
    return CustomCard(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'Erreur de chargement',
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
      backgroundColor: const Color(AppConstants.secondaryColor).withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.secondaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complétez votre profil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Ajoutez votre localisation pour découvrir des défis près de chez vous !',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
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
                  ),
                  child: const Text('Plus tard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/complete-profile');
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Compléter'),
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
