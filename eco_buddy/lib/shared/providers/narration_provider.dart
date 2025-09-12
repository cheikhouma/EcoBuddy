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
      final choiceMade = currentState!.currentStory!.choices[choiceIndex];
      final nextStory = await _repository.makeChoice(
        currentState.sessionId!,
        choiceIndex,
      );

      // Afficher d'abord le dialogue avec les points gagnés
      state = AsyncValue.data(currentState.copyWith(
        showChoiceDialog: true,
        lastPointsEarned: nextStory.points,
        lastChoiceMade: choiceMade,
        totalPointsEarned: currentState.totalPointsEarned + nextStory.points,
        currentStory: nextStory, // Garde la nouvelle histoire en mémoire
        isCompleted: nextStory.choices.isEmpty,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void continueStory() {
    final currentState = state.value;
    if (currentState == null) return;

    // Si l'histoire est terminée, on affiche juste un récapitulatif final
    if (currentState.isCompleted) {
      // L'histoire est terminée, on garde le dialogue ouvert mais on change le contenu
      return;
    }

    // Fermer le dialogue et afficher la suite de l'histoire
    state = AsyncValue.data(currentState.copyWith(
      showChoiceDialog: false,
      lastPointsEarned: 0,
      lastChoiceMade: null,
    ));
  }

  void finishStory() {
    // Réinitialiser complètement l'état pour revenir à l'écran de démarrage
    state = const AsyncValue.data(NarrationState());
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
  final bool showChoiceDialog;
  final int lastPointsEarned;
  final String? lastChoiceMade;

  const NarrationState({
    this.currentStory,
    this.sessionId,
    this.totalPointsEarned = 0,
    this.isCompleted = false,
    this.showChoiceDialog = false,
    this.lastPointsEarned = 0,
    this.lastChoiceMade,
  });

  NarrationState copyWith({
    StoryModel? currentStory,
    String? sessionId,
    int? totalPointsEarned,
    bool? isCompleted,
    bool? showChoiceDialog,
    int? lastPointsEarned,
    String? lastChoiceMade,
  }) {
    return NarrationState(
      currentStory: currentStory ?? this.currentStory,
      sessionId: sessionId ?? this.sessionId,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      showChoiceDialog: showChoiceDialog ?? this.showChoiceDialog,
      lastPointsEarned: lastPointsEarned ?? this.lastPointsEarned,
      lastChoiceMade: lastChoiceMade ?? this.lastChoiceMade,
    );
  }
}