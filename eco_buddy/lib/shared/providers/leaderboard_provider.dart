import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/leaderboard/domain/models/leaderboard_user_model.dart';
import '../../features/leaderboard/data/repositories/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, AsyncValue<LeaderboardState>>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return LeaderboardNotifier(repository);
});

class LeaderboardNotifier extends StateNotifier<AsyncValue<LeaderboardState>> {
  final LeaderboardRepository _repository;
  String _currentPeriod = 'semaine';

  LeaderboardNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    state = const AsyncValue.loading();
    
    try {
      final users = await _repository.getLeaderboard(_currentPeriod);
      final topUsers = users.take(3).toList();
      
      state = AsyncValue.data(LeaderboardState(
        allUsers: users,
        topUsers: topUsers,
        period: _currentPeriod,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshLeaderboard() async {
    await loadLeaderboard();
  }

  Future<void> setPeriod(String period) async {
    if (_currentPeriod == period) return;
    
    _currentPeriod = period;
    await loadLeaderboard();
  }

  Future<LeaderboardUser?> getUserRank(String userId) async {
    try {
      return await _repository.getUserRank(userId, _currentPeriod);
    } catch (error) {
      return null;
    }
  }
}

class LeaderboardState {
  final List<LeaderboardUser> allUsers;
  final List<LeaderboardUser> topUsers;
  final String period;

  const LeaderboardState({
    this.allUsers = const [],
    this.topUsers = const [],
    this.period = 'semaine',
  });

  LeaderboardState copyWith({
    List<LeaderboardUser>? allUsers,
    List<LeaderboardUser>? topUsers,
    String? period,
  }) {
    return LeaderboardState(
      allUsers: allUsers ?? this.allUsers,
      topUsers: topUsers ?? this.topUsers,
      period: period ?? this.period,
    );
  }
}