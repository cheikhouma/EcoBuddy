import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/data/auth_repository_impl.dart';

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

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(user: user, isAuthenticated: true);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authRepository.login(username, password);
      final user = User(
        username: response.user.username,
        email: response.email,
        role: response.role,
        points: response.points,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
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
      final user = User(
        username: response.username,
        email: response.email,
        role: response.role,
        points: response.points,
        age: age,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState();
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
      final updatedUser = User(
        username: response.username,
        email: response.email,
        role: response.role,
        points: response.points,
        age: state.user?.age, // Keep existing age
      );

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
