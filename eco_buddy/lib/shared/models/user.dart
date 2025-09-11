import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;  // Ajout du champ ID manquant (nullable pour compatibilité)
  final String username;
  final String email;
  final String role;  // Backend renvoie enum Role.name() comme String
  final int points;
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