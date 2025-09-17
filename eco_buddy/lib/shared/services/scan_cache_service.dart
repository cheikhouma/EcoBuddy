import 'dart:convert';
import '../../features/scanner/domain/models/scan_result_model.dart';
import 'storage_service.dart';

class ScanCacheService {
  static final Map<String, _CachedResult> _memoryCache = {};
  static const Duration _cacheExpiry = Duration(hours: 6);
  static const Duration _memoryCacheExpiry = Duration(minutes: 30);
  static const String _cachePrefix = 'scan_cache_';
  static const int _maxMemoryCacheSize = 50;

  /// Gets cached result from memory first, then persistent storage
  static Future<ScanResultModel?> getCachedResult(String objectLabel) async {
    final String cacheKey = _sanitizeKey(objectLabel.toLowerCase());

    // Check memory cache first (fastest)
    final memoryCached = _memoryCache[cacheKey];
    if (memoryCached != null && !_isMemoryCacheExpired(memoryCached)) {
      print('🚀 Cache hit (memory): $objectLabel');
      return memoryCached.result;
    }

    // Check persistent storage cache
    try {
      final cachedJson = await StorageService.getString('$_cachePrefix$cacheKey');
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final DateTime cachedTime = DateTime.parse(cachedData['timestamp']);

        if (!_isPersistentCacheExpired(cachedTime)) {
          final result = ScanResultModel.fromJson(cachedData['result']);

          // Promote to memory cache
          _addToMemoryCache(cacheKey, result);

          print('🚀 Cache hit (storage): $objectLabel');
          return result;
        } else {
          // Remove expired cache
          await StorageService.remove('$_cachePrefix$cacheKey');
        }
      }
    } catch (e) {
      print('⚠️ Error reading cache for $objectLabel: $e');
    }

    return null;
  }

  /// Caches a scan result both in memory and persistent storage
  static Future<void> cacheResult(String objectLabel, ScanResultModel result) async {
    final String cacheKey = _sanitizeKey(objectLabel.toLowerCase());

    // Cache in memory
    _addToMemoryCache(cacheKey, result);

    // Cache in persistent storage
    try {
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'result': result.toJson(),
        'label': objectLabel,
      };

      await StorageService.setString('$_cachePrefix$cacheKey', jsonEncode(cacheData));
      print('💾 Cached result for: $objectLabel');
    } catch (e) {
      print('⚠️ Error caching result for $objectLabel: $e');
    }
  }

  /// Pre-cache common objects with mock data
  static Future<void> preloadCommonObjects() async {
    final commonObjects = [
      'bottle',
      'can',
      'bag',
      'plastic bottle',
      'water bottle',
      'soda can',
      'plastic bag',
      'paper',
      'cardboard',
      'cup',
      'container',
    ];

    for (final objectLabel in commonObjects) {
      final cached = await getCachedResult(objectLabel);
      if (cached == null) {
        // Create optimized mock result for common objects
        final mockResult = _createOptimizedMockResult(objectLabel);
        await cacheResult(objectLabel, mockResult);
      }
    }

    print('🚀 Preloaded ${commonObjects.length} common objects to cache');
  }

  /// Clear expired cache entries
  static Future<void> clearExpiredCache() async {
    try {
      final allKeys = await StorageService.getAllKeys();
      final cacheKeys = allKeys.where((key) => key.startsWith(_cachePrefix));

      int deletedCount = 0;
      for (final key in cacheKeys) {
        final cachedJson = await StorageService.getString(key);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson);
          final DateTime cachedTime = DateTime.parse(cachedData['timestamp']);

          if (_isPersistentCacheExpired(cachedTime)) {
            await StorageService.remove(key);
            deletedCount++;
          }
        }
      }

      // Clear expired memory cache
      _memoryCache.removeWhere((key, value) => _isMemoryCacheExpired(value));

      print('🧹 Cleared $deletedCount expired cache entries');
    } catch (e) {
      print('⚠️ Error clearing expired cache: $e');
    }
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final allKeys = await StorageService.getAllKeys();
      final cacheKeys = allKeys.where((key) => key.startsWith(_cachePrefix));

      for (final key in cacheKeys) {
        await StorageService.remove(key);
      }

      _memoryCache.clear();

      print('🧹 Cleared all scan cache');
    } catch (e) {
      print('⚠️ Error clearing all cache: $e');
    }
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final allKeys = await StorageService.getAllKeys();
      final cacheKeys = allKeys.where((key) => key.startsWith(_cachePrefix));

      int totalCached = 0;
      int expiredCount = 0;

      for (final key in cacheKeys) {
        totalCached++;
        final cachedJson = await StorageService.getString(key);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson);
          final DateTime cachedTime = DateTime.parse(cachedData['timestamp']);

          if (_isPersistentCacheExpired(cachedTime)) {
            expiredCount++;
          }
        }
      }

      return {
        'totalCached': totalCached,
        'memoryCached': _memoryCache.length,
        'expiredCount': expiredCount,
        'cacheHitRate': _getCacheHitRate(),
        'cacheExpiry': _cacheExpiry.inHours,
        'memoryCacheExpiry': _memoryCacheExpiry.inMinutes,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Private helper methods

  static String _sanitizeKey(String key) {
    return key
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  static bool _isPersistentCacheExpired(DateTime cachedTime) {
    return DateTime.now().difference(cachedTime) > _cacheExpiry;
  }

  static bool _isMemoryCacheExpired(_CachedResult cached) {
    return DateTime.now().difference(cached.timestamp) > _memoryCacheExpiry;
  }

  static void _addToMemoryCache(String key, ScanResultModel result) {
    // Implement LRU eviction if cache is full
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      final oldestKey = _memoryCache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _memoryCache.remove(oldestKey);
    }

    _memoryCache[key] = _CachedResult(
      result: result,
      timestamp: DateTime.now(),
    );
  }

  static double _getCacheHitRate() {
    // This would be implemented with proper analytics
    return 0.0;
  }

  static ScanResultModel _createOptimizedMockResult(String objectLabel) {
    final lowerLabel = objectLabel.toLowerCase();

    if (lowerLabel.contains('bottle')) {
      return ScanResultModel(
        id: 'cache_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Bouteille en plastique',
        carbonImpact: 2.5,
        recyclable: true,
        alternative: 'Utilisez une gourde réutilisable',
        description: 'Les bouteilles plastique mettent 450 ans à se décomposer.',
        ecoTips: 'Recyclez dans le bac jaune',
        pointsEarned: 5,
        scanDate: DateTime.now(),
        confidence: 0.85,
        objectType: 'plastic',
        funFact: '1 million de bouteilles sont achetées chaque minute.',
      );
    } else if (lowerLabel.contains('can')) {
      return ScanResultModel(
        id: 'cache_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Canette en aluminium',
        carbonImpact: 1.8,
        recyclable: true,
        alternative: 'Buvez dans des verres réutilisables',
        description: 'L\'aluminium est recyclable à l\'infini.',
        ecoTips: 'Recyclez dans le bac de tri',
        pointsEarned: 8,
        scanDate: DateTime.now(),
        confidence: 0.90,
        objectType: 'metal',
        funFact: 'Recycler une canette économise 95% de l\'énergie.',
      );
    } else if (lowerLabel.contains('bag')) {
      return ScanResultModel(
        id: 'cache_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Sac plastique',
        carbonImpact: 0.6,
        recyclable: false,
        alternative: 'Utilisez un sac en toile',
        description: 'Les sacs plastique polluent les océans.',
        ecoTips: 'Réutilisez plusieurs fois',
        pointsEarned: 3,
        scanDate: DateTime.now(),
        confidence: 0.80,
        objectType: 'plastic',
        funFact: '8 millions de tonnes de plastique finissent dans les océans.',
      );
    } else {
      return ScanResultModel(
        id: 'cache_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Objet détecté',
        carbonImpact: 1.0,
        recyclable: true,
        alternative: 'Recherchez des alternatives durables',
        description: 'Objet avec impact environnemental variable.',
        ecoTips: 'Consultez les consignes de tri locales',
        pointsEarned: 2,
        scanDate: DateTime.now(),
        confidence: 0.75,
        objectType: 'unknown',
        funFact: 'Chaque geste compte pour la planète !',
      );
    }
  }
}

class _CachedResult {
  final ScanResultModel result;
  final DateTime timestamp;

  _CachedResult({
    required this.result,
    required this.timestamp,
  });
}