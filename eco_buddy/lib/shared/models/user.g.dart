// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: _parseId(json['id']),
  username: json['username'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  points: _parseInt(json['points']),
  age: _parseNullableInt(json['age']),
  city: json['city'] as String?,
  country: json['country'] as String?,
  region: json['region'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isLocationCompleted: json['isLocationCompleted'] as bool?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'role': instance.role,
  'points': instance.points,
  'age': instance.age,
  'city': instance.city,
  'country': instance.country,
  'region': instance.region,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'isLocationCompleted': instance.isLocationCompleted,
};
