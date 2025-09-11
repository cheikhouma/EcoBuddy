import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/storage_service.dart';
import '../../domain/models/story_model.dart';

class NarrationRepository {
  Future<StoryModel> startNewStory() async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.narrationStart}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return _parseBackendResponse(jsonData);
      } else {
        throw Exception('Failed to start story: ${response.body}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockStory();
    }
  }

  Future<StoryModel> makeChoice(String sessionId, int choiceIndex) async {
    try {
      final token = await StorageService.getToken();
      final currentStory = await _getCurrentStory(sessionId, choiceIndex);
      final choice = currentStory.choices[choiceIndex];
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.narrationChoice}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sessionId': sessionId,
          'choice': choice,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return _parseBackendResponse(jsonData);
      } else {
        throw Exception('Failed to process choice: ${response.body}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockNextStory(choiceIndex);
    }
  }

  Future<StoryModel> _getCurrentStory(String sessionId, int choiceIndex) async {
    // Pour le moment, retourne une histoire mock pour obtenir les choix
    return _getMockStory();
  }

  StoryModel _parseBackendResponse(Map<String, dynamic> json) {
    // Parse la réponse du backend au format API
    final story = json['story'] ?? '';
    final choices = List<String>.from(json['choices'] ?? []);
    
    return StoryModel(
      id: json['sessionId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      title: _extractTitle(story),
      content: _extractContent(story),
      choices: choices,
      chapterNumber: (json['stepCount'] ?? 0) + 1,
      points: json['pointsEarned'] ?? 0,
      isCompleted: json['isCompleted'] ?? choices.isEmpty,
    );
  }

  String _extractTitle(String storyText) {
    if (storyText.contains('Titre:')) {
      final parts = storyText.split('|');
      final titlePart = parts.first.trim();
      if (titlePart.startsWith('Titre:')) {
        return titlePart.substring(6).trim();
      }
    }
    return 'Histoire Interactive';
  }

  String _extractContent(String storyText) {
    if (storyText.contains('Situation:')) {
      final parts = storyText.split('|');
      for (String part in parts) {
        if (part.trim().startsWith('Situation:')) {
          return part.trim().substring(10).trim();
        }
      }
    }
    return storyText;
  }

  StoryModel _getMockStory() {
    return const StoryModel(
      id: 'story_001',
      sessionId: 'session_123',
      title: 'La Forêt Enchantée',
      content: 'Vous vous promenez dans une magnifique forêt lorsque vous découvrez une rivière polluée par des déchets plastiques. Des animaux de la forêt vous regardent avec espoir, semblant attendre votre aide. Que décidez-vous de faire ?',
      choices: [
        'Commencer immédiatement à ramasser les déchets pour nettoyer la rivière',
        'Retourner au village pour organiser une équipe de nettoyage plus importante',
        'Prendre des photos pour sensibiliser sur les réseaux sociaux avant d\'agir',
        'Étudier la source de pollution avant de prendre une décision'
      ],
      chapterNumber: 1,
      points: 10,
    );
  }

  StoryModel _getMockNextStory(int choiceIndex) {
    final stories = [
      // Choice 0: Direct action
      const StoryModel(
        id: 'story_002a',
        sessionId: 'session_123',
        title: 'L\'Action Immédiate',
        content: 'Votre action rapide inspire les animaux de la forêt ! Un écureuil et plusieurs oiseaux viennent vous aider. Ensemble, vous ramassez de nombreux déchets. La rivière commence à retrouver sa clarté, mais vous découvrez que la pollution vient d\'une usine en amont. Comment procédez-vous ?',
        choices: [
          'Aller directement confronter les responsables de l\'usine',
          'Documenter les preuves et contacter les autorités environnementales',
          'Organiser une manifestation pacifique devant l\'usine'
        ],
        chapterNumber: 2,
        points: 20,
      ),
      // Choice 1: Team organization
      const StoryModel(
        id: 'story_002b',
        sessionId: 'session_123',
        title: 'La Force du Groupe',
        content: 'Au village, votre appel mobilise 15 volontaires ! Équipés de sacs et d\'outils, vous retournez à la rivière. L\'efficacité de votre groupe impressionne même le maire qui se joint à vous. En quelques heures, la rivière est propre, mais vous réalisez l\'ampleur du problème de gestion des déchets dans la région.',
        choices: [
          'Proposer au maire un système de recyclage communautaire',
          'Créer une association de protection de l\'environnement local',
          'Organiser des sessions d\'éducation environnementale dans les écoles'
        ],
        chapterNumber: 2,
        points: 25,
      ),
      // Choice 2: Social media awareness
      const StoryModel(
        id: 'story_002c',
        sessionId: 'session_123',
        title: 'Le Pouvoir de la Sensibilisation',
        content: 'Vos photos deviennent virales ! Des milliers de personnes partagent votre message. Une ONG environnementale vous contacte pour collaborer, et même des célébrités relaient votre cause. Cependant, pendant ce temps, la rivière reste polluée.',
        choices: [
          'Utiliser cette notoriété pour organiser un grand événement de nettoyage',
          'Collaborer avec l\'ONG pour une campagne de sensibilisation plus large',
          'Retourner discrètement nettoyer la rivière vous-même'
        ],
        chapterNumber: 2,
        points: 15,
      ),
      // Choice 3: Investigation
      const StoryModel(
        id: 'story_002d',
        sessionId: 'session_123',
        title: 'L\'Enquête Révélatrice',
        content: 'Votre enquête révèle qu\'une usine textile déverse illégalement ses eaux usées dans la rivière depuis des mois. Vous découvrez aussi que plusieurs espèces locales sont menacées. Vous avez maintenant des preuves solides de cette pollution industrielle.',
        choices: [
          'Présenter vos preuves directement aux médias locaux',
          'Porter plainte auprès du tribunal administratif',
          'Négocier directement avec l\'entreprise pour trouver une solution'
        ],
        chapterNumber: 2,
        points: 30,
      ),
    ];

    if (choiceIndex >= 0 && choiceIndex < stories.length) {
      return stories[choiceIndex];
    }
    
    // Final story if choices are exhausted
    return const StoryModel(
      id: 'story_final',
      sessionId: 'session_123',
      title: 'Mission Accomplie !',
      content: 'Grâce à vos actions déterminées et réfléchies, la forêt a retrouvé sa beauté naturelle. Les animaux vous remercient, et votre exemple inspire d\'autres à protéger l\'environnement. Votre aventure écologique est un succès !',
      choices: [],
      chapterNumber: 3,
      points: 50,
      isCompleted: true,
    );
  }
}