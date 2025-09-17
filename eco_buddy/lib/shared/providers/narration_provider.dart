import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/narration/domain/models/story_model.dart';
import '../../features/narration/domain/models/story_history_model.dart';
import '../../features/narration/data/repositories/narration_repository.dart';
import '../services/storage_service.dart';

final narrationRepositoryProvider = Provider<NarrationRepository>((ref) {
  return NarrationRepository();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final narrationProvider =
    StateNotifierProvider<NarrationNotifier, AsyncValue<NarrationState>>((ref) {
      final repository = ref.watch(narrationRepositoryProvider);
      final storage = ref.watch(storageServiceProvider);
      return NarrationNotifier(repository, storage);
    });

class NarrationNotifier extends StateNotifier<AsyncValue<NarrationState>> {
  final NarrationRepository _repository;
  final StorageService _storage;

  // 🛡️ PROTECTION CONTRE RACE CONDITIONS
  bool _isProcessingChoice = false;
  DateTime? _lastChoiceTime;
  static const Duration _minTimeBetweenChoices = Duration(milliseconds: 500);

  NarrationNotifier(this._repository, this._storage)
    : super(const AsyncValue.data(NarrationState())) {
    _loadStoryHistory();
  }

  Future<void> _loadStoryHistory() async {
    try {
      List<StoryHistoryModel> history = <StoryHistoryModel>[];

      // 1. D'abord essayer de charger depuis l'API backend
      try {
        history = await _repository.getStoryHistory();
        // Sauvegarder en local pour cache
        await _saveStoryHistoryLocal(history);
      } catch (e) {
        // 2. Si API échoue, charger depuis le stockage local
        final historyData = await _storage.getList('story_history');
        history =
            historyData
                ?.map((item) => StoryHistoryModel.fromJson(item))
                .toList() ??
            <StoryHistoryModel>[];
      }

      final currentState = state.value ?? const NarrationState();
      state = AsyncValue.data(currentState.copyWith(storyHistory: history));
    } catch (e) {
      // Si tout échoue, continuer avec une liste vide
    }
  }

  /// Recharge l'historique des histoires depuis le serveur
  /// À appeler après une connexion utilisateur pour récupérer ses données
  Future<void> reloadStoryHistory() async {
    try {
      await _loadStoryHistory();
    } catch (e) {
      // Log l'erreur mais ne bloque pas l'application
    }
  }

  Future<void> _saveStoryHistory(List<StoryHistoryModel> history) async {
    // SAUVEGARDE HYBRIDE : API Backend ET Stockage Local

    // 1. Sauvegarder localement (toujours)
    await _saveStoryHistoryLocal(history);

    // 2. Essayer de synchroniser avec le backend
    try {
      // Pour chaque histoire, essayer de la sauvegarder sur le serveur
      for (final story in history) {
        try {
          await _repository.saveStoryToHistory(
            sessionId: story.sessionId,
            title: story.title,
            summary: story.summary,
            totalPoints: story.totalPoints,
            chapterCount: story.chapterCount,
            status: story.status,
            theme: story.theme,
          );
        } catch (e) {
          // Si une histoire échoue, continuer avec les autres
        }
      }
    } catch (e) {
      // Si sync backend échoue, au moins on a le local
    }
  }

  Future<void> _saveStoryHistoryLocal(List<StoryHistoryModel> history) async {
    try {
      final historyData = history.map((item) => item.toJson()).toList();
      await _storage.saveList('story_history', historyData);
    } catch (e) {
      // Log l'erreur mais ne bloque pas l'app
    }
  }

  Future<void> startNewStory() async {
    // 🔍 DEBUG : Vérifier l'état avant de commencer
    final beforeHistory = state.value?.storyHistory ?? [];
    print('🚀 STARTING NEW STORY - Histoire avant: ${beforeHistory.length} éléments');
    beforeHistory.forEach((h) => print('  - ${h.title} (${h.id})'));

    state = const AsyncValue.loading();

    try {
      // ✅ CORRECTION : Préserver l'historique existant
      final currentHistory = state.value?.storyHistory ?? [];
      print('🔍 Histoire pendant loading: ${currentHistory.length} éléments');

      final story = await _repository.startNewStory();

      print('🔍 Histoire à préserver: ${beforeHistory.length} éléments');
      state = AsyncValue.data(
        NarrationState(
          currentStory: story,
          sessionId: story.sessionId,
          totalPointsEarned: 0,
          isCompleted: false,
          storyHistory: beforeHistory, // ✅ Utiliser l'historique d'AVANT le loading !
        ),
      );
      print('✅ NEW STORY STARTED - Histoire après: ${beforeHistory.length} éléments');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> makeChoice(int choiceIndex) async {
    // 🛡️ PROTECTION ANTI-SPAM : Vérifier si déjà en cours
    if (_isProcessingChoice) {
      print('🚫 Choice already being processed, ignoring double-tap');
      return;
    }

    // 🛡️ PROTECTION TEMPORELLE : Minimum 500ms entre choix
    final now = DateTime.now();
    if (_lastChoiceTime != null &&
        now.difference(_lastChoiceTime!) < _minTimeBetweenChoices) {
      print('🚫 Too fast! Please wait before making another choice');
      return;
    }

    // 🛡️ VALIDATION ÉTAT : Vérifier que l'histoire existe
    final currentState = state.value;
    if (currentState?.currentStory == null ||
        currentState!.currentStory!.choices.isEmpty ||
        choiceIndex >= currentState.currentStory!.choices.length) {
      print('🚫 Invalid choice or no story available');
      return;
    }

    // 🔒 VERROUILLER LE TRAITEMENT
    _isProcessingChoice = true;
    _lastChoiceTime = now;

    try {
      final choiceMade = currentState.currentStory!.choices[choiceIndex];

      // Récupérer les points pour ce choix spécifique
      int pointsForThisChoice = 15; // défaut
      if (choiceIndex < currentState.currentStory!.choicePoints.length) {
        pointsForThisChoice =
            currentState.currentStory!.choicePoints[choiceIndex];
      }

      // ✅ AFFICHER IMMÉDIATEMENT les points + indicateur traitement (UX optimisée)
      state = AsyncValue.data(
        currentState.copyWith(
          showChoiceDialog: true,
          lastPointsEarned: pointsForThisChoice,
          lastChoiceMade: choiceMade,
          totalPointsEarned:
              currentState.totalPointsEarned + pointsForThisChoice,
          isLoadingNextStory:
              true, // Marquer qu'on charge la prochaine histoire
          isProcessingChoice: true, // 🚀 INDICATEUR VISUEL pour l'UI
        ),
      );

      // 🚀 APPEL API en arrière-plan pour récupérer la suite
      print('🔄 Making API call to get next story...');
      final nextStory = await _repository.makeChoice(
        currentState.sessionId!,
        choiceIndex,
      );
      print('✅ Next story received: ${nextStory.title}');

      // ✅ MISE À JOUR ATOMIQUE de l'état final
      final finalState = state.value;
      if (finalState != null) {
        state = AsyncValue.data(
          finalState.copyWith(
            currentStory: nextStory,
            isCompleted: nextStory.choices.isEmpty,
            isLoadingNextStory: false, // Histoire chargée
            isProcessingChoice: false, // 🚀 TRAITEMENT TERMINÉ
          ),
        );
        print('✅ State updated with next story');
      }
    } catch (error, stackTrace) {
      // ❌ GESTION D'ERREUR : Restaurer état précédent si échec
      print('❌ Error making choice: $error');

      // Restaurer l'état précédent mais sans le dialogue ni le processing
      final errorState = state.value;
      if (errorState != null) {
        state = AsyncValue.data(
          errorState.copyWith(
            showChoiceDialog: false,
            isLoadingNextStory: false,
            isProcessingChoice: false,
            lastPointsEarned: 0,
            lastChoiceMade: null,
          ),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    } finally {
      // 🔓 DÉVERROUILLER dans tous les cas
      _isProcessingChoice = false;
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

    // ✅ CORRECTION : Ne plus bloquer sur isLoadingNextStory
    // Si la prochaine histoire n'est pas encore chargée, fermer quand même le dialogue
    // et laisser l'interface normale gérer le loading

    // Fermer le dialogue et afficher la suite de l'histoire
    state = AsyncValue.data(
      currentState.copyWith(
        showChoiceDialog: false,
        lastPointsEarned: 0,
        lastChoiceMade: null,
        isLoadingNextStory: false, // 🚀 Forcer à false pour éviter les blocages
      ),
    );
  }

  Future<void> finishStory() async {
    print('🏁 Finishing story...');
    final currentState = state.value;
    if (currentState == null) return;

    // 🔍 DEBUG : Vérifier l'historique avant finish
    print('🔍 Histoire avant finish: ${currentState.storyHistory?.length ?? 0} éléments');
    currentState.storyHistory?.forEach((h) => print('  - ${h.title} (${h.id})'));

    // 🚀 AFFICHER LE LOADER IMMÉDIATEMENT
    state = AsyncValue.data(currentState.copyWith(isFinishing: true));

    try {
      if (currentState.currentStory != null && currentState.sessionId != null) {
        try {
          print('💾 Saving story to history...');
          // Sauvegarder l'histoire dans l'historique
          await _saveCurrentStoryToHistory(StoryStatus.completed);
          print('✅ Story saved successfully');
        } catch (e) {
          print('❌ Failed to save story: $e');
          // Continue even if save fails - don't block the UI
        }
      }

      // Réinitialiser complètement l'état pour revenir à l'écran d'historique
      // ✅ CORRECTION : Utiliser l'état mis à jour après la sauvegarde
      final finalState = state.value;
      print('🔍 Histoire après sauvegarde: ${finalState?.storyHistory?.length ?? 0} éléments');
      finalState?.storyHistory?.forEach((h) => print('  - ${h.title} (${h.id})'));

      state = AsyncValue.data(
        NarrationState(storyHistory: finalState?.storyHistory ?? []),
      );
      print('✅ Story finished, returned to history screen with ${finalState?.storyHistory?.length ?? 0} stories');
    } catch (e) {
      print('❌ Error finishing story: $e');
      // En cas d'erreur, restaurer l'état mais sans le loader
      state = AsyncValue.data(currentState.copyWith(isFinishing: false));
    }
  }

  Future<void> abandonStory() async {
    final currentState = state.value;
    if (currentState?.currentStory != null && currentState?.sessionId != null) {
      // Sauvegarder l'histoire comme abandonnée
      await _saveCurrentStoryToHistory(StoryStatus.abandoned);
    }

    // Réinitialiser pour revenir à l'écran d'historique
    // ✅ CORRECTION : Utiliser l'état mis à jour après la sauvegarde
    final finalState = state.value;
    state = AsyncValue.data(
      NarrationState(storyHistory: finalState?.storyHistory ?? []),
    );
  }

  Future<void> _saveCurrentStoryToHistory(StoryStatus status) async {
    // ✅ CORRECTION : Récupérer l'état le plus récent au moment de la sauvegarde
    final currentState = state.value;
    if (currentState?.currentStory == null || currentState?.sessionId == null) {
      return;
    }

    final story = currentState!.currentStory!;

    // Créer l'entrée d'historique
    int storyId;
    try {
      storyId = int.parse(story.id);
    } catch (e) {
      print('❌ Failed to parse story ID: ${story.id}, using default');
      storyId =
          DateTime.now().millisecondsSinceEpoch; // Use timestamp as fallback
    }

    String theme;
    try {
      theme = _extractThemeFromContent(story.content);
    } catch (e) {
      print('❌ Failed to extract theme, using default');
      theme = 'general';
    }

    final historyEntry = StoryHistoryModel.fromStoryModel(
      storyId: storyId,
      sessionId: currentState.sessionId!,
      title: story.title,
      content: story.content,
      totalPoints: currentState.totalPointsEarned,
      chapterCount: story.chapterNumber,
      status: status,
      theme: theme,
    );

    // SAUVEGARDE HYBRIDE : Backend ET Local

    // 1. Sauvegarder immédiatement sur le serveur
    try {
      await _repository.saveStoryToHistory(
        sessionId: historyEntry.sessionId,
        title: historyEntry.title,
        summary: historyEntry.summary,
        totalPoints: historyEntry.totalPoints,
        chapterCount: historyEntry.chapterCount,
        status: historyEntry.status,
        theme: historyEntry.theme,
      );
    } catch (e) {
      // Si backend échoue, on continue avec le local
    }

    // 2. Ajouter à l'historique local - récupérer l'historique le plus récent
    final latestState = state.value; // Récupérer l'état le plus récent
    final currentHistory = latestState?.storyHistory ?? currentState.storyHistory ?? [];
    final List<StoryHistoryModel> updatedHistory = [
      historyEntry,
      ...currentHistory,
    ];
    if (updatedHistory.length > 50) {
      updatedHistory.removeRange(50, updatedHistory.length);
    }

    // 3. Sauvegarder localement
    await _saveStoryHistoryLocal(updatedHistory);

    // 4. Mettre à jour l'état
    print('🔍 Mise à jour de l\'état avec ${updatedHistory.length} histoires');
    updatedHistory.forEach((h) => print('  - ${h.title} (${h.id})'));
    state = AsyncValue.data(
      currentState.copyWith(storyHistory: updatedHistory),
    );
  }

  String _extractThemeFromContent(String content) {
    final contentLower = content.toLowerCase();

    if (contentLower.contains(
      RegExp(r'transport|voiture|vélo|bus|train|avion'),
    )) {
      return 'transport';
    } else if (contentLower.contains(
      RegExp(r'énergie|électricité|chauffage|solaire|éolienne'),
    )) {
      return 'energy';
    } else if (contentLower.contains(
      RegExp(r'nourriture|alimentation|bio|local|végétarien'),
    )) {
      return 'food';
    } else if (contentLower.contains(
      RegExp(r'déchet|recyclage|plastique|tri'),
    )) {
      return 'waste';
    } else if (contentLower.contains(RegExp(r'eau|robinet|douche|pluie'))) {
      return 'water';
    } else if (contentLower.contains(
      RegExp(r'nature|forêt|animal|biodiversité'),
    )) {
      return 'biodiversity';
    }

    return 'general';
  }

  void reset() {
    final currentState = state.value;
    state = AsyncValue.data(
      NarrationState(storyHistory: currentState?.storyHistory ?? []),
    );
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
  final List<StoryHistoryModel>? storyHistory;
  final bool isLoadingNextStory;
  final bool isProcessingChoice; // 🚀 NOUVEL INDICATEUR
  final bool isFinishing; // 🚀 NOUVEL INDICATEUR POUR FINISH

  const NarrationState({
    this.currentStory,
    this.sessionId,
    this.totalPointsEarned = 0,
    this.isCompleted = false,
    this.showChoiceDialog = false,
    this.lastPointsEarned = 0,
    this.lastChoiceMade,
    this.storyHistory,
    this.isLoadingNextStory = false,
    this.isProcessingChoice = false, // 🚀 DÉFAUT FAUX
    this.isFinishing = false, // 🚀 DÉFAUT FAUX
  });

  NarrationState copyWith({
    StoryModel? currentStory,
    String? sessionId,
    int? totalPointsEarned,
    bool? isCompleted,
    bool? showChoiceDialog,
    int? lastPointsEarned,
    String? lastChoiceMade,
    List<StoryHistoryModel>? storyHistory,
    bool? isLoadingNextStory,
    bool? isProcessingChoice, // 🚀 NOUVEAU PARAMÈTRE
    bool? isFinishing, // 🚀 NOUVEAU PARAMÈTRE POUR FINISH
  }) {
    return NarrationState(
      currentStory: currentStory ?? this.currentStory,
      sessionId: sessionId ?? this.sessionId,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      showChoiceDialog: showChoiceDialog ?? this.showChoiceDialog,
      lastPointsEarned: lastPointsEarned ?? this.lastPointsEarned,
      lastChoiceMade: lastChoiceMade ?? this.lastChoiceMade,
      storyHistory: storyHistory ?? this.storyHistory,
      isLoadingNextStory: isLoadingNextStory ?? this.isLoadingNextStory,
      isProcessingChoice:
          isProcessingChoice ?? this.isProcessingChoice, // 🚀 NOUVEAU
      isFinishing: isFinishing ?? this.isFinishing, // 🚀 NOUVEAU POUR FINISH
    );
  }

  // Getters utilitaires
  bool get hasActiveStory => currentStory != null;
  bool get hasHistory => storyHistory != null && storyHistory!.isNotEmpty;
  int get completedStoriesCount =>
      storyHistory
          ?.where((story) => story.status == StoryStatus.completed)
          .length ??
      0;
  int get totalHistoryPoints =>
      storyHistory?.fold<int>(0, (total, story) => total + story.totalPoints) ??
      0;
}
