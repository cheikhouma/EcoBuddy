import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../../core/constants/app_constants.dart';
import 'dart:convert';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Token management
  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // User data management
  static Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: AppConstants.userKey, value: userJson);
  }

  static Future<User?> getUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Generic data storage for lists
  Future<void> saveList(String key, List<Map<String, dynamic>> data) async {
    final jsonString = jsonEncode(data);
    await _storage.write(key: key, value: jsonString);
  }

  Future<List<Map<String, dynamic>>?> getList(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> deleteKey(String key) async {
    await _storage.delete(key: key);
  }

  // Generic string storage methods for caching
  static Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  static Future<List<String>> getAllKeys() async {
    final allData = await _storage.readAll();
    return allData.keys.toList();
  }
}