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

    // ✅ ENGLISH VERSION: Complete mock database
    if (lowerLabel.contains('bottle') || lowerLabel.contains('bouteille')) {
      return {
        'name': 'Plastic Bottle',
        'carbonImpact': 2.5,
        'recyclable': true,
        'alternative': 'Reusable stainless steel or glass water bottle',
        'description': 'PET bottles take 450 years to decompose and release microplastics.',
        'ecoTips': 'Recycle in recycling bin, Remove cap and label, Rinse before recycling',
        'pointsEarned': 5,
        'objectType': 'plastic',
        'funFact': '1 million plastic bottles are purchased every minute worldwide!',
      };
    } else if (lowerLabel.contains('can') || lowerLabel.contains('canette')) {
      return {
        'name': 'Aluminum Can',
        'carbonImpact': 1.8,
        'recyclable': true,
        'alternative': 'Returnable glass bottle or water fountain',
        'description': 'Aluminum is infinitely recyclable without quality loss.',
        'ecoTips': 'Recycle in sorting bin, Empty completely, Crush to save space',
        'pointsEarned': 8,
        'objectType': 'metal',
        'funFact': 'Recycling a can saves 95% of the energy needed to manufacture it.',
      };
    } else if (lowerLabel.contains('bag') || lowerLabel.contains('sac')) {
      return {
        'name': 'Plastic Bag',
        'carbonImpact': 0.6,
        'recyclable': false,
        'alternative': 'Canvas bag, organic cotton or wicker basket',
        'description': 'Plastic bags pollute oceans and kill marine wildlife.',
        'ecoTips': 'Reuse multiple times, Bring to store for specialized recycling, Avoid single-use bags',
        'pointsEarned': 3,
        'objectType': 'plastic',
        'funFact': '500 billion plastic bags are used worldwide each year.',
      };
    } else if (lowerLabel.contains('cup') || lowerLabel.contains('tasse') || lowerLabel.contains('gobelet')) {
      return {
        'name': 'Disposable Cup',
        'carbonImpact': 1.2,
        'recyclable': false,
        'alternative': 'Reusable ceramic mug or cup',
        'description': 'Disposable cups have a plastic film that prevents recycling.',
        'ecoTips': 'Use your own cup, Choose porcelain when dining in',
        'pointsEarned': 4,
        'objectType': 'mixed',
        'funFact': 'A disposable cup takes 50 years to decompose.',
      };
    } else if (lowerLabel.contains('straw') || lowerLabel.contains('paille')) {
      return {
        'name': 'Plastic Straw',
        'carbonImpact': 0.3,
        'recyclable': false,
        'alternative': 'Bamboo, stainless steel or glass straw',
        'description': 'Plastic straws are a scourge for marine life.',
        'ecoTips': 'Refuse disposable straws, Use a reusable straw',
        'pointsEarned': 3,
        'objectType': 'plastic',
        'funFact': '500 million straws are used daily in the United States.',
      };
    } else if (lowerLabel.contains('phone') || lowerLabel.contains('téléphone') || lowerLabel.contains('mobile')) {
      return {
        'name': 'Mobile Phone',
        'carbonImpact': 70.0,
        'recyclable': true,
        'alternative': 'Refurbished phone or repair',
        'description': 'Rare metal extraction causes massive pollution.',
        'ecoTips': 'Repair instead of replacing, Donate or sell if functional, Recycle at store',
        'pointsEarned': 15,
        'objectType': 'electronic',
        'funFact': '1.4 billion phones are sold each year.',
      };
    } else if (lowerLabel.contains('battery') || lowerLabel.contains('pile')) {
      return {
        'name': 'Battery',
        'carbonImpact': 5.0,
        'recyclable': true,
        'alternative': 'Rechargeable batteries or battery-free devices',
        'description': 'Batteries contain toxic heavy metals.',
        'ecoTips': 'Drop at collection point, Never throw in trash, Choose rechargeable',
        'pointsEarned': 10,
        'objectType': 'electronic',
        'funFact': 'One discarded battery pollutes 1m³ of soil for 50 years.',
      };
    } else if (lowerLabel.contains('paper') || lowerLabel.contains('papier')) {
      return {
        'name': 'Paper',
        'carbonImpact': 0.8,
        'recyclable': true,
        'alternative': 'Digital version or recycled paper',
        'description': 'Paper can be recycled 5 to 7 times maximum.',
        'ecoTips': 'Sort in recycling bin, Remove staples and plastic, Use both sides',
        'pointsEarned': 2,
        'objectType': 'paper',
        'funFact': 'It takes 2-3 tons of wood to make 1 ton of paper.',
      };
    } else if (lowerLabel.contains('glass') || lowerLabel.contains('verre')) {
      return {
        'name': 'Glass Container',
        'carbonImpact': 1.5,
        'recyclable': true,
        'alternative': 'Reusable containers or bulk buying',
        'description': 'Glass is infinitely recyclable without quality loss.',
        'ecoTips': 'Recycle in glass container, Remove caps and lids, Reuse as jars',
        'pointsEarned': 6,
        'objectType': 'glass',
        'funFact': 'Recycling glass saves 30% energy compared to manufacturing.',
      };
    } else if (lowerLabel.contains('cigarette')) {
      return {
        'name': 'Cigarette Butt',
        'carbonImpact': 0.2,
        'recyclable': false,
        'alternative': 'Quit smoking or electronic cigarette',
        'description': 'Cigarette butts are the most widespread waste worldwide.',
        'ecoTips': 'Throw in trash, Use portable ashtray, Never litter',
        'pointsEarned': 1,
        'objectType': 'toxic',
        'funFact': '4.5 trillion cigarette butts are discarded worldwide each year.',
      };
    } else {
      return {
        'name': 'Detected Object',
        'carbonImpact': 1.0,
        'recyclable': true,
        'alternative': 'Look for sustainable alternatives',
        'description': 'Object with environmental impact to evaluate.',
        'ecoTips': 'Check local sorting guidelines, Prioritize reuse',
        'pointsEarned': 2,
        'objectType': 'unknown',
        'funFact': 'Every action counts to preserve our planet!',
      };
    }
  }

  /// Creates a fallback result in case of error
  ScanResultModel _createFallbackResult(String error) {
    return ScanResultModel(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Unidentified Object',
      description: 'Unable to analyze this object. Error: $error',
      ecoTips:
          'Check recycling symbols on object, Consult your local sorting center',
      alternative: 'Choose sustainable alternatives',
      pointsEarned: 1,
      scanDate: DateTime.now(),
      confidence: 0.0,
      objectType: 'unknown',
      funFact: 'Every action counts to preserve our planet!',
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
    // ✅ SYNCHRONISÉ avec unified_scanner_screen.dart
    const ecoKeywords = [
      // Contenants
      'bottle', 'bouteille', 'can', 'canette', 'jar', 'bocal',
      'container', 'conteneur', 'cup', 'tasse', 'glass', 'verre',
      'mug', 'gobelet', 'bowl', 'bol',

      // Emballages
      'bag', 'sac', 'box', 'boîte', 'package', 'paquet',
      'wrapper', 'emballage', 'carton', 'cardboard',
      'packaging', 'pack', 'pouch', 'sachet',

      // Matériaux
      'plastic', 'plastique', 'paper', 'papier', 'metal', 'métal',
      'aluminum', 'aluminium', 'steel', 'acier', 'wood', 'bois',
      'fabric', 'tissu', 'leather', 'cuir', 'rubber', 'caoutchouc',

      // Déchets et recyclage
      'trash', 'déchet', 'waste', 'garbage', 'ordure',
      'recyclable', 'compost', 'biodegradable',

      // Objets spécifiques
      'straw', 'paille', 'utensil', 'ustensile', 'plate', 'assiette',
      'fork', 'fourchette', 'spoon', 'cuillère', 'knife', 'couteau',
      'napkin', 'serviette', 'tissue', 'mouchoir',

      // Électronique
      'battery', 'pile', 'phone', 'téléphone', 'computer', 'ordinateur',
      'cable', 'câble', 'charger', 'chargeur',

      // Nouveaux objets courants
      'cigarette', 'mask', 'masque', 'filter', 'filtre',
      'pen', 'stylo', 'marker', 'marqueur', 'pencil', 'crayon',
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
