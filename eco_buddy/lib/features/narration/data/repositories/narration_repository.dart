import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/exceptions/story_exceptions.dart';
import '../../domain/models/story_model.dart';
import '../../domain/models/story_history_model.dart';

class NarrationRepository {
  Future<StoryModel> startNewStory() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw const AuthenticationStoryException(
          'Vous devez être connecté pour démarrer une histoire',
        );
      }

      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.narrationStart}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const NetworkStoryException(
              'Timeout: Le service prend trop de temps à répondre',
            ),
          );

      return _handleResponse(response);
    } catch (e) {
      if (e is StoryException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkStoryException(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
          originalError: e,
        );
      } else {
        throw StoryException(
          'Une erreur inattendue s\'est produite: ${e.toString()}',
          originalError: e,
        );
      }
    }
  }

  Future<StoryModel> makeChoice(String sessionId, int choiceIndex) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw const AuthenticationStoryException(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      }

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.narrationChoice}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'sessionId': sessionId,
              'choice': choiceIndex.toString(),
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const NetworkStoryException(
              'Timeout: Le traitement du choix prend trop de temps',
            ),
          );

      return _handleResponse(response);
    } catch (e) {
      if (e is StoryException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkStoryException(
          'Impossible de traiter votre choix. Vérifiez votre connexion.',
          originalError: e,
        );
      } else {
        throw StoryException(
          'Erreur lors du traitement de votre choix: ${e.toString()}',
          originalError: e,
        );
      }
    }
  }

  StoryModel _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        return _parseBackendResponse(jsonData);
      } catch (e) {
        throw ParsingException(
          'Erreur lors de l\'analyse de la réponse du serveur',
          originalError: e,
        );
      }
    } else if (response.statusCode == 401) {
      throw const AuthenticationStoryException(
        'Votre session a expiré. Veuillez vous reconnecter.',
      );
    } else if (response.statusCode == 404) {
      throw const SessionExpiredException(
        'Session introuvable. Veuillez démarrer une nouvelle histoire.',
      );
    } else if (response.statusCode == 500) {
      throw const AIServiceException(
        'Le service d\'intelligence artificielle rencontre des difficultés. Réessayez dans quelques minutes.',
      );
    } else {
      throw NetworkStoryException(
        'Erreur du serveur (${response.statusCode}): ${response.body}',
      );
    }
  }

  StoryModel _parseBackendResponse(Map<String, dynamic> json) {
    // Parser la nouvelle structure de réponse unifiée
    try {
      // Parser les points pour chaque choix
      List<int> choicePoints = [];
      if (json['choicePoints'] != null) {
        choicePoints = List<int>.from(json['choicePoints']);
      } else {
        // Si pas défini, utiliser des valeurs par défaut selon le nombre de choix
        final choicesList = List<String>.from(json['choices'] ?? []);
        choicePoints = List.filled(choicesList.length, 15); // défaut 15 points
      }

      return StoryModel(
        id: json['id'] ?? json['sessionId'] ?? '',
        sessionId: json['sessionId'] ?? '',
        title: json['title'] ?? 'Aventure Écologique',
        content: json['content'] ?? json['story'] ?? '',
        choices: List<String>.from(json['choices'] ?? []),
        choicePoints: choicePoints,
        chapterNumber: json['chapterNumber'] ?? 1,
        pointsEarned: json['pointsEarned'] ?? json['points'] ?? 0,
        totalPoints:
            json['totalPoints'] ?? json['pointsEarned'] ?? json['points'] ?? 0,
        isCompleted: json['isCompleted'] ?? false,
        status: json['status'] ?? 'success',
      );
    } catch (e) {
      throw ParsingException(
        'Erreur lors de l\'analyse des données de l\'histoire',
        originalError: e,
      );
    }
  }

  // ========== MÉTHODES POUR L'HISTORIQUE ==========

  Future<List<StoryHistoryModel>> getStoryHistory({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw const AuthenticationStoryException(
          'Vous devez être connecté pour consulter l\'historique',
        );
      }

      final response = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}/narration/history?page=$page&size=$size',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const NetworkStoryException(
              'Timeout: Impossible de récupérer l\'historique',
            ),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> storiesJson = jsonData['stories'] ?? [];

        return storiesJson
            .map((json) => StoryHistoryModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw const AuthenticationStoryException(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      } else {
        throw NetworkStoryException(
          'Erreur lors de la récupération de l\'historique (${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is StoryException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkStoryException(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
          originalError: e,
        );
      } else {
        throw StoryException(
          'Erreur lors de la récupération de l\'historique: ${e.toString()}',
          originalError: e,
        );
      }
    }
  }

  Future<StoryHistoryModel> getStoryHistoryDetails(String sessionId) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw const AuthenticationStoryException(
          'Vous devez être connecté pour consulter les détails',
        );
      }

      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/narration/history/$sessionId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const NetworkStoryException(
              'Timeout: Impossible de récupérer les détails',
            ),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return StoryHistoryModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw const AuthenticationStoryException(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      } else if (response.statusCode == 404) {
        throw const SessionExpiredException(
          'Histoire introuvable dans l\'historique.',
        );
      } else {
        throw NetworkStoryException(
          'Erreur lors de la récupération des détails (${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is StoryException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkStoryException(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
          originalError: e,
        );
      } else {
        throw StoryException(
          'Erreur lors de la récupération des détails: ${e.toString()}',
          originalError: e,
        );
      }
    }
  }

  Future<StoryHistoryModel> saveStoryToHistory({
    required String sessionId,
    required String title,
    required String summary,
    required int totalPoints,
    required int chapterCount,
    required StoryStatus status,
    String? theme,
  }) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw const AuthenticationStoryException(
          'Vous devez être connecté pour sauvegarder l\'histoire',
        );
      }

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/narration/history'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'sessionId': sessionId,
              'title': title,
              'summary': summary,
              'totalPoints': totalPoints,
              'chapterCount': chapterCount,
              'status': status.name.toUpperCase(),
              'theme': theme ?? 'general',
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const NetworkStoryException(
              'Timeout: Impossible de sauvegarder l\'histoire',
            ),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return StoryHistoryModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw const AuthenticationStoryException(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      } else {
        throw NetworkStoryException(
          'Erreur lors de la sauvegarde (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (e is StoryException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkStoryException(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
          originalError: e,
        );
      } else {
        throw StoryException(
          'Erreur lors de la sauvegarde: ${e.toString()}',
          originalError: e,
        );
      }
    }
  }
}
