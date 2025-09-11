import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../../core/constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Future<Map<String, String>> get _authHeaders async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth API calls
  static Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authLogin}'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<AuthResponse> signup(String username, String email, String password, int age) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authSignup}'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'age': age,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to signup: ${response.body}');
    }
  }

  static Future<AuthResponse> updateProfile(String username, String email) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/auth/profile'),
      headers: await _authHeaders,
      body: jsonEncode({
        'username': username,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to update profile');
    }
  }

  static Future<AuthResponse> updateLocation({
    required String city,
    required String country,
    String? region,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/auth/location'),
      headers: await _authHeaders,
      body: jsonEncode({
        'city': city,
        'country': country,
        if (region != null) 'region': region,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to update location');
    }
  }

  static Future<bool> getLocationStatus() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/location-status'),
      headers: await _authHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isLocationCompleted'] ?? false;
    } else {
      throw Exception('Failed to get location status');
    }
  }

  // Generic API methods
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('GET $endpoint failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _authHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('POST $endpoint failed: ${response.body}');
    }
  }

  static Future<List<dynamic>> getList(String endpoint) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('GET $endpoint failed: ${response.body}');
    }
  }
}