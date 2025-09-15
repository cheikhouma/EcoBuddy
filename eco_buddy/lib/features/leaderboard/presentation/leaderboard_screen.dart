import 'package:eco_buddy/features/leaderboard/domain/models/leaderboard_user_model.dart';
import 'package:eco_buddy/l10n/app_localizations.dart';
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
      backgroundColor: const Color(0xFFFAFBFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: const Color(AppConstants.primaryColor),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Classement',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(AppConstants.primaryColor),
                          Color(AppConstants.secondaryColor),
                          Color(AppConstants.accentColor),
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.ecoChamp,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                color: Colors.white,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) =>
                    _handleMenuSelection(context, ref, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.refresh,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'filter',
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.filter,
                          style: TextStyle(color: Colors.black),
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
                  _buildUserRankCard(context, ref, authState.user!),
                const SizedBox(height: 20),

                // Period selector
                _buildPeriodSelector(context, ref),
                const SizedBox(height: 20),

                // Top 3 podium
                leaderboardState.when(
                  data: (state) => _buildPodium(context, state.topUsers),
                  loading: () => _buildLoadingPodium(),
                  error: (error, _) => _buildErrorWidget(error.toString()),
                ),
                const SizedBox(height: 24),

                // Full leaderboard
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(AppConstants.primaryColor),
                              Color(AppConstants.accentColor),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.fullLeaderboard,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
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
                          'Live',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(AppConstants.accentColor),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildUserRankCard(BuildContext context, WidgetRef ref, User user) {
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
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.pointsEarneds,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
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

  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodButton(
            AppLocalizations.of(context)!.week,
            true,
            ref,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPeriodButton(
            AppLocalizations.of(context)!.month,
            false,
            ref,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPeriodButton(
            AppLocalizations.of(context)!.year,
            false,
            ref,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String text, bool isSelected, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () => ref
            .read(leaderboardProvider.notifier)
            .setPeriod(text.toLowerCase()),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      Color(AppConstants.primaryColor),
                      Color(AppConstants.secondaryColor),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : const Color(
                      AppConstants.primaryColor,
                    ).withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(
                        AppConstants.primaryColor,
                      ).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : const Color(AppConstants.primaryColor),
              letterSpacing: 0.5,
            ),
            child: Text(text, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<LeaderboardUser> topUsers) {
    if (topUsers.length < 3) return Container();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Section title with trophy
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.top3,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Podium
          Container(
            height: 250,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Second place
                Expanded(child: _buildPodiumPosition(topUsers[1], 2, 70)),
                const SizedBox(width: 8),
                // First place
                Expanded(child: _buildPodiumPosition(topUsers[0], 1, 100)),
                const SizedBox(width: 8),
                // Third place
                if (topUsers.length > 2)
                  Expanded(child: _buildPodiumPosition(topUsers[2], 3, 50)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(LeaderboardUser user, int rank, double height) {
    Color primaryColor;
    Color secondaryColor;
    List<BoxShadow> shadows;
    String rankText;

    switch (rank) {
      case 1:
        primaryColor = const Color(0xFFFFD700);
        secondaryColor = const Color(0xFFFFA000);
        rankText = '🥇';
        shadows = [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case 2:
        primaryColor = const Color(0xFFC0C0C0);
        secondaryColor = const Color(0xFF9E9E9E);
        rankText = '🥈';
        shadows = [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ];
        break;
      case 3:
        primaryColor = const Color(0xFFCD7F32);
        secondaryColor = const Color(0xFFA0522D);
        rankText = '🥉';
        shadows = [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      default:
        primaryColor = Colors.grey[400]!;
        secondaryColor = Colors.grey[600]!;
        rankText = rank.toString();
        shadows = [];
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown and avatar section
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Glowing effect for winner
              if (rank == 1)
                Positioned(
                  top: -5,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // Avatar
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: shadows,
                  border: Border.all(color: Colors.white, width: 3),
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

              // Crown/Medal
              Positioned(
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(rankText, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Username
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.username,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),

          // Points with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.accentColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  size: 12,
                  color: const Color(AppConstants.accentColor),
                ),
                const SizedBox(width: 2),
                Text(
                  '${user.points}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.accentColor),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Podium base with gradient
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.8),
                  primaryColor.withValues(alpha: 0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rank.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  Text(
                    rank == 1
                        ? 'Winner'
                        : rank == 2
                        ? 'Runner'
                        : 'Third',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: secondaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
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
    Widget rankWidget = Text(rank.toString());

    if (rank <= 3) {
      switch (rank) {
        case 1:
          rankColor = const Color(0xFFFFD700);
          rankWidget = TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: const Text('🥇', style: TextStyle(fontSize: 20)),
              );
            },
          );
          break;
        case 2:
          rankColor = const Color(0xFFC0C0C0);
          rankWidget = TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: const Text('🥈', style: TextStyle(fontSize: 18)),
              );
            },
          );
          break;
        case 3:
          rankColor = const Color(0xFFCD7F32);
          rankWidget = TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: const Text('🥉', style: TextStyle(fontSize: 16)),
              );
            },
          );
          break;
      }
    } else {
      rankWidget = Text(
        rank.toString(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: rankColor,
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (rank * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: isCurrentUser ? 4 : 2,
                shadowColor: isCurrentUser
                    ? const Color(
                        AppConstants.primaryColor,
                      ).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: const Color(
                    AppConstants.primaryColor,
                  ).withValues(alpha: 0.1),
                  highlightColor: const Color(
                    AppConstants.primaryColor,
                  ).withValues(alpha: 0.05),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isCurrentUser
                          ? LinearGradient(
                              colors: [
                                const Color(
                                  AppConstants.primaryColor,
                                ).withValues(alpha: 0.1),
                                const Color(
                                  AppConstants.secondaryColor,
                                ).withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isCurrentUser ? null : Colors.white,
                      border: isCurrentUser
                          ? Border.all(
                              color: const Color(
                                AppConstants.primaryColor,
                              ).withValues(alpha: 0.3),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Rank with animation
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: rank <= 3
                                ? LinearGradient(
                                    colors: [
                                      rankColor.withValues(alpha: 0.2),
                                      rankColor.withValues(alpha: 0.1),
                                    ],
                                  )
                                : null,
                            color: rank > 3 ? Colors.grey[100] : null,
                            borderRadius: BorderRadius.circular(22),
                            border: rank <= 3
                                ? Border.all(
                                    color: rankColor.withValues(alpha: 0.4),
                                    width: 1.5,
                                  )
                                : Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                            boxShadow: rank <= 3
                                ? [
                                    BoxShadow(
                                      color: rankColor.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(child: rankWidget),
                        ),
                        const SizedBox(width: 16),

                        // Avatar with gradient and shadow
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: isCurrentUser
                                ? const LinearGradient(
                                    colors: [
                                      Color(AppConstants.primaryColor),
                                      Color(AppConstants.secondaryColor),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey[300]!,
                                      Colors.grey[100]!,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: isCurrentUser
                                    ? const Color(
                                        AppConstants.primaryColor,
                                      ).withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.username.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCurrentUser
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // User info with improved typography
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.username,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrentUser
                                            ? const Color(
                                                AppConstants.primaryColor,
                                              )
                                            : Colors.black87,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  if (isCurrentUser)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(AppConstants.accentColor),
                                            Color(AppConstants.primaryColor),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Vous',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (user.level != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Colors.amber[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Niveau ${user.level}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Points with enhanced design
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(AppConstants.accentColor),
                                    Color(AppConstants.primaryColor),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      AppConstants.accentColor,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.eco,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.points}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'éco-points',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),

                        // Tap indicator
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
                          children:
                              user.badges != null && user.badges!.isNotEmpty
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
