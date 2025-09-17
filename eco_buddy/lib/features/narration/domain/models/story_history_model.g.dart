// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryHistoryModel _$StoryHistoryModelFromJson(Map<String, dynamic> json) =>
    StoryHistoryModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      totalPoints: (json['totalPoints'] as num).toInt(),
      chapterCount: (json['chapterCount'] as num).toInt(),
      status: $enumDecode(_$StoryStatusEnumMap, json['status']),
      theme: json['theme'] as String,
    );

Map<String, dynamic> _$StoryHistoryModelToJson(StoryHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'title': instance.title,
      'summary': instance.summary,
      'completedAt': instance.completedAt.toIso8601String(),
      'totalPoints': instance.totalPoints,
      'chapterCount': instance.chapterCount,
      'status': _$StoryStatusEnumMap[instance.status]!,
      'theme': instance.theme,
    };

const _$StoryStatusEnumMap = {
  StoryStatus.completed: 'COMPLETED',
  StoryStatus.abandoned: 'ABANDONED',
};
