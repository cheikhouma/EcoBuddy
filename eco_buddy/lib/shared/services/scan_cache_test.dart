// Test file to verify scan cache functionality
// This can be called from the debug menu or initialization

import 'scan_cache_service.dart';
import '../../features/scanner/domain/models/scan_result_model.dart';

class ScanCacheTest {
  /// Test basic cache functionality
  static Future<bool> testCacheOperations() async {
    try {
      print('🧪 Testing scan cache functionality...');

      // 1. Test cache miss
      final result1 = await ScanCacheService.getCachedResult('test_bottle');
      if (result1 != null) {
        print('❌ Expected cache miss but got result');
        return false;
      }
      print('✅ Cache miss test passed');

      // 2. Test cache write and read
      final testResult = ScanResultModel(
        id: 'test_123',
        name: 'Test Bottle',
        carbonImpact: 2.5,
        recyclable: true,
        alternative: 'Test alternative',
        description: 'Test description',
        ecoTips: 'Test tips',
        pointsEarned: 5,
        scanDate: DateTime.now(),
        confidence: 0.85,
        objectType: 'plastic',
        funFact: 'Test fun fact',
      );

      await ScanCacheService.cacheResult('test_bottle', testResult);
      print('✅ Cache write test passed');

      // 3. Test cache hit
      final result2 = await ScanCacheService.getCachedResult('test_bottle');
      if (result2 == null || result2.name != 'Test Bottle') {
        print('❌ Expected cache hit but got null or wrong result');
        return false;
      }
      print('✅ Cache hit test passed');

      // 4. Test preload common objects
      await ScanCacheService.preloadCommonObjects();
      print('✅ Preload test passed');

      // 5. Verify common objects are cached
      final bottleResult = await ScanCacheService.getCachedResult('bottle');
      if (bottleResult == null) {
        print('❌ Expected preloaded bottle result');
        return false;
      }
      print('✅ Preloaded object verification passed');

      // 6. Test cache statistics
      final stats = await ScanCacheService.getCacheStats();
      print('📊 Cache stats: $stats');
      print('✅ Cache stats test passed');

      print('🎉 All cache tests passed!');
      return true;
    } catch (e) {
      print('❌ Cache test failed: $e');
      return false;
    }
  }

  /// Test cache performance
  static Future<void> testCachePerformance() async {
    print('🚀 Testing cache performance...');

    // Test with multiple cache hits
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 10; i++) {
      await ScanCacheService.getCachedResult('bottle');
    }

    stopwatch.stop();
    final cacheTime = stopwatch.elapsedMilliseconds;

    print('📊 Cache performance: ${cacheTime}ms for 10 cache hits');
    print('📊 Average: ${cacheTime / 10}ms per cache hit');

    if (cacheTime < 100) {
      print('✅ Cache performance excellent (< 100ms)');
    } else if (cacheTime < 500) {
      print('⚠️ Cache performance acceptable (< 500ms)');
    } else {
      print('❌ Cache performance poor (> 500ms)');
    }
  }

  /// Test cache memory management
  static Future<void> testCacheMemoryManagement() async {
    print('🧠 Testing cache memory management...');

    // Fill cache beyond limit to test LRU eviction
    for (int i = 0; i < 60; i++) {
      final result = ScanResultModel(
        id: 'test_$i',
        name: 'Test Object $i',
        pointsEarned: i,
        scanDate: DateTime.now(),
        confidence: 0.8,
      );

      await ScanCacheService.cacheResult('test_object_$i', result);
    }

    final stats = await ScanCacheService.getCacheStats();
    print('📊 Memory cache size after 60 additions: ${stats['memoryCached']}');

    if (stats['memoryCached'] <= 50) {
      print('✅ Memory management working - LRU eviction active');
    } else {
      print('⚠️ Memory management issue - cache size exceeded limit');
    }
  }

  /// Run all tests
  static Future<bool> runAllTests() async {
    print('🧪 Running comprehensive scan cache tests...\n');

    final basicTest = await testCacheOperations();
    await testCachePerformance();
    await testCacheMemoryManagement();

    print('\n🏁 Test suite completed');
    return basicTest;
  }
}