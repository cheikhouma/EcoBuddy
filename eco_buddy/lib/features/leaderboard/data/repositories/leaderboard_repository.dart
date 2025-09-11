import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/storage_service.dart';
import '../../domain/models/leaderboard_user_model.dart';

class LeaderboardRepository {
  Future<List<LeaderboardUser>> getLeaderboard(String period) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/dashboard/leaderboard'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map(
              (json) => LeaderboardUser.fromJson({
                'id': json['username'], // Utiliser username comme ID
                'username': json['username'],
                'points': json['points'],
                'rank': json['rank'],
                'challengesCompleted': json['challengesCompleted'],
              }),
            )
            .toList();
      } else {
        // Si pas de données ou erreur API, retourner liste vide
        return [];
      }
    } catch (e) {
      // Retourner liste vide si erreur
      return [];
    }
  }

  Future<LeaderboardUser?> getUserRank(String userId, String period) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final currentUser = jsonData['currentUser'];
        if (currentUser != null) {
          return LeaderboardUser.fromJson({
            'id': currentUser['username'],
            'username': currentUser['username'],
            'points': currentUser['points'],
            'rank': currentUser['rank'],
            'challengesCompleted': currentUser['challengesCompleted'],
          });
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
