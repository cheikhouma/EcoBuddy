import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AsyncValue<SettingsState>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(isDarkMode: enabled);
    state = AsyncValue.data(newState);

    try {
      await _repository.saveDarkMode(enabled);
    } catch (error) {
      // Revert on error
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> setNotifications(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(isNotificationsEnabled: enabled);
    state = AsyncValue.data(newState);

    try {
      await _repository.saveNotifications(enabled);
    } catch (error) {
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> setVibration(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(isVibrationEnabled: enabled);
    state = AsyncValue.data(newState);

    try {
      await _repository.saveVibration(enabled);
    } catch (error) {
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> setSound(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(isSoundEnabled: enabled);
    state = AsyncValue.data(newState);

    try {
      await _repository.saveSound(enabled);
    } catch (error) {
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> setDailyChallenges(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(isDailyChallengesEnabled: enabled);
    state = AsyncValue.data(newState);

    try {
      await _repository.saveDailyChallenges(enabled);
    } catch (error) {
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> setLeaderboard(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(isLeaderboardEnabled: enabled);
    state = AsyncValue.data(newState);

    try {
      await _repository.saveLeaderboard(enabled);
    } catch (error) {
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> setLanguage(String language) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(language: language);
    state = AsyncValue.data(newState);

    try {
      await _repository.saveLanguage(language);
    } catch (error) {
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> resetSettings() async {
    try {
      await _repository.resetSettings();
      await loadSettings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class SettingsState {
  final bool isDarkMode;
  final bool isNotificationsEnabled;
  final bool isVibrationEnabled;
  final bool isSoundEnabled;
  final bool isDailyChallengesEnabled;
  final bool isLeaderboardEnabled;
  final String language;
  final bool isLocationEnabled;
  final bool isDataSharingEnabled;

  const SettingsState({
    this.isDarkMode = false,
    this.isNotificationsEnabled = true,
    this.isVibrationEnabled = true,
    this.isSoundEnabled = true,
    this.isDailyChallengesEnabled = true,
    this.isLeaderboardEnabled = true,
    this.language = 'fr',
    this.isLocationEnabled = false,
    this.isDataSharingEnabled = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isNotificationsEnabled,
    bool? isVibrationEnabled,
    bool? isSoundEnabled,
    bool? isDailyChallengesEnabled,
    bool? isLeaderboardEnabled,
    String? language,
    bool? isLocationEnabled,
    bool? isDataSharingEnabled,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isDailyChallengesEnabled: isDailyChallengesEnabled ?? this.isDailyChallengesEnabled,
      isLeaderboardEnabled: isLeaderboardEnabled ?? this.isLeaderboardEnabled,
      language: language ?? this.language,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      isDataSharingEnabled: isDataSharingEnabled ?? this.isDataSharingEnabled,
    );
  }
}