import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../../../shared/services/permission_service.dart';
import '../../../shared/services/scan_cache_service.dart';
import '../../../shared/services/tflite_service.dart';
import '../data/scanner_service.dart';
import '../domain/models/scan_result_model.dart';

/// Modes de scanning unifiés
enum ScanMode {
  quick,    // Scan rapide avec cache
  ar,       // AR avec ML Kit temps réel
  detailed, // Analyse détaillée avec TensorFlow Lite
}

/// Interface de scanner unifiée qui s'adapte au mode sélectionné
class UnifiedScannerScreen extends ConsumerStatefulWidget {
  final ScanMode initialMode;

  const UnifiedScannerScreen({
    super.key,
    this.initialMode = ScanMode.ar,
  });

  @override
  ConsumerState<UnifiedScannerScreen> createState() => _UnifiedScannerScreenState();
}

class _UnifiedScannerScreenState extends ConsumerState<UnifiedScannerScreen>
    with TickerProviderStateMixin {

  // Common state
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _status = 'Initialisation...';

  // Current scan mode
  late ScanMode _currentMode;

  // AR Mode specific
  ImageLabeler? _imageLabeler;
  List<ImageLabel> _detectedLabels = [];
  DateTime _lastDetectionTime = DateTime.now();
  String? _lastProcessedLabel;

  // Animation controllers
  late AnimationController _scanAnimationController;
  late AnimationController _modeTransitionController;
  late Animation<double> _scanAnimation;
  late Animation<double> _modeTransitionAnimation;

  // TensorFlow Lite classification
  Timer? _classificationTimer;
  ClassificationResult? _latestClassification;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_scanAnimationController);

    _modeTransitionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modeTransitionController,
      curve: Curves.easeInOut,
    ));
  }

  /// Initialisation unifiée
  Future<void> _initializeApp() async {
    try {
      // 1. Pré-charger le cache
      _preloadCache();

      // 2. Vérifier permissions
      final hasPermission = await PermissionService.requestCameraPermission();
      if (!hasPermission) {
        setState(() => _status = 'Permission caméra requise');
        return;
      }

      // 3. Initialiser la caméra
      await _initializeCamera();

      // 4. Initialiser les services selon le mode
      await _initializeModeServices();

      setState(() {
        _isInitialized = true;
        _status = _getStatusForMode();
      });

    } catch (e) {
      setState(() => _status = 'Erreur d\'initialisation: $e');
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) throw 'Aucune caméra disponible';

    _cameraController = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();

    if (_currentMode == ScanMode.ar) {
      _startImageStream();
    } else if (_currentMode == ScanMode.detailed) {
      _startClassificationTimer();
    }
  }

  Future<void> _initializeModeServices() async {
    switch (_currentMode) {
      case ScanMode.ar:
        _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
        break;
      case ScanMode.detailed:
        await TFLiteService.initialize();
        break;
      case ScanMode.quick:
        // Mode rapide utilise uniquement le cache
        break;
    }
  }

  void _preloadCache() {
    Future.microtask(() async {
      try {
        await ScanCacheService.preloadCommonObjects();
      } catch (e) {
        print('⚠️ Erreur pré-chargement cache: $e');
      }
    });
  }

  /// Change de mode avec animation
  Future<void> _switchMode(ScanMode newMode) async {
    if (newMode == _currentMode) return;

    // Animation de transition
    await _modeTransitionController.forward();

    // Nettoyer l'ancien mode
    _cleanupCurrentMode();

    // Changer de mode
    setState(() {
      _currentMode = newMode;
      _status = _getStatusForMode();
    });

    // Initialiser le nouveau mode
    await _initializeModeServices();

    if (_currentMode == ScanMode.ar) {
      _startImageStream();
    } else if (_currentMode == ScanMode.detailed) {
      _startClassificationTimer();
    } else {
      _stopImageStream();
      _stopClassificationTimer();
    }

    // Terminer l'animation
    await _modeTransitionController.reverse();
  }

  void _cleanupCurrentMode() {
    _stopImageStream();
    _stopClassificationTimer();
    _imageLabeler?.close();
    _imageLabeler = null;
    _detectedLabels.clear();
    _lastProcessedLabel = null;
    _latestClassification = null;
  }

  String _getStatusForMode() {
    switch (_currentMode) {
      case ScanMode.quick:
        return 'Mode rapide - Appuyez pour scanner';
      case ScanMode.ar:
        return 'Mode AR - Pointez vers un objet';
      case ScanMode.detailed:
        return 'Mode détaillé - Analyse approfondie';
    }
  }

  // AR Mode methods
  void _startImageStream() {
    if (_cameraController?.value.isInitialized != true || _currentMode != ScanMode.ar) return;

    _cameraController!.startImageStream((CameraImage image) {
      if (!_isProcessing &&
          DateTime.now().difference(_lastDetectionTime).inMilliseconds > 3000) {
        _detectObjectsAR(image);
      }
    });
  }

  void _stopImageStream() {
    _cameraController?.stopImageStream();
  }

  Future<void> _detectObjectsAR(CameraImage cameraImage) async {
    if (_isProcessing || _imageLabeler == null) return;

    setState(() => _isProcessing = true);

    try {
      final inputImage = _createInputImageFromCameraImage(cameraImage);
      if (inputImage != null) {
        final labels = await _imageLabeler!.processImage(inputImage);

        final ecoLabels = labels
            .where((label) => _isEcologicallyRelevant(label.label))
            .toList();

        if (ecoLabels.isNotEmpty && mounted) {
          setState(() => _detectedLabels = ecoLabels);

          final bestLabel = ecoLabels.first;
          if (_lastProcessedLabel != bestLabel.label) {
            _lastProcessedLabel = bestLabel.label;
            await _processDetectedObject(bestLabel.label, bestLabel.confidence);
          }
        }
      }
    } catch (e) {
      print('❌ Erreur détection AR: $e');
    } finally {
      _lastDetectionTime = DateTime.now();
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Detailed Mode methods
  void _startClassificationTimer() {
    _classificationTimer?.cancel();
    _classificationTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _classifyImageDetailed(),
    );
  }

  void _stopClassificationTimer() {
    _classificationTimer?.cancel();
    _classificationTimer = null;
  }

  Future<void> _classifyImageDetailed() async {
    if (_isProcessing || _cameraController?.value.isInitialized != true) return;

    setState(() => _isProcessing = true);

    try {
      final XFile image = await _cameraController!.takePicture();
      final classification = await TFLiteService.classifyFromBytes(await image.readAsBytes());

      setState(() => _latestClassification = classification);

      if (classification.isEcologicallyRelevant) {
        await _processDetectedObject(classification.label, classification.confidence);
      }
    } catch (e) {
      print('❌ Erreur classification détaillée: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Quick Mode methods
  Future<void> _quickScan() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final XFile image = await _cameraController!.takePicture();
      final scannerService = ScannerService();
      final result = await scannerService.scanFromXFile(image);

      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du scan: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Common processing method
  Future<void> _processDetectedObject(String label, double confidence) async {
    try {
      final scannerService = ScannerService();
      final result = await scannerService.scanObjectWithMLKit(label, confidence);

      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du traitement: $e');
    }
  }

  // UI Helper methods
  void _showResultDialog(ScanResultModel result) {
    showDialog(
      context: context,
      builder: (context) => _buildResultDialog(result),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Build methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _isInitialized ? _buildScannerBody() : _buildLoadingScreen(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Scanner - ${_getModeDisplayName()}'),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        PopupMenuButton<ScanMode>(
          icon: const Icon(Icons.tune),
          onSelected: _switchMode,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ScanMode.quick,
              child: Row(
                children: [
                  const Icon(Icons.flash_on, size: 20),
                  const SizedBox(width: 8),
                  Text(_currentMode == ScanMode.quick ? '✓ Rapide' : 'Rapide'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ScanMode.ar,
              child: Row(
                children: [
                  const Icon(Icons.camera_alt, size: 20),
                  const SizedBox(width: 8),
                  Text(_currentMode == ScanMode.ar ? '✓ AR Temps réel' : 'AR Temps réel'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ScanMode.detailed,
              child: Row(
                children: [
                  const Icon(Icons.analytics, size: 20),
                  const SizedBox(width: 8),
                  Text(_currentMode == ScanMode.detailed ? '✓ Détaillé' : 'Détaillé'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 16),
          Text(
            _status,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerBody() {
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: _cameraController?.value.isInitialized == true
              ? CameraPreview(_cameraController!)
              : Container(color: Colors.black),
        ),

        // Overlay selon le mode
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _modeTransitionAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: 1.0 - _modeTransitionAnimation.value,
                child: _buildModeSpecificOverlay(),
              );
            },
          ),
        ),

        // Status bar
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildStatusBar(),
        ),

        // Mode indicator
        Positioned(
          bottom: 100,
          left: 16,
          child: _buildModeIndicator(),
        ),
      ],
    );
  }

  Widget _buildModeSpecificOverlay() {
    switch (_currentMode) {
      case ScanMode.ar:
        return _buildAROverlay();
      case ScanMode.detailed:
        return _buildDetailedOverlay();
      case ScanMode.quick:
        return _buildQuickOverlay();
    }
  }

  Widget _buildAROverlay() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScanOverlayPainter(
            detectedLabels: _detectedLabels,
            isDetecting: _isProcessing,
            animationValue: _scanAnimation.value,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildDetailedOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _latestClassification != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _latestClassification!.label,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      '${(_latestClassification!.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildQuickOverlay() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 3),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Center(
          child: Icon(
            Icons.camera_alt,
            color: Colors.green,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _status,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildModeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getModeColor().withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getModeDisplayName(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentMode == ScanMode.quick) {
      return FloatingActionButton(
        onPressed: _isProcessing ? null : _quickScan,
        backgroundColor: Colors.green,
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.camera_alt, color: Colors.white),
      );
    }
    return null;
  }

  Widget _buildResultDialog(ScanResultModel result) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getImpactColor(result.environmentalImpact),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔍 ${result.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mode: ${_getModeDisplayName()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.description != null)
                    Text(result.description!),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Points: +${result.pointsEarned}'),
                      if (result.carbonImpact != null)
                        Text('${result.carbonImpact!.toStringAsFixed(1)} kg CO₂'),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Utility methods
  String _getModeDisplayName() {
    switch (_currentMode) {
      case ScanMode.quick:
        return 'Rapide';
      case ScanMode.ar:
        return 'AR';
      case ScanMode.detailed:
        return 'Détaillé';
    }
  }

  Color _getModeColor() {
    switch (_currentMode) {
      case ScanMode.quick:
        return Colors.green;
      case ScanMode.ar:
        return Colors.orange;
      case ScanMode.detailed:
        return Colors.blue;
    }
  }

  Color _getImpactColor(EnvironmentalImpact impact) {
    switch (impact) {
      case EnvironmentalImpact.low:
        return Colors.green;
      case EnvironmentalImpact.medium:
        return Colors.orange;
      case EnvironmentalImpact.high:
        return Colors.red;
    }
  }

  bool _isEcologicallyRelevant(String objectLabel) {
    const ecoKeywords = [
      'bottle', 'can', 'bag', 'container', 'cup', 'box',
      'plastic', 'glass', 'paper', 'cardboard', 'packaging',
      'wrapper', 'carton', 'trash', 'waste',
    ];

    final lowerLabel = objectLabel.toLowerCase();
    return ecoKeywords.any((keyword) => lowerLabel.contains(keyword));
  }

  InputImage? _createInputImageFromCameraImage(CameraImage cameraImage) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );

      final InputImageRotation imageRotation = InputImageRotation.rotation0deg;

      final InputImageFormat inputImageFormat = InputImageFormat.nv21;

      final inputImageMetadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
    } catch (e) {
      print('❌ Erreur création InputImage: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _cleanupCurrentMode();
    _cameraController?.dispose();
    _scanAnimationController.dispose();
    _modeTransitionController.dispose();
    super.dispose();
  }
}

/// Custom painter pour l'overlay de scan AR (repris de ar_scanner_screen.dart)
class ScanOverlayPainter extends CustomPainter {
  final List<ImageLabel> detectedLabels;
  final bool isDetecting;
  final double animationValue;

  ScanOverlayPainter({
    required this.detectedLabels,
    required this.isDetecting,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scanSize = size.width * 0.7;

    // Frame de scan
    if (isDetecting) {
      final framePaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final rect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: scanSize,
        height: scanSize,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        framePaint,
      );

      // Ligne de scan animée
      final scanLinePaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final top = centerY - scanSize / 2;
      final left = centerX - scanSize / 2;
      final right = centerX + scanSize / 2;
      final scanY = top + (animationValue * scanSize);

      canvas.drawLine(Offset(left, scanY), Offset(right, scanY), scanLinePaint);
    }

    // Indicateurs d'objets détectés
    if (detectedLabels.isNotEmpty) {
      final targetPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      for (int i = 0; i < detectedLabels.length && i < 3; i++) {
        final angle = (i * 2 * pi) / 3;
        final targetX = centerX + (scanSize / 3) * 0.8 * cos(angle);
        final targetY = centerY + (scanSize / 3) * 0.8 * sin(angle);

        canvas.drawCircle(Offset(targetX, targetY), 8, targetPaint);
        canvas.drawCircle(Offset(targetX, targetY), 4, Paint()..color = Colors.green);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}