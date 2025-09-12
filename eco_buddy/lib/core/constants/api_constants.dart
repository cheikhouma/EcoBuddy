class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authSignup = '/auth/signup';

  // Narration endpoints
  static const String narrationStart = '/narration/start';
  static const String narrationChoice = '/narration/choice';

  // Challenges endpoints
  static const String challenges = '/challenges';
  static const String challengesComplete = '/challenges/complete';
  static const String challengesCompleted = '/challenges/completed';

  // Scanner endpoints
  static const String scannerObject = '/scanner/object';
  static const String scannerObjects = '/scanner/objects';
  static const String scannerObjectsSearch = '/scanner/objects/search';

  // Dashboard endpoints
  static const String dashboard = '/dashboard';
  static const String dashboardLeaderboard = '/dashboard/leaderboard';
}
