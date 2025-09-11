import 'package:eco_buddy/shared/providers/settings_provider.dart';

class SettingsRepository {
  // Mock storage - in a real app, this would use SharedPreferences or secure storage
  static final Map<String, dynamic> _storage = {
    'isDarkMode': false,
    'isNotificationsEnabled': true,
    'isVibrationEnabled': true,
    'isSoundEnabled': true,
    'isDailyChallengesEnabled': true,
    'isLeaderboardEnabled': true,
    'language': 'fr',
    'isLocationEnabled': false,
    'isDataSharingEnabled': false,
  };

  Future<SettingsState> getSettings() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return SettingsState(
      isDarkMode: _storage['isDarkMode'] ?? false,
      isNotificationsEnabled: _storage['isNotificationsEnabled'] ?? true,
      isVibrationEnabled: _storage['isVibrationEnabled'] ?? true,
      isSoundEnabled: _storage['isSoundEnabled'] ?? true,
      isDailyChallengesEnabled: _storage['isDailyChallengesEnabled'] ?? true,
      isLeaderboardEnabled: _storage['isLeaderboardEnabled'] ?? true,
      language: _storage['language'] ?? 'fr',
      isLocationEnabled: _storage['isLocationEnabled'] ?? false,
      isDataSharingEnabled: _storage['isDataSharingEnabled'] ?? false,
    );
  }

  Future<void> saveDarkMode(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['isDarkMode'] = enabled;
  }

  Future<void> saveNotifications(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['isNotificationsEnabled'] = enabled;
  }

  Future<void> saveVibration(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['isVibrationEnabled'] = enabled;
  }

  Future<void> saveSound(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['isSoundEnabled'] = enabled;
  }

  Future<void> saveDailyChallenges(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['isDailyChallengesEnabled'] = enabled;
  }

  Future<void> saveLeaderboard(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['isLeaderboardEnabled'] = enabled;
  }

  Future<void> saveLanguage(String language) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['language'] = language;
  }

  Future<void> saveLocation(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['isLocationEnabled'] = enabled;
  }

  Future<void> saveDataSharing(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage['isDataSharingEnabled'] = enabled;
  }

  Future<void> resetSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _storage.clear();
    _storage.addAll({
      'isDarkMode': false,
      'isNotificationsEnabled': true,
      'isVibrationEnabled': true,
      'isSoundEnabled': true,
      'isDailyChallengesEnabled': true,
      'isLeaderboardEnabled': true,
      'language': 'fr',
      'isLocationEnabled': false,
      'isDataSharingEnabled': false,
    });
  }
}
