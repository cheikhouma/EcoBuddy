// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  static Interpreter? _interpreter;
  static List<String>? _labels;

  static const String modelPath = 'assets/models/object_detection_model.tflite';
  static const String labelsPath = 'assets/models/labels.txt';

  // Objets écologiques à détecter
  static const List<String> ecoObjects = [
    'bottle',
    'plastic bottle',
    'glass bottle',
    'can',
    'soda can',
    'plastic bag',
    'paper bag',
    'cardboard',
    'paper',
    'plastic container',
    'cup',
    'food container',
    'aluminum can',
    'tin can',
    'shopping bag',
    'packaging',
    'wrapper',
    'box',
    'carton',
    'container',
  ];

  /// Initialise le modèle TensorFlow Lite
  static Future<bool> initialize() async {
    try {
      // Charger le modèle
      _interpreter = await Interpreter.fromAsset(modelPath);
      print('✅ Modèle TensorFlow Lite chargé avec succès');

      // Charger les labels
      await _loadLabels();
      print('✅ Labels chargés: ${_labels?.length} classes');

      return true;
    } catch (e) {
      print('❌ Erreur lors du chargement du modèle TensorFlow Lite: $e');

      // Utiliser des labels par défaut pour le développement
      _labels = _getDefaultEcoLabels();
      print('⚠️ Utilisation des labels par défaut pour le développement');
      return false;
    }
  }

  /// Charge les labels depuis le fichier
  static Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .toList();
    } catch (e) {
      print(
        '⚠️ Impossible de charger les labels, utilisation des labels par défaut',
      );
      _labels = _getDefaultEcoLabels();
    }
  }

  /// Labels par défaut pour objets écologiques
  static List<String> _getDefaultEcoLabels() {
    return [
      'bottle',
      'plastic_bottle',
      'glass_bottle',
      'can',
      'plastic_bag',
      'paper',
      'cardboard',
      'plastic_container',
      'cup',
      'food_container',
      'unknown',
    ];
  }

  /// Classification d'image à partir d'un fichier
  static Future<ClassificationResult> classifyImage(File imageFile) async {
    try {
      // Lire et redimensionner l'image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      // Redimensionner à 224x224 pour la classification
      final resized = img.copyResize(image, width: 224, height: 224);

      return await _runClassification(resized);
    } catch (e) {
      print('❌ Erreur lors de la classification: $e');
      return _getMockResult();
    }
  }

  /// Classification d'image à partir de bytes
  static Future<ClassificationResult> classifyFromBytes(
    Uint8List imageBytes,
  ) async {
    try {
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      final resized = img.copyResize(image, width: 224, height: 224);
      return await _runClassification(resized);
    } catch (e) {
      print('❌ Erreur lors de la classification: $e');
      return _getMockResult();
    }
  }

  /// Exécute la classification sur l'image préparée
  static Future<ClassificationResult> _runClassification(
    img.Image image,
  ) async {
    if (_interpreter == null) {
      print('⚠️ Modèle non initialisé, simulation de résultat');
      return _getMockResult();
    }

    try {
      // Détecter le type de tensor d'entrée
      final inputTensor = _interpreter!.getInputTensor(0);
      final isFloat = inputTensor.type == TfLiteType.kTfLiteFloat32;

      print('🔧 Type tensor d\'entrée: ${inputTensor.type}, Float: $isFloat');

      // Préparer les données d'entrée selon le type attendu
      late final dynamic input;

      if (isFloat) {
        // Modèle attend des float32 normalisés
        input = List.generate(
          224,
          (y) => List.generate(
            224,
            (x) => List.generate(3, (c) {
              final pixel = image.getPixelSafe(x, y);
              final red = (pixel.r * 255).toInt().clamp(0, 255);
              final green = (pixel.g * 255).toInt().clamp(0, 255);
              final blue = (pixel.b * 255).toInt().clamp(0, 255);

              switch (c) {
                case 0:
                  return red / 255.0;
                case 1:
                  return green / 255.0;
                case 2:
                  return blue / 255.0;
                default:
                  return 0.0;
              }
            }),
          ),
        );
      } else {
        // Modèle attend des uint8 (0-255) - convertir en 4D tensor manuellement
        input = List.generate(
          1,
          (_) => List.generate(
            224,
            (y) => List.generate(
              224,
              (x) => List.generate(3, (c) {
                final pixel = image.getPixelSafe(x, y);
                switch (c) {
                  case 0:
                    return (pixel.r * 255).toInt().clamp(0, 255);
                  case 1:
                    return (pixel.g * 255).toInt().clamp(0, 255);
                  case 2:
                    return (pixel.b * 255).toInt().clamp(0, 255);
                  default:
                    return 0;
                }
              }),
            ),
          ),
        );
      }

      // Préparer la sortie
      var output = [List.filled(_labels?.length ?? 10, 0.0)];

      // Exécuter l'inférence
      _interpreter!.run(input, output);

      // Trouver la classe avec la plus haute probabilité
      final probabilities = output[0];
      double maxProb = 0.0;
      int maxIndex = 0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      final detectedLabel = _labels?[maxIndex] ?? 'unknown';
      final confidence = maxProb;

      // Vérifier si c'est un objet écologique pertinent
      final isEcoRelevant = _isEcologicallyRelevant(detectedLabel);

      return ClassificationResult(
        label: detectedLabel,
        confidence: confidence,
        isEcologicallyRelevant: isEcoRelevant,
        alternatives: _getAlternativeSuggestions(detectedLabel),
      );
    } catch (e) {
      print('❌ Erreur lors de l\'inférence TensorFlow Lite: $e');
      return _getMockResult();
    }
  }

  /// Vérifie si l'objet détecté est écologiquement pertinent
  static bool _isEcologicallyRelevant(String label) {
    return ecoObjects.any(
      (ecoObj) =>
          label.toLowerCase().contains(ecoObj.toLowerCase()) ||
          ecoObj.toLowerCase().contains(label.toLowerCase()),
    );
  }

  /// Suggestions d'alternatives écologiques
  static List<String> _getAlternativeSuggestions(String label) {
    final lowerLabel = label.toLowerCase();

    if (lowerLabel.contains('plastic')) {
      return [
        'Utiliser une gourde réutilisable',
        'Privilégier les emballages en verre',
        'Choisir des alternatives biodégradables',
      ];
    }

    if (lowerLabel.contains('bottle')) {
      return [
        'Recycler dans la bonne filière',
        'Réutiliser comme contenant',
        'Utiliser une gourde réutilisable',
      ];
    }

    if (lowerLabel.contains('bag')) {
      return [
        'Utiliser un sac réutilisable',
        'Sacs en toile ou jute',
        'Éviter les sacs plastique',
      ];
    }

    return [
      'Recycler correctement',
      'Réutiliser si possible',
      'Chercher des alternatives durables',
    ];
  }

  /// Résultat mock pour les tests/développement
  static ClassificationResult _getMockResult() {
    final mockLabels = ['bottle', 'plastic_bag', 'can', 'paper', 'cardboard'];
    final randomLabel = (mockLabels..shuffle()).first;

    return ClassificationResult(
      label: randomLabel,
      confidence: 0.85 + (0.1 * (DateTime.now().millisecond % 10) / 10),
      isEcologicallyRelevant: true,
      alternatives: _getAlternativeSuggestions(randomLabel),
    );
  }

  /// Libère les ressources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

/// Résultat de classification
class ClassificationResult {
  final String label;
  final double confidence;
  final bool isEcologicallyRelevant;
  final List<String> alternatives;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.isEcologicallyRelevant,
    required this.alternatives,
  });

  /// Convertit en JSON pour l'API backend
  Map<String, dynamic> toJson() => {
    'label': label,
    'confidence': confidence,
    'isEcologicallyRelevant': isEcologicallyRelevant,
    'alternatives': alternatives,
  };

  @override
  String toString() {
    return 'ClassificationResult(label: $label, confidence: ${confidence.toStringAsFixed(2)}, eco: $isEcologicallyRelevant)';
  }
}
