import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(fromJson: _parseId)
  final int? id;  // Long backend → int (nullable pour compatibilité)
  final String username;
  final String email;
  final String role;  // Backend renvoie enum Role.name() comme String
  @JsonKey(fromJson: _parseInt)
  final int points;
  @JsonKey(fromJson: _parseNullableInt)
  final int? age;
  final String? city;
  final String? country;
  final String? region;
  final double? latitude;
  final double? longitude;
  final bool? isLocationCompleted;

  const User({
    this.id,  // ID optionnel car pas toujours fourni
    required this.username,
    required this.email,
    required this.role,
    required this.points,
    this.age,
    this.city,
    this.country,
    this.region,
    this.latitude,
    this.longitude,
    this.isLocationCompleted,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    int? points,
    int? age,
    String? city,
    String? country,
    String? region,
    double? latitude,
    double? longitude,
    bool? isLocationCompleted,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      points: points ?? this.points,
      age: age ?? this.age,
      city: city ?? this.city,
      country: country ?? this.country,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocationCompleted: isLocationCompleted ?? this.isLocationCompleted,
    );
  }
}

/// Parse id from various types (int, String, Long)
int? _parseId(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

/// Parse int from various types (int, String, num)
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  return 0;
}

/// Parse nullable int from various types
int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  return null;
}