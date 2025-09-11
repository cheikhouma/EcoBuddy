class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int points;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final double? progress;
  final String? imageUrl;
  final List<String>? requirements;
  final String difficulty;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.progress,
    this.imageUrl,
    this.requirements,
    this.difficulty = 'medium',
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now();
    final durationDays = json['durationDays'] ?? 7;

    return ChallengeModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      points: json['points'] ?? 0,
      startDate: createdAt,
      endDate: createdAt.add(Duration(days: durationDays)),
      isCompleted: json['completed'] ?? false,
      progress: json['progress']?.toDouble(),
      imageUrl: json['imageUrl'],
      requirements: json['requirements']
          ?.split('|')
          .where((r) => r.isNotEmpty)
          .toList(),
      difficulty: json['difficulty'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
      'progress': progress,
      'imageUrl': imageUrl,
      'requirements': requirements,
      'difficulty': difficulty,
    };
  }

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? points,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    double? progress,
    String? imageUrl,
    List<String>? requirements,
    String? difficulty,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      imageUrl: imageUrl ?? this.imageUrl,
      requirements: requirements ?? this.requirements,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  bool get isActive => !isCompleted && DateTime.now().isBefore(endDate);
  bool get isExpired => !isCompleted && DateTime.now().isAfter(endDate);

  String get difficultyLabel {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Facile';
      case 'medium':
        return 'Moyen';
      case 'hard':
        return 'Difficile';
      default:
        return 'Moyen';
    }
  }
}
