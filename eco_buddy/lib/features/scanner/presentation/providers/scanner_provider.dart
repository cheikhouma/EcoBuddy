import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/scanner_service.dart';
import '../../domain/models/scan_result_model.dart';

// Provider pour le service scanner
final scannerServiceProvider = Provider<ScannerService>((ref) {
  return ScannerService();
});

// Provider pour l'état du scanner AR
final arScannerStateProvider = StateNotifierProvider<ARScannerNotifier, ARScannerState>((ref) {
  final scannerService = ref.watch(scannerServiceProvider);
  return ARScannerNotifier(scannerService);
});

// État du scanner AR
class ARScannerState {
  final bool isScanning;
  final bool isLoading;
  final ScanResultModel? lastResult;
  final String? errorMessage;
  final List<String> detectedLabels;

  const ARScannerState({
    this.isScanning = false,
    this.isLoading = false,
    this.lastResult,
    this.errorMessage,
    this.detectedLabels = const [],
  });

  ARScannerState copyWith({
    bool? isScanning,
    bool? isLoading,
    ScanResultModel? lastResult,
    String? errorMessage,
    List<String>? detectedLabels,
  }) {
    return ARScannerState(
      isScanning: isScanning ?? this.isScanning,
      isLoading: isLoading ?? this.isLoading,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage,
      detectedLabels: detectedLabels ?? this.detectedLabels,
    );
  }
}

// Notifier pour gérer l'état du scanner AR
class ARScannerNotifier extends StateNotifier<ARScannerState> {
  final ScannerService _scannerService;

  ARScannerNotifier(this._scannerService) : super(const ARScannerState());

  // Lance un scan avec ML Kit
  Future<void> scanWithMLKit(String objectLabel, double confidence) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _scannerService.scanObjectWithMLKit(objectLabel, confidence);
      
      state = state.copyWith(
        isLoading: false,
        lastResult: result,
        detectedLabels: [objectLabel],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Met à jour les labels détectés
  void updateDetectedLabels(List<String> labels) {
    state = state.copyWith(detectedLabels: labels);
  }

  // Démarre le scanning
  void startScanning() {
    state = state.copyWith(isScanning: true);
  }

  // Arrête le scanning
  void stopScanning() {
    state = state.copyWith(isScanning: false);
  }

  // Efface le dernier résultat
  void clearLastResult() {
    state = state.copyWith(
      lastResult: null,
      errorMessage: null,
    );
  }

  // Réinitialise l'état
  void reset() {
    state = const ARScannerState();
  }
}