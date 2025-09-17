// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/tflite_service.dart';
import '../../../shared/services/scan_cache_service.dart';
import '../domain/models/scan_result_model.dart';

class ScannerService {
  /// Scanne un objet à partir d'un fichier image
  Future<ScanResultModel> scanObject(File imageFile) async {
    try {
      // 1. Classification locale avec TensorFlow Lite
      final classificationResult = await TFLiteService.classifyImage(imageFile);
      print('🔍 Classification: ${classificationResult.toString()}');

      // 2. Envoyer au backend pour l'analyse écologique complète
      final backendResult = await _sendToBackend(
        classificationResult,
        imageFile,
      );

      return backendResult;
    } catch (e) {
      print('❌ Erreur lors du scan: $e');
      return _createFallbackResult(e.toString());
    }
  }

  /// Scanne à partir de bytes d'image (caméra en temps réel)
  Future<ScanResultModel> scanFromBytes(Uint8List imageBytes) async {
    try {
      // 1. Classification locale avec TensorFlow Lite
      final classificationResult = await TFLiteService.classifyFromBytes(
        imageBytes,
      );
      print('🔍 Classification temps réel: ${classificationResult.toString()}');

      // 2. Envoyer au backend pour l'analyse écologique
      final backendResult = await _sendBytesToBackend(
        classificationResult,
        imageBytes,
      );

      return backendResult;
    } catch (e) {
      print('❌ Erreur lors du scan temps réel: $e');
      return _createFallbackResult(e.toString());
    }
  }

  /// Scanne à partir d'une XFile (caméra)
  Future<ScanResultModel> scanFromXFile(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await scanFromBytes(bytes);
    } catch (e) {
      print('❌ Erreur lors du scan XFile: $e');
      return _createFallbackResult(e.toString());
    }
  }

  /// Scanne un objet avec MLKit (pour AR Scanner) - avec cache intelligent
  Future<ScanResultModel> scanObjectWithMLKit(
    String objectLabel,
    double confidence,
  ) async {
    try {
      // 🚀 1. Vérifier le cache d'abord (cache intelligent)
      final cachedResult = await ScanCacheService.getCachedResult(objectLabel);
      if (cachedResult != null) {
        print('🚀 Cache hit pour: $objectLabel');
        return cachedResult.copyWith(
          confidence: confidence, // Mise à jour avec confidence actuelle
          scanDate: DateTime.now(), // Mise à jour avec date actuelle
        );
      }

      print('🔍 Cache miss pour: $objectLabel - Appel API nécessaire');

      final token = await StorageService.getToken();

      final requestBody = {
        'objectLabel': objectLabel,
        'confidence': confidence,
        'isEcologicallyRelevant': _isEcologicallyRelevant(objectLabel),
        'alternatives': _getAlternativeSuggestions(objectLabel),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.scannerObject}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      ScanResultModel result;
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        result = ScanResultModel.fromJson(jsonData);
      } else {
        result = _createMockResultForLabel(objectLabel, confidence);
      }

      // 💾 2. Mettre en cache le résultat pour les prochaines fois
      await ScanCacheService.cacheResult(objectLabel, result);

      return result;
    } catch (e) {
      print('⚠️ Erreur MLKit scan: $e');
      final fallbackResult = _createMockResultForLabel(objectLabel, confidence);

      // Cache même les résultats de fallback pour éviter les appels répétés en cas d'erreur
      await ScanCacheService.cacheResult(objectLabel, fallbackResult);

      return fallbackResult;
    }
  }

  /// Envoie la classification au backend pour analyse complète
  Future<ScanResultModel> _sendToBackend(
    ClassificationResult classification,
    File imageFile,
  ) async {
    try {
      final token = await StorageService.getToken();

      // Convertir l'image en base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Préparer la requête
      final requestBody = {
        'objectLabel': classification.label,
        'confidence': classification.confidence,
        'isEcologicallyRelevant': classification.isEcologicallyRelevant,
        'alternatives': classification.alternatives,
        'imageData': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.scannerObject}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ScanResultModel.fromJson(jsonData);
      } else {
        print('⚠️ Erreur backend (${response.statusCode}): ${response.body}');
        return _createMockResultForLabel(
          classification.label,
          classification.confidence,
        );
      }
    } catch (e) {
      print('⚠️ Erreur communication backend: $e');
      return _createMockResultForLabel(
        classification.label,
        classification.confidence,
      );
    }
  }

  /// Envoie les bytes d'image au backend
  Future<ScanResultModel> _sendBytesToBackend(
    ClassificationResult classification,
    Uint8List imageBytes,
  ) async {
    try {
      final token = await StorageService.getToken();

      // Convertir en base64
      final base64Image = base64Encode(imageBytes);

      final requestBody = {
        'objectLabel': classification.label,
        'confidence': classification.confidence,
        'isEcologicallyRelevant': classification.isEcologicallyRelevant,
        'alternatives': classification.alternatives,
        'imageData': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.scannerObject}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ScanResultModel.fromJson(jsonData);
      } else {
        return _createMockResultForLabel(
          classification.label,
          classification.confidence,
        );
      }
    } catch (e) {
      return _createMockResultForLabel(
        classification.label,
        classification.confidence,
      );
    }
  }

  /// Crée un résultat mock basé sur le label détecté
  ScanResultModel _createMockResultForLabel(
    String objectLabel,
    double confidence,
  ) {
    final mockData = _getMockDataForLabel(objectLabel);
    return ScanResultModel(
      id: 'ar_${DateTime.now().millisecondsSinceEpoch}',
      name: mockData['name'],
      carbonImpact: mockData['carbonImpact'],
      recyclable: mockData['recyclable'],
      alternative: mockData['alternative'],
      description: mockData['description'],
      ecoTips: mockData['ecoTips'],
      pointsEarned: mockData['pointsEarned'],
      scanDate: DateTime.now(),
      confidence: confidence,
      objectType: mockData['objectType'],
      funFact: mockData['funFact'],
    );
  }

  Map<String, dynamic> _getMockDataForLabel(String label) {
    final lowerLabel = label.toLowerCase();

    if (lowerLabel.contains('bottle') || lowerLabel.contains('bouteille')) {
      return {
        'name': 'Bouteille en plastique',
        'carbonImpact': 2.5,
        'recyclable': true,
        'alternative': 'Utilisez une gourde réutilisable en acier inoxydable',
        'description':
            'Les bouteilles en plastique PET mettent 450 ans à se décomposer.',
        'ecoTips':
            'Recyclez dans le bac jaune, Retirez le bouchon avant recyclage',
        'pointsEarned': 5,
        'objectType': 'plastic',
        'funFact':
            '1 million de bouteilles plastique sont achetées chaque minute dans le monde.',
      };
    } else if (lowerLabel.contains('can') || lowerLabel.contains('canette')) {
      return {
        'name': 'Canette en aluminium',
        'carbonImpact': 1.8,
        'recyclable': true,
        'alternative': 'Buvez dans des verres réutilisables',
        'description':
            'L\'aluminium est recyclable à l\'infini sans perte de qualité.',
        'ecoTips':
            'Recyclez dans le bac de tri, Videz complètement avant recyclage',
        'pointsEarned': 8,
        'objectType': 'metal',
        'funFact':
            'Recycler une canette économise 95% de l\'énergie nécessaire pour la fabriquer.',
      };
    } else if (lowerLabel.contains('bag') || lowerLabel.contains('sac')) {
      return {
        'name': 'Sac plastique',
        'carbonImpact': 0.6,
        'recyclable': false,
        'alternative': 'Utilisez un sac en toile ou en coton bio',
        'description': 'Les sacs plastique polluent massivement les océans.',
        'ecoTips':
            'Réutilisez plusieurs fois, Apportez en magasin pour recyclage spécialisé',
        'pointsEarned': 3,
        'objectType': 'plastic',
        'funFact':
            '8 millions de tonnes de plastique finissent dans les océans chaque année.',
      };
    } else {
      return {
        'name': 'Objet détecté',
        'carbonImpact': 1.0,
        'recyclable': true,
        'alternative': 'Recherchez des alternatives durables',
        'description': 'Objet avec impact environnemental variable.',
        'ecoTips': 'Consultez les consignes de tri locales',
        'pointsEarned': 2,
        'objectType': 'unknown',
        'funFact': 'Chaque geste compte pour préserver notre planète !',
      };
    }
  }

  /// Crée un résultat de fallback en cas d'erreur
  ScanResultModel _createFallbackResult(String error) {
    return ScanResultModel(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Objet non identifié',
      description: 'Impossible d\'analyser cet objet. Erreur: $error',
      ecoTips:
          'Vérifiez les symboles de recyclage sur l\'objet, Consultez votre centre de tri local',
      alternative: 'Privilégiez des alternatives durables',
      pointsEarned: 1,
      scanDate: DateTime.now(),
      confidence: 0.0,
      objectType: 'unknown',
      funFact: 'Chaque geste compte pour préserver notre planète !',
    );
  }

  /// Sauvegarde un résultat de scan (fonctionnalité d'historique)
  Future<bool> saveResult(ScanResultModel result) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/scanner/save'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(result.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Erreur sauvegarde résultat: $e');
      return false;
    }
  }

  /// Récupère l'historique des scans
  Future<List<ScanResultModel>> getScanHistory() async {
    try {
      final token = await StorageService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/scanner/history'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => ScanResultModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('⚠️ Erreur récupération historique: $e');
      return [];
    }
  }

  /// Détermine si un objet détecté est écologiquement pertinent
  bool _isEcologicallyRelevant(String objectLabel) {
    const ecoKeywords = [
      'bottle',
      'can',
      'bag',
      'container',
      'cup',
      'box',
      'plastic',
      'glass',
      'paper',
      'cardboard',
      'packaging',
      'wrapper',
      'carton',
      'trash',
      'waste',
      'recyclable',
    ];

    final lowerLabel = objectLabel.toLowerCase();
    return ecoKeywords.any((keyword) => lowerLabel.contains(keyword));
  }

  /// Génère des suggestions d'alternatives pour les objets détectés
  List<String> _getAlternativeSuggestions(String objectLabel) {
    final lowerLabel = objectLabel.toLowerCase();

    if (lowerLabel.contains('bottle')) {
      return ['Gourde réutilisable', 'Bouteille en verre', 'Carafe filtrante'];
    } else if (lowerLabel.contains('bag')) {
      return ['Sac en toile', 'Sac en coton bio', 'Panier réutilisable'];
    } else if (lowerLabel.contains('cup')) {
      return ['Tasse réutilisable', 'Mug en céramique', 'Gobelet en bambou'];
    } else if (lowerLabel.contains('can')) {
      return ['Bouteille en verre', 'Carafe', 'Gourde en métal'];
    } else if (lowerLabel.contains('container')) {
      return ['Bocal en verre', 'Contenant en bambou', 'Boîte réutilisable'];
    } else {
      return ['Alternatives durables disponibles'];
    }
  }
}
