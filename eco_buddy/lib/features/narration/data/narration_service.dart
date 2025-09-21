import 'package:eco_buddy/core/constants/api_constants.dart';
import 'package:eco_buddy/shared/services/api_service.dart';

class NarrationService {
  static Future<StoryResponse> startNarration() async {
    final response = await ApiService.get(ApiConstants.narrationStart);
    return StoryResponse.fromJson(response);
  }

  static Future<StoryResponse> makeChoice(
    String sessionId,
    String choice,
  ) async {
    final response = await ApiService.post(ApiConstants.narrationChoice, {
      'sessionId': sessionId,
      'choice': choice,
    });
    return StoryResponse.fromJson(response);
  }
}

class StoryResponse {
  final String sessionId;
  final String story;
  final List<String> choices;
  final int stepCount;
  final bool isCompleted;
  final int? pointsEarned;

  StoryResponse({
    required this.sessionId,
    required this.story,
    required this.choices,
    required this.stepCount,
    this.isCompleted = false,
    this.pointsEarned,
  });

  factory StoryResponse.fromJson(Map<String, dynamic> json) {
    return StoryResponse(
      sessionId: json['sessionId'] ?? '',
      story: json['story'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      stepCount: json['stepCount'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      pointsEarned: json['pointsEarned'],
    );
  }
}
