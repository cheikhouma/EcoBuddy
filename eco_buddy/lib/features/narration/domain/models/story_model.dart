class StoryModel {
  final String id;
  final String sessionId;
  final String title;
  final String content;
  final List<String> choices;
  final int chapterNumber;
  final int points;
  final bool isCompleted;

  const StoryModel({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.content,
    required this.choices,
    required this.chapterNumber,
    required this.points,
    this.isCompleted = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      chapterNumber: json['chapterNumber'] ?? 1,
      points: json['points'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'title': title,
      'content': content,
      'choices': choices,
      'chapterNumber': chapterNumber,
      'points': points,
      'isCompleted': isCompleted,
    };
  }

  StoryModel copyWith({
    String? id,
    String? sessionId,
    String? title,
    String? content,
    List<String>? choices,
    int? chapterNumber,
    int? points,
    bool? isCompleted,
  }) {
    return StoryModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      content: content ?? this.content,
      choices: choices ?? this.choices,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}