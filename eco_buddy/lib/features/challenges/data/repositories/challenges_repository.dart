import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/storage_service.dart';
import '../../domain/models/challenge_model.dart';

class ChallengesRepository {
  Future<List<ChallengeModel>> getChallenges() async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/challenges'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => ChallengeModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> updateChallengeProgress(String challengeId) async {
    try {
      final token = await StorageService.getToken();
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/challenges/progress'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'challengeId': challengeId}),
      );
    } catch (e) {
      throw Exception('Failed to update challenge progress: $e');
    }
  }

  Future<Map<String, dynamic>> completeChallenge(String challengeId) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/challenges/complete'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'challengeId': challengeId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to complete challenge: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to complete challenge: $e');
    }
  }

}