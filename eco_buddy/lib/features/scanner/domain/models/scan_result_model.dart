enum EnvironmentalImpact { low, medium, high }

class ScanResultModel {
  // Backend ScanResponse.java fields - EXACT MAPPING
  final String name;
  final double? carbonImpact;
  final bool? recyclable;
  final String? alternative;
  final String? description;
  final String? ecoTips;
  final int pointsEarned;
  
  // Frontend-only fields
  final String id;
  final DateTime scanDate;
  final double confidence;
  final String? imageUrl;
  final String? objectType;
  final String? funFact;

  const ScanResultModel({
    required this.name,
    this.carbonImpact,
    this.recyclable,
    this.alternative,
    this.description,
    this.ecoTips,
    required this.pointsEarned,
    required this.id,
    required this.scanDate,
    this.confidence = 1.0,
    this.imageUrl,
    this.objectType,
    this.funFact,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      name: json['name'] ?? '',
      carbonImpact: json['carbonImpact']?.toDouble(),
      recyclable: json['recyclable'],
      alternative: json['alternative'],
      description: json['description'],
      ecoTips: json['ecoTips'],
      pointsEarned: json['pointsEarned'] ?? 0,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scanDate: DateTime.now(),
      confidence: 1.0,
      imageUrl: null,
      objectType: json['objectType'],
      funFact: json['funFact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'carbonImpact': carbonImpact,
      'recyclable': recyclable,
      'alternative': alternative,
      'description': description,
      'ecoTips': ecoTips,
      'pointsEarned': pointsEarned,
      'id': id,
      'scanDate': scanDate.toIso8601String(),
      'confidence': confidence,
      'imageUrl': imageUrl,
      'objectType': objectType,
      'funFact': funFact,
    };
  }

  ScanResultModel copyWith({
    String? name,
    double? carbonImpact,
    bool? recyclable,
    String? alternative,
    String? description,
    String? ecoTips,
    int? pointsEarned,
    String? id,
    DateTime? scanDate,
    double? confidence,
    String? imageUrl,
    String? objectType,
    String? funFact,
  }) {
    return ScanResultModel(
      name: name ?? this.name,
      carbonImpact: carbonImpact ?? this.carbonImpact,
      recyclable: recyclable ?? this.recyclable,
      alternative: alternative ?? this.alternative,
      description: description ?? this.description,
      ecoTips: ecoTips ?? this.ecoTips,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      id: id ?? this.id,
      scanDate: scanDate ?? this.scanDate,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      objectType: objectType ?? this.objectType,
      funFact: funFact ?? this.funFact,
    );
  }

  // UI compatibility getters
  String get objectName => name;
  int get points => pointsEarned;
  List<String> get alternatives => alternative != null ? [alternative!] : [];
  List<String> get recyclingSuggestions => ecoTips != null ? ecoTips!.split(',').map((s) => s.trim()).toList() : [];
  String get environmentalInfo => description ?? '';
  
  // AR Scanner compatibility getters
  double? get carbonFootprint => carbonImpact;
  double? get recyclingRate => recyclable == true ? 0.8 : (recyclable == false ? 0.1 : null);
  int? get biodegradabilityYears {
    if (objectType?.toLowerCase().contains('plastic') == true) return 450;
    if (objectType?.toLowerCase().contains('glass') == true) return 1000;
    if (objectType?.toLowerCase().contains('paper') == true) return 2;
    if (objectType?.toLowerCase().contains('metal') == true) return 80;
    return null;
  }
  
  EnvironmentalImpact get environmentalImpact {
    final carbon = carbonImpact ?? 0.0;
    if (carbon < 1.0) return EnvironmentalImpact.low;
    if (carbon < 10.0) return EnvironmentalImpact.medium;
    return EnvironmentalImpact.high;
  }
}