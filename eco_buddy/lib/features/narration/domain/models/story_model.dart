class StoryModel {
  final String id;
  final String sessionId;
  final String title;
  final String content;
  final List<String> choices;
  final List<int> choicePoints; // Points pour chaque choix
  final int chapterNumber;
  final int pointsEarned; // Points gagnés pour cette étape
  final int totalPoints;  // Points totaux de l'utilisateur
  final bool isCompleted;
  final String status;

  const StoryModel({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.content,
    required this.choices,
    required this.choicePoints,
    required this.chapterNumber,
    required this.pointsEarned,
    required this.totalPoints,
    this.isCompleted = false,
    this.status = 'success',
  });

  // Getter pour compatibilité avec l'ancien code
  int get points => pointsEarned;

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    // Parser les points pour chaque choix
    List<int> choicePoints = [];
    if (json['choicePoints'] != null) {
      choicePoints = List<int>.from(json['choicePoints']);
    } else {
      // Si pas défini, utiliser des valeurs par défaut selon le nombre de choix
      final choicesList = List<String>.from(json['choices'] ?? []);
      choicePoints = List.filled(choicesList.length, 15); // défaut 15 points
    }

    return StoryModel(
      id: json['id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      choicePoints: choicePoints,
      chapterNumber: json['chapterNumber'] ?? 1,
      pointsEarned: json['pointsEarned'] ?? json['points'] ?? 0,
      totalPoints: json['totalPoints'] ?? json['pointsEarned'] ?? json['points'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      status: json['status'] ?? 'success',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'title': title,
      'content': content,
      'choices': choices,
      'choicePoints': choicePoints,
      'chapterNumber': chapterNumber,
      'pointsEarned': pointsEarned,
      'totalPoints': totalPoints,
      'isCompleted': isCompleted,
      'status': status,
    };
  }

  StoryModel copyWith({
    String? id,
    String? sessionId,
    String? title,
    String? content,
    List<String>? choices,
    List<int>? choicePoints,
    int? chapterNumber,
    int? pointsEarned,
    int? totalPoints,
    bool? isCompleted,
    String? status,
  }) {
    return StoryModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      content: content ?? this.content,
      choices: choices ?? this.choices,
      choicePoints: choicePoints ?? this.choicePoints,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      totalPoints: totalPoints ?? this.totalPoints,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
    );
  }
}