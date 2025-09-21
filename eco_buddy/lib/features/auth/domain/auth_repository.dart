import '../../../shared/models/auth_response.dart';
import '../../../shared/models/user.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String username, String password);
  Future<AuthResponse> signup(String username, String email, String password, int age);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<AuthResponse> updateProfile(String username, String email);
}