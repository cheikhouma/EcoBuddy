import 'package:eco_buddy/features/challenges/domain/models/challenge_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/challenges_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/card_widget.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesState = ref.watch(challengesProvider);

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
                'Défis Écologiques',
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
                  child: Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats overview
                _buildStatsOverview(ref),
                const SizedBox(height: 20),

                // Active challenges section
                _buildSectionHeader('Défis actifs'),
                const SizedBox(height: 12),
                challengesState.when(
                  data: (state) => _buildActiveChallenges(
                    context,
                    ref,
                    state.activeChallenges,
                  ),
                  loading: () => _buildLoadingChallenges(),
                  error: (error, _) => _buildErrorWidget(error.toString()),
                ),
                const SizedBox(height: 24),

                // Completed challenges section
                _buildSectionHeader('Défis terminés'),
                const SizedBox(height: 12),
                challengesState.when(
                  data: (state) => _buildCompletedChallenges(
                    context,
                    ref,
                    state.completedChallenges,
                  ),
                  loading: () => _buildLoadingChallenges(),
                  error: (error, _) => _buildErrorWidget(error.toString()),
                ),
                const SizedBox(height: 24),

                // Mini leaderboard
                _buildSectionHeader('Classement des défis'),
                const SizedBox(height: 12),
                _buildMiniLeaderboard(ref),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            ref.read(challengesProvider.notifier).refreshChallenges(),
        backgroundColor: const Color(AppConstants.accentColor),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh),
        label: const Text('Actualiser'),
      ),
    );
  }

  Widget _buildStatsOverview(WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Défis actifs',
            value: '5',
            icon: Icons.pending_actions,
            color: const Color(AppConstants.warningColor),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Défis réussis',
            value: '12',
            icon: Icons.check_circle,
            color: const Color(AppConstants.accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildActiveChallenges(
    BuildContext context,
    WidgetRef ref,
    List<ChallengeModel> challenges,
  ) {
    if (challenges.isEmpty) {
      return _buildEmptyState(
        'Aucun défi actif',
        'Tous vos défis sont terminés !',
      );
    }

    return Column(
      children: challenges
          .map(
            (challenge) =>
                _buildChallengeCard(context, ref, challenge, isActive: true),
          )
          .toList(),
    );
  }

  Widget _buildCompletedChallenges(
    BuildContext context,
    WidgetRef ref,
    List<ChallengeModel> challenges,
  ) {
    if (challenges.isEmpty) {
      return _buildEmptyState(
        'Aucun défi terminé',
        'Commencez vos premiers défis !',
      );
    }

    return Column(
      children: challenges
          .take(3)
          .map(
            (challenge) =>
                _buildChallengeCard(context, ref, challenge, isActive: false),
          )
          .toList(),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge, {
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: isActive
            ? () => _showChallengeDetails(context, ref, challenge)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        (isActive
                                ? const Color(AppConstants.primaryColor)
                                : const Color(AppConstants.accentColor))
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getChallengeIcon(challenge.category),
                    color: isActive
                        ? const Color(AppConstants.primaryColor)
                        : const Color(AppConstants.accentColor),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          AppConstants.accentColor,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${challenge.points}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(AppConstants.accentColor),
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getTimeRemaining(challenge.endDate),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (isActive && challenge.progress != null) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progression',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(challenge.progress! * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: challenge.progress!,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        challenge.progress! >= 1.0
                            ? const Color(AppConstants.accentColor)
                            : const Color(AppConstants.primaryColor),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniLeaderboard(WidgetRef ref) {
    return CustomCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top défis cette semaine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => {
                  // Navigate to full leaderboard (tab 4)
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLeaderboardItem(1, 'Emma L.', 245, Icons.emoji_events),
          _buildLeaderboardItem(2, 'Lucas M.', 189, Icons.emoji_events),
          _buildLeaderboardItem(3, 'Sophie K.', 156, Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    String name,
    int points,
    IconData icon,
  ) {
    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Gold
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Silver
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        rankColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(icon, size: 16, color: rankColor),
          const SizedBox(width: 4),
          Text(
            '$points pts',
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

  Widget _buildLoadingChallenges() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return CustomCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.eco, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
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

  Future<void> _completeChallenge(
    BuildContext context,
    WidgetRef ref,
    String challengeId,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(AppConstants.primaryColor),
            ),
          ),
        ),
      );

      final result = await ref
          .read(challengesProvider.notifier)
          .completeChallenge(challengeId);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (result != null) {
          // Show success dialog with points earned
          final pointsEarned = result['pointsEarned'] ?? 0;
          final totalPoints = result['totalPoints'] ?? 0;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.celebration,
                    color: Color(AppConstants.accentColor),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Défi terminé !',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Félicitations ! Vous avez terminé ce défi écologique.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(
                        AppConstants.accentColor,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(AppConstants.accentColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+$pointsEarned points gagnés !',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(AppConstants.accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total : $totalPoints points',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      color: Color(AppConstants.primaryColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: const Color(AppConstants.errorColor),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  IconData _getChallengeIcon(String category) {
    switch (category.toLowerCase()) {
      case 'recycling':
        return Icons.recycling;
      case 'energy':
        return Icons.bolt;
      case 'transport':
        return Icons.directions_bike;
      case 'water':
        return Icons.water_drop;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.eco;
    }
  }

  String _getTimeRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) return 'Expiré';

    if (difference.inDays > 0) {
      return '${difference.inDays}j restants';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h restantes';
    } else {
      return '${difference.inMinutes}min restantes';
    }
  }

  void _showChallengeDetails(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(
                                AppConstants.primaryColor,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getChallengeIcon(challenge.category),
                              color: const Color(AppConstants.primaryColor),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  challenge.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+${challenge.points} points',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(AppConstants.accentColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge.description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (challenge.progress != null) ...[
                        Text(
                          'Progression',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: challenge.progress!,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(AppConstants.primaryColor),
                            ),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(challenge.progress! * 100).toInt()}% complété',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  challenge.progress != null &&
                                      challenge.progress! < 1.0
                                  ? () => ref
                                        .read(challengesProvider.notifier)
                                        .markChallengeProgress(challenge.id)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  AppConstants.secondaryColor,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Progression',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  challenge.progress != null &&
                                      challenge.progress! >= 1.0
                                  ? () => _completeChallenge(
                                      context,
                                      ref,
                                      challenge.id,
                                    )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    challenge.progress != null &&
                                        challenge.progress! >= 1.0
                                    ? const Color(AppConstants.primaryColor)
                                    : Colors.grey[400],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    challenge.progress != null &&
                                            challenge.progress! >= 1.0
                                        ? Icons.check_circle
                                        : Icons.lock,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    challenge.progress != null &&
                                            challenge.progress! >= 1.0
                                        ? 'Terminer'
                                        : 'Verrouillé',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
}
