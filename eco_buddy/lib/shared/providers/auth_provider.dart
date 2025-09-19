import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import 'narration_provider.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool registrationSuccess;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.registrationSuccess = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? registrationSuccess,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      registrationSuccess: registrationSuccess ?? this.registrationSuccess,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(user: user, isAuthenticated: true);

        // Recharger l'historique des histoires après la connexion
        _reloadNarrationHistory();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔍 Calling repository login...');
      final response = await _authRepository.login(username, password);
      print('✅ Repository response received');
      print('🔍 Response type: ${response.runtimeType}');
      print('🔍 Response user: ${response.user}');

      state = state.copyWith(
        user: response.user, // Utiliser directement l'objet User désérialisé
        isAuthenticated: true,
        isLoading: false,
      );
      print("********************");
      print(response);

      // Recharger l'historique des histoires après la connexion
      _reloadNarrationHistory();
    } catch (e) {
      print("********************");
      print(e);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signup(
    String username,
    String email,
    String password,
    int age,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authRepository.signup(
        username,
        email,
        password,
        age,
      );
      state = state.copyWith(
        user: response.user, // Utiliser directement l'objet User désérialisé
        isAuthenticated: false,
        isLoading: false,
        registrationSuccess: true,
      );

      // Recharger l'historique des histoires après l'inscription
      _reloadNarrationHistory();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState();

    // Nettoyer l'historique des histoires lors de la déconnexion
    _clearNarrationHistory();
  }

  void updateUserPoints(int newPoints) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(points: newPoints);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> updateProfile(String username, String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authRepository.updateProfile(username, email);
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearRegistrationSuccess() {
    state = state.copyWith(registrationSuccess: false);
  }

  /// Recharge l'historique des histoires via le NarrationProvider
  void _reloadNarrationHistory() {
    try {
      // Importer le provider et recharger l'historique de façon asynchrone
      Future.microtask(() async {
        try {
          final narrationNotifier = _ref.read(narrationProvider.notifier);
          await narrationNotifier.reloadStoryHistory();
        } catch (e) {
          // Log l'erreur silencieusement, ne pas bloquer l'auth
        }
      });
    } catch (e) {
      // Ignore les erreurs de rechargement pour ne pas affecter l'auth
    }
  }

  /// Vide l'historique des histoires lors de la déconnexion
  void _clearNarrationHistory() {
    try {
      Future.microtask(() {
        try {
          final narrationNotifier = _ref.read(narrationProvider.notifier);
          narrationNotifier.reset();
        } catch (e) {
          // Log l'erreur silencieusement
        }
      });
    } catch (e) {
      // Ignore les erreurs
    }
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepository, ref);
});
