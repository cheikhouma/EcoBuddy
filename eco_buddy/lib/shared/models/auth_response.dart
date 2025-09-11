import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String token;
  final String type;
  final int? expiresIn;      // Durée d'expiration en secondes
  final User user;           // Informations utilisateur complètes

  const AuthResponse({
    required this.token,
    this.type = 'Bearer',
    this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
  
  // Getters pour compatibilité avec l'ancien code
  String get username => user.username;
  String get email => user.email;
  String get role => user.role;
  int get points => user.points;
}