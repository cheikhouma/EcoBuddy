// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  token: json['token'] as String,
  type: json['type'] as String? ?? 'Bearer',
  expiresIn: (json['expiresIn'] as num?)?.toInt(),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  storyHistory: (json['storyHistory'] as List<dynamic>?)
      ?.map((e) => StoryHistoryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'type': instance.type,
      'expiresIn': instance.expiresIn,
      'user': instance.user,
      'storyHistory': instance.storyHistory,
    };
