import 'package:eco_buddy/features/leaderboard/domain/models/leaderboard_user_model.dart';
import 'package:eco_buddy/shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/leaderboard_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/card_widget.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardState = ref.watch(leaderboardProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(AppConstants.primaryColor),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Classement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(AppConstants.primaryColor),
                      Color(AppConstants.secondaryColor),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.leaderboard, size: 80, color: Colors.white),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                color: Colors.white,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) =>
                    _handleMenuSelection(context, ref, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.black38),
                        SizedBox(width: 8),
                        Text(
                          'Actualiser',
                          style: TextStyle(color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'filter',
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.black38),
                        SizedBox(width: 8),
                        Text(
                          'Filtrer',
                          style: TextStyle(color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // User's rank card
                if (authState.user != null)
                  _buildUserRankCard(ref, authState.user!),
                const SizedBox(height: 20),

                // Period selector
                _buildPeriodSelector(ref),
                const SizedBox(height: 20),

                // Top 3 podium
                leaderboardState.when(
                  data: (state) => _buildPodium(state.topUsers),
                  loading: () => _buildLoadingPodium(),
                  error: (error, _) => _buildErrorWidget(error.toString()),
                ),
                const SizedBox(height: 24),

                // Full leaderboard
                const Text(
                  'Classement complet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                leaderboardState.when(
                  data: (state) => _buildLeaderboard(
                    context,
                    ref,
                    state.allUsers,
                    authState.user,
                  ),
                  loading: () => _buildLoadingLeaderboard(),
                  error: (error, _) => _buildErrorWidget(error.toString()),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: authState.user != null
          ? FloatingActionButton(
              onPressed: () {
                // Convertir User en LeaderboardUser pour le profil
                final leaderboardUser = LeaderboardUser(
                  id: authState.user!.username,
                  username: authState.user!.username,
                  points: authState.user!.points,
                  rank: 0, // Le rang sera récupéré dans le widget
                );
                _showUserProfile(context, ref, leaderboardUser);
              },
              backgroundColor: const Color(AppConstants.accentColor),
              foregroundColor: Colors.white,
              child: const Icon(Icons.person),
            )
          : null,
    );
  }

  Widget _buildUserRankCard(WidgetRef ref, User user) {
    // Obtenir le rang réel de l'utilisateur depuis l'API
    final leaderboardState = ref.watch(leaderboardProvider);

    return CustomCard(
      backgroundColor: const Color(
        AppConstants.primaryColor,
      ).withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(AppConstants.primaryColor),
                  Color(AppConstants.secondaryColor),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                user.username.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre position actuelle',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.accentColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: leaderboardState.when(
                  data: (state) {
                    // Trouver l'utilisateur actuel dans la liste
                    final currentUser = state.allUsers.firstWhere(
                      (leaderUser) => leaderUser.username == user.username,
                      orElse: () => const LeaderboardUser(
                        id: '',
                        username: '',
                        points: 0,
                        rank: 0,
                      ),
                    );

                    return Text(
                      currentUser.rank > 0
                          ? '#${currentUser.rank}'
                          : 'Non classé',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                  loading: () => const Text(
                    '...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  error: (_, __) => const Text(
                    'N/A',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${user.points} pts',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.accentColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref) {
    return Row(
      children: [
        Expanded(child: _buildPeriodButton('Semaine', true, ref)),
        const SizedBox(width: 8),
        Expanded(child: _buildPeriodButton('Mois', false, ref)),
        const SizedBox(width: 8),
        Expanded(child: _buildPeriodButton('Année', false, ref)),
      ],
    );
  }

  Widget _buildPeriodButton(String text, bool isSelected, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(leaderboardProvider.notifier).setPeriod(text.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(AppConstants.primaryColor)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(AppConstants.primaryColor),
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : const Color(AppConstants.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardUser> topUsers) {
    if (topUsers.length < 3) return Container();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 160,
        maxHeight: 200,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Second place
              _buildPodiumPosition(topUsers[1], 2, 40),
              const SizedBox(width: 6),
              // First place  
              _buildPodiumPosition(topUsers[0], 1, 60),
              const SizedBox(width: 6),
              // Third place
              if (topUsers.length > 2)
                _buildPodiumPosition(topUsers[2], 3, 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumPosition(LeaderboardUser user, int rank, double height) {
    Color rankColor;
    IconData crownIcon;

    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Gold
        crownIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Silver
        crownIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronze
        crownIcon = Icons.emoji_events;
        break;
      default:
        rankColor = Colors.grey;
        crownIcon = Icons.emoji_events;
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User avatar and crown
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: rankColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    user.username.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
              ),
              Icon(crownIcon, color: rankColor, size: 20),
            ],
          ),
          const SizedBox(height: 6),

          // Username
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Points
          Text(
            '${user.points} pts',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          const Spacer(),

          // Podium base
          Container(
            height: height.clamp(30.0, 80.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(
                color: rankColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(
    BuildContext context,
    WidgetRef ref,
    List<LeaderboardUser> users,
    User? currentUser,
  ) {
    return Column(
      children: users.asMap().entries.map((entry) {
        final index = entry.key;
        final user = entry.value;
        final isCurrentUser = currentUser?.username == user.username;

        return _buildLeaderboardItem(
          rank: index + 1,
          user: user,
          isCurrentUser: isCurrentUser,
          onTap: () => _showUserProfile(
            context,
            ref,
            user, // user est déjà de type LeaderboardUser
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required LeaderboardUser user,
    required bool isCurrentUser,
    required VoidCallback onTap,
  }) {
    Color rankColor = Colors.grey[600]!;
    if (rank <= 3) {
      switch (rank) {
        case 1:
          rankColor = const Color(0xFFFFD700);
          break;
        case 2:
          rankColor = const Color(0xFFC0C0C0);
          break;
        case 3:
          rankColor = const Color(0xFFCD7F32);
          break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        onTap: onTap,
        backgroundColor: isCurrentUser
            ? const Color(AppConstants.primaryColor).withValues(alpha: 0.1)
            : null,
        child: Row(
          children: [
            // Rank
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: rank <= 3
                    ? Border.all(color: rankColor, width: 1)
                    : null,
              ),
              child: Center(
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? const Color(
                        AppConstants.primaryColor,
                      ).withValues(alpha: 0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  user.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser
                        ? const Color(AppConstants.primaryColor)
                        : Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser
                          ? const Color(AppConstants.primaryColor)
                          : Colors.black87,
                    ),
                  ),
                  if (user.level != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Niveau ${user.level}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),

            // Points and badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.points}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.accentColor),
                  ),
                ),
                Text(
                  'points',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.person,
                color: Color(AppConstants.primaryColor),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPodium() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLoadingLeaderboard() {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return CustomCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(AppConstants.errorColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                error,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'refresh':
        ref.read(leaderboardProvider.notifier).refreshLeaderboard();
        break;
      case 'filter':
        _showFilterDialog(context, ref);
        break;
    }
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer le classement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Amis uniquement'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Région locale'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  void _showUserProfile(
    BuildContext context,
    WidgetRef ref,
    LeaderboardUser user,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile header
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(AppConstants.primaryColor),
                              Color(AppConstants.secondaryColor),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        '${user.points} points écologiques',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(AppConstants.accentColor),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats grid
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Défis',
                                '${user.challengesCompleted ?? 0}',
                                Icons.emoji_events,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatItem(
                                'Scans',
                                '${user.scansCompleted ?? 0}',
                                Icons.camera_alt,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatItem(
                                'Histoires',
                                '${user.storiesCompleted ?? 0}',
                                Icons.auto_stories,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Badges section
                      const Text(
                        'Badges obtenus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: user.badges != null && user.badges!.isNotEmpty
                              ? user.badges!
                                    .map(
                                      (badge) => _buildBadge(
                                        badge,
                                        _getBadgeIcon(badge),
                                        const Color(AppConstants.accentColor),
                                      ),
                                    )
                                    .toList()
                              : [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Aucun badge pour le moment',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(AppConstants.primaryColor), size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title, 
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge.toLowerCase()) {
      case 'recycleur':
      case 'recycleur pro':
        return Icons.recycling;
      case 'scanner':
      case 'scanner expert':
      case 'scanner pro':
      case 'scanner amateur':
        return Icons.camera_alt;
      case 'éco-guerrier':
      case 'éco-champion':
      case 'éco-citoyen':
        return Icons.eco;
      case 'défenseur':
      case 'défenseur nature':
        return Icons.shield;
      case 'éco-débutant':
        return Icons.start;
      default:
        return Icons.emoji_events;
    }
  }
}
