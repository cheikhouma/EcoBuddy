import 'package:json_annotation/json_annotation.dart';

part 'story_history_model.g.dart';

@JsonSerializable()
class StoryHistoryModel {
  final String id;
  final String sessionId;
  final String title;
  final String summary;
  final DateTime completedAt;
  final int totalPoints;
  final int chapterCount;
  final StoryStatus status;
  final String theme;

  const StoryHistoryModel({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.summary,
    required this.completedAt,
    required this.totalPoints,
    required this.chapterCount,
    required this.status,
    required this.theme,
  });

  factory StoryHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoryHistoryModelToJson(this);

  factory StoryHistoryModel.fromStoryModel({
    required String storyId,
    required String sessionId,
    required String title,
    required String content,
    required int totalPoints,
    required int chapterCount,
    required StoryStatus status,
    String? theme,
  }) {
    // Extraire les 100 premiers caractères comme résumé
    String summary = content.length > 100
        ? '${content.substring(0, 100)}...'
        : content;

    return StoryHistoryModel(
      id: storyId,
      sessionId: sessionId,
      title: title,
      summary: summary,
      completedAt: DateTime.now(),
      totalPoints: totalPoints,
      chapterCount: chapterCount,
      status: status,
      theme: theme ?? 'general',
    );
  }

  StoryHistoryModel copyWith({
    String? id,
    String? sessionId,
    String? title,
    String? summary,
    DateTime? completedAt,
    int? totalPoints,
    int? chapterCount,
    StoryStatus? status,
    String? theme,
  }) {
    return StoryHistoryModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      completedAt: completedAt ?? this.completedAt,
      totalPoints: totalPoints ?? this.totalPoints,
      chapterCount: chapterCount ?? this.chapterCount,
      status: status ?? this.status,
      theme: theme ?? this.theme,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(completedAt);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a $weeks semaine${weeks > 1 ? 's' : ''}";
    } else {
      final months = (difference.inDays / 30).floor();
      return "Il y a $months mois";
    }
  }

  String get themeDisplayName {
    switch (theme.toLowerCase()) {
      case 'transport':
        return 'Transport';
      case 'energy':
      case 'energie':
        return 'Énergie';
      case 'food':
      case 'alimentation':
        return 'Alimentation';
      case 'waste':
      case 'dechets':
        return 'Déchets';
      case 'water':
      case 'eau':
        return 'Eau';
      case 'biodiversity':
      case 'biodiversite':
        return 'Biodiversité';
      default:
        return 'Général';
    }
  }
}

enum StoryStatus {
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('ABANDONED')
  abandoned,
}

extension StoryStatusExtension on StoryStatus {
  String get displayName {
    switch (this) {
      case StoryStatus.completed:
        return 'Terminée';
      case StoryStatus.abandoned:
        return 'Abandonnée';
    }
  }

  String get icon {
    switch (this) {
      case StoryStatus.completed:
        return '✅';
      case StoryStatus.abandoned:
        return '⏸️';
    }
  }
}