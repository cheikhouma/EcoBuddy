import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/storage_service.dart';
import '../../domain/models/scan_result_model.dart';

class ScannerRepository {
  Future<ScanResultModel> scanObject() async {
    try {
      final token = await StorageService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/scanner/scan'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'imageData': 'base64_mock_image_data',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ScanResultModel.fromJson(jsonData);
      } else {
        // Fallback to mock data if API fails
        return _getMockScanResult();
      }
    } catch (e) {
      // Simulate network delay and return mock data
      await Future.delayed(const Duration(seconds: 2));
      return _getMockScanResult();
    }
  }

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
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => ScanResultModel.fromJson(json)).toList();
      } else {
        // Fallback to mock data if API fails
        return _getMockScanHistory();
      }
    } catch (e) {
      // Return mock data for development
      return _getMockScanHistory();
    }
  }

  Future<void> saveResult(ScanResultModel result) async {
    try {
      final token = await StorageService.getToken();
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/scanner/save'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(result.toJson()),
      );
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> shareResult(ScanResultModel result) async {
    try {
      // Mock share functionality
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, this would integrate with platform sharing
      // For now, just simulate the API call
      final token = await StorageService.getToken();
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/scanner/share'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'scanResultId': result.id,
          'platform': 'social_media',
        }),
      );
    } catch (e) {
      // Handle error silently for now
    }
  }

  ScanResultModel _getMockScanResult() {
    final random = Random();
    final mockResults = [
      ScanResultModel(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Bouteille en plastique PET',
        carbonImpact: 2.5,
        recyclable: true,
        alternative: 'Utilisez une gourde réutilisable en acier inoxydable',
        description: 'Les bouteilles en plastique PET mettent entre 450 et 1000 ans pour se décomposer naturellement. Elles contribuent significativement à la pollution des océans et émettent des gaz à effet de serre lors de leur production.',
        ecoTips: 'Rincez la bouteille avant de la jeter dans le bac de tri, Séparez le bouchon du corps de la bouteille, Compressez la bouteille pour économiser l\'espace',
        pointsEarned: 5,
        scanDate: DateTime.now(),
        confidence: 0.95,
      ),
      ScanResultModel(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Smartphone',
        carbonImpact: 70.0,
        recyclable: true,
        alternative: 'Gardez votre téléphone plus longtemps (3-4 ans minimum)',
        description: 'La production d\'un smartphone génère environ 70 kg de CO2 et nécessite l\'extraction de métaux rares. L\'impact environnemental est considérable, surtout si l\'appareil est renouvelé fréquemment.',
        ecoTips: 'Apportez votre ancien téléphone dans un point de collecte agréé, Effacez toutes vos données personnelles avant le recyclage, Retirez la batterie si possible',
        pointsEarned: 10,
        scanDate: DateTime.now(),
        confidence: 0.88,
      ),
      ScanResultModel(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Sac en toile de jute',
        carbonImpact: 0.5,
        recyclable: true,
        alternative: 'Continuez à utiliser ce type de sac écologique !',
        description: 'La toile de jute est une fibre naturelle biodégradable qui nécessite peu d\'eau et de pesticides pour sa culture. C\'est une excellente alternative écologique aux sacs plastiques.',
        ecoTips: 'Réutilisez le sac tant qu\'il est en bon état, Compostez-le en fin de vie, Donnez-le à une association s\'il est encore utilisable',
        pointsEarned: 15,
        scanDate: DateTime.now(),
        confidence: 0.92,
      ),
    ];

    return mockResults[random.nextInt(mockResults.length)];
  }

  List<ScanResultModel> _getMockScanHistory() {
    final now = DateTime.now();
    return [
      ScanResultModel(
        id: 'history_001',
        name: 'Bouteille en plastique',
        carbonImpact: 2.5,
        recyclable: true,
        alternative: 'Utiliser une gourde réutilisable',
        description: 'Impact élevé sur l\'environnement.',
        ecoTips: 'Recycler dans la poubelle jaune',
        pointsEarned: 5,
        scanDate: now.subtract(const Duration(hours: 2)),
        confidence: 0.95,
      ),
      ScanResultModel(
        id: 'history_002',
        name: 'Sac en coton bio',
        carbonImpact: 0.3,
        recyclable: true,
        alternative: 'Continuer à utiliser ce type de sac',
        description: 'Excellent choix écologique !',
        ecoTips: 'Réutiliser autant que possible',
        pointsEarned: 15,
        scanDate: now.subtract(const Duration(days: 1)),
        confidence: 0.89,
      ),
      ScanResultModel(
        id: 'history_003',
        name: 'Canette en aluminium',
        carbonImpact: 1.8,
        recyclable: true,
        alternative: 'Boire dans des verres réutilisables',
        description: 'Recyclable à l\'infini mais énergivore à produire.',
        ecoTips: 'Recycler dans la poubelle de tri',
        pointsEarned: 8,
        scanDate: now.subtract(const Duration(days: 3)),
        confidence: 0.93,
      ),
    ];
  }
}