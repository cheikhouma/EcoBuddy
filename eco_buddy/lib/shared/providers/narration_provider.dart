import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/narration/domain/models/story_model.dart';
import '../../features/narration/data/repositories/narration_repository.dart';

final narrationRepositoryProvider = Provider<NarrationRepository>((ref) {
  return NarrationRepository();
});

final narrationProvider = StateNotifierProvider<NarrationNotifier, AsyncValue<NarrationState>>((ref) {
  final repository = ref.watch(narrationRepositoryProvider);
  return NarrationNotifier(repository);
});

class NarrationNotifier extends StateNotifier<AsyncValue<NarrationState>> {
  final NarrationRepository _repository;

  NarrationNotifier(this._repository) : super(const AsyncValue.data(NarrationState()));

  Future<void> startNewStory() async {
    state = const AsyncValue.loading();
    
    try {
      final story = await _repository.startNewStory();
      state = AsyncValue.data(NarrationState(
        currentStory: story,
        sessionId: story.sessionId,
        totalPointsEarned: 0,
        isCompleted: false,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> makeChoice(int choiceIndex) async {
    final currentState = state.value;
    if (currentState?.currentStory == null) return;

    state = const AsyncValue.loading();

    try {
      final nextStory = await _repository.makeChoice(
        currentState!.sessionId!,
        choiceIndex,
      );

      state = AsyncValue.data(currentState.copyWith(
        currentStory: nextStory,
        totalPointsEarned: currentState.totalPointsEarned + nextStory.points,
        isCompleted: nextStory.choices.isEmpty,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(NarrationState());
  }
}

class NarrationState {
  final StoryModel? currentStory;
  final String? sessionId;
  final int totalPointsEarned;
  final bool isCompleted;

  const NarrationState({
    this.currentStory,
    this.sessionId,
    this.totalPointsEarned = 0,
    this.isCompleted = false,
  });

  NarrationState copyWith({
    StoryModel? currentStory,
    String? sessionId,
    int? totalPointsEarned,
    bool? isCompleted,
  }) {
    return NarrationState(
      currentStory: currentStory ?? this.currentStory,
      sessionId: sessionId ?? this.sessionId,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}