class LeaderboardUser {
  final String id;
  final String username;
  final int points;
  final int rank;
  final String? avatar;
  final int? level;
  final List<String>? badges;
  final int? challengesCompleted;
  final int? scansCompleted;
  final int? storiesCompleted;

  const LeaderboardUser({
    required this.id,
    required this.username,
    required this.points,
    required this.rank,
    this.avatar,
    this.level,
    this.badges,
    this.challengesCompleted,
    this.scansCompleted,
    this.storiesCompleted,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      points: json['points'] ?? 0,
      rank: json['rank'] ?? 0,
      avatar: json['avatar'],
      level: json['level'],
      badges: json['badges'] != null ? List<String>.from(json['badges']) : null,
      challengesCompleted: json['challengesCompleted'],
      scansCompleted: json['scansCompleted'],
      storiesCompleted: json['storiesCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'points': points,
      'rank': rank,
      'avatar': avatar,
      'level': level,
      'badges': badges,
      'challengesCompleted': challengesCompleted,
      'scansCompleted': scansCompleted,
      'storiesCompleted': storiesCompleted,
    };
  }

  LeaderboardUser copyWith({
    String? id,
    String? username,
    int? points,
    int? rank,
    String? avatar,
    int? level,
    List<String>? badges,
    int? challengesCompleted,
    int? scansCompleted,
    int? storiesCompleted,
  }) {
    return LeaderboardUser(
      id: id ?? this.id,
      username: username ?? this.username,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      avatar: avatar ?? this.avatar,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      scansCompleted: scansCompleted ?? this.scansCompleted,
      storiesCompleted: storiesCompleted ?? this.storiesCompleted,
    );
  }
}