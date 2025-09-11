import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/challenges/domain/models/challenge_model.dart';
import '../../features/challenges/data/repositories/challenges_repository.dart';

final challengesRepositoryProvider = Provider<ChallengesRepository>((ref) {
  return ChallengesRepository();
});

final challengesProvider = StateNotifierProvider<ChallengesNotifier, AsyncValue<ChallengesState>>((ref) {
  final repository = ref.watch(challengesRepositoryProvider);
  return ChallengesNotifier(repository);
});

class ChallengesNotifier extends StateNotifier<AsyncValue<ChallengesState>> {
  final ChallengesRepository _repository;

  ChallengesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    state = const AsyncValue.loading();
    
    try {
      final challenges = await _repository.getChallenges();
      final activeChallenges = challenges.where((c) => !c.isCompleted).toList();
      final completedChallenges = challenges.where((c) => c.isCompleted).toList();
      
      state = AsyncValue.data(ChallengesState(
        activeChallenges: activeChallenges,
        completedChallenges: completedChallenges,
        totalPoints: completedChallenges.fold(0, (sum, challenge) => sum + challenge.points),
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshChallenges() async {
    await loadChallenges();
  }

  Future<void> markChallengeProgress(String challengeId) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      await _repository.updateChallengeProgress(challengeId);
      await loadChallenges(); // Reload to get updated data
    } catch (error) {
      // Handle error silently for now
    }
  }

  Future<Map<String, dynamic>?> completeChallenge(String challengeId) async {
    final currentState = state.value;
    if (currentState == null) return null;

    try {
      final result = await _repository.completeChallenge(challengeId);
      await loadChallenges(); // Reload to get updated data
      return result;
    } catch (error) {
      rethrow; // Let the UI handle the error
    }
  }
}

class ChallengesState {
  final List<ChallengeModel> activeChallenges;
  final List<ChallengeModel> completedChallenges;
  final int totalPoints;

  const ChallengesState({
    this.activeChallenges = const [],
    this.completedChallenges = const [],
    this.totalPoints = 0,
  });

  ChallengesState copyWith({
    List<ChallengeModel>? activeChallenges,
    List<ChallengeModel>? completedChallenges,
    int? totalPoints,
  }) {
    return ChallengesState(
      activeChallenges: activeChallenges ?? this.activeChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}