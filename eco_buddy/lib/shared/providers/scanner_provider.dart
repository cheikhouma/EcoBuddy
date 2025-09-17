import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/scanner/domain/models/scan_result_model.dart';
import '../../features/scanner/data/repositories/scanner_repository.dart';

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepository();
});

final scannerProvider =
    StateNotifierProvider<ScannerNotifier, AsyncValue<ScannerState>>((ref) {
      final repository = ref.watch(scannerRepositoryProvider);
      return ScannerNotifier(repository);
    });

class ScannerNotifier extends StateNotifier<AsyncValue<ScannerState>> {
  final ScannerRepository _repository;

  ScannerNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final scanHistory = await _repository.getScanHistory();
      state = AsyncValue.data(
        ScannerState(isCameraReady: false, scanHistory: scanHistory),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> initializeCamera() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isInitializingCamera: true));

    try {
      // Simulate camera initialization delay
      await Future.delayed(const Duration(seconds: 2));

      state = AsyncValue.data(
        currentState.copyWith(isCameraReady: true, isInitializingCamera: false),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> startScan() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isCameraReady ||
        currentState.isScanning) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isScanning: true));

    try {
      final scanResult = await _repository.scanObject();

      state = AsyncValue.data(
        currentState.copyWith(
          isScanning: false,
          lastScanResult: scanResult,
          scanHistory: [scanResult, ...currentState.scanHistory],
        ),
      );
    } catch (error) {
      state = AsyncValue.data(currentState.copyWith(isScanning: false));
    }
  }

  void toggleFlash() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isFlashOn: !currentState.isFlashOn),
    );
  }

  Future<void> saveResult(ScanResultModel result) async {
    try {
      await _repository.saveResult(result);
    } catch (error) {
      // Handle error silently for now
    }
  }

  Future<void> shareResult(ScanResultModel result) async {
    try {
      await _repository.shareResult(result);
    } catch (error) {
      // Handle error silently for now
    }
  }

  void clearLastResult() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(lastScanResult: null));
  }
}

class ScannerState {
  final bool isCameraReady;
  final bool isInitializingCamera;
  final bool isScanning;
  final bool isFlashOn;
  final ScanResultModel? lastScanResult;
  final List<ScanResultModel> scanHistory;

  const ScannerState({
    this.isCameraReady = false,
    this.isInitializingCamera = false,
    this.isScanning = false,
    this.isFlashOn = false,
    this.lastScanResult,
    this.scanHistory = const [],
  });

  ScannerState copyWith({
    bool? isCameraReady,
    bool? isInitializingCamera,
    bool? isScanning,
    bool? isFlashOn,
    ScanResultModel? lastScanResult,
    List<ScanResultModel>? scanHistory,
  }) {
    return ScannerState(
      isCameraReady: isCameraReady ?? this.isCameraReady,
      isInitializingCamera: isInitializingCamera ?? this.isInitializingCamera,
      isScanning: isScanning ?? this.isScanning,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      lastScanResult: lastScanResult ?? this.lastScanResult,
      scanHistory: scanHistory ?? this.scanHistory,
    );
  }
}
