import '../domain/auth_repository.dart';
import '../../../shared/models/auth_response.dart';
import '../../../shared/models/user.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthResponse> login(String username, String password) async {
    final response = await ApiService.login(username, password);
    
    // Save token and user data
    await StorageService.saveToken(response.token);
    await StorageService.saveUser(response.user);
    
    return response;
  }

  @override
  Future<AuthResponse> signup(String username, String email, String password, int age) async {
    final response = await ApiService.signup(username, email, password, age);
    
    // Save token and user data  
    await StorageService.saveToken(response.token);
    await StorageService.saveUser(response.user);
    
    return response;
  }

  @override
  Future<void> logout() async {
    await StorageService.clearAll();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await StorageService.getUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  @override
  Future<AuthResponse> updateProfile(String username, String email) async {
    final response = await ApiService.updateProfile(username, email);
    
    // Save new token and user data
    await StorageService.saveToken(response.token);
    await StorageService.saveUser(response.user);
    
    return response;
  }
}