import 'dart:async';
import 'dart:math';
import 'package:eco_buddy/core/constants/app_constants.dart';
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
import 'scan_result_screen.dart';

/// Modes de scanning unifiés
enum ScanMode {
  quick, // Scan rapide avec cache
  ar, // AR avec ML Kit temps réel
  detailed, // Analyse détaillée avec TensorFlow Lite
}

/// Interface de scanner unifiée qui s'adapte au mode sélectionné
class UnifiedScannerScreen extends ConsumerStatefulWidget {
  final ScanMode initialMode;

  const UnifiedScannerScreen({super.key, this.initialMode = ScanMode.ar});

  @override
  ConsumerState<UnifiedScannerScreen> createState() =>
      _UnifiedScannerScreenState();
}

class _UnifiedScannerScreenState extends ConsumerState<UnifiedScannerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
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
  bool _isImageProcessing = false; // Nouveau flag pour éviter la saturation

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
    WidgetsBinding.instance.addObserver(this); // ✅ Observer du cycle de vie
    _currentMode = widget.initialMode;
    _initializeAnimations();
    _initializeApp();
  }

  // ✅ NOUVEAU : Gestion du cycle de vie de l'app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      print('🔴 App paused/inactive/hidden - Force stopping camera');
      _forceStopAllCameraOperations();
    } else if (state == AppLifecycleState.resumed) {
      print('🟢 App resumed - Camera can be reinitialized if needed');
    }
  }

  // ✅ NOUVEAU : Cleanup immédiat quand le widget est désactivé
  @override
  void deactivate() {
    print('🔴 Scanner deactivate() - Immediate cleanup');
    _forceStopAllCameraOperations();
    super.deactivate();
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

    _modeTransitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _modeTransitionController,
        curve: Curves.easeInOut,
      ),
    );
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

    // ✅ DÉSACTIVÉ : Plus de scan automatique au démarrage
    // if (_currentMode == ScanMode.ar) {
    //   _startImageStream();
    // } else if (_currentMode == ScanMode.detailed) {
    //   _startClassificationTimer();
    // }
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

    // ✅ DÉSACTIVÉ : Plus de scan automatique lors du changement de mode
    // if (_currentMode == ScanMode.ar) {
    //   _startImageStream();
    // } else if (_currentMode == ScanMode.detailed) {
    //   _startClassificationTimer();
    // } else {
    //   _stopImageStream();
    //   _stopClassificationTimer();
    // }

    // S'assurer que les scans automatiques sont arrêtés
    _stopImageStream();
    _stopClassificationTimer();

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
        return 'Quick mode - Tap to scan';
      case ScanMode.ar:
        return 'AR mode - Tap to scan with ML Kit';
      case ScanMode.detailed:
        return 'Detailed mode - Tap for TensorFlow analysis';
    }
  }

  // AR Mode methods
  void _startImageStream() {
    if (_cameraController?.value.isInitialized != true ||
        _currentMode != ScanMode.ar)
      return;

    _cameraController!.startImageStream((CameraImage image) {
      // Protection contre la saturation du buffer
      if (!_isProcessing &&
          !_isImageProcessing &&
          DateTime.now().difference(_lastDetectionTime).inMilliseconds > 5000) {
        _detectObjectsAR(image);
      }
    });
  }

  void _stopImageStream() {
    _cameraController?.stopImageStream();
    // Reset des flags pour éviter les conflits
    _isImageProcessing = false;
    _detectedLabels.clear();
  }

  Future<void> _detectObjectsAR(CameraImage cameraImage) async {
    if (_isProcessing || _isImageProcessing || _imageLabeler == null) return;

    setState(() {
      _isProcessing = true;
      _isImageProcessing = true;
    });

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
        setState(() {
          _isProcessing = false;
          _isImageProcessing = false;
        });
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
      final classification = await TFLiteService.classifyFromBytes(
        await image.readAsBytes(),
      );

      setState(() => _latestClassification = classification);

      if (classification.isEcologicallyRelevant) {
        await _processDetectedObject(
          classification.label,
          classification.confidence,
        );
      }
    } catch (e) {
      print('❌ Erreur classification détaillée: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // ✅ NOUVEAU : Scan manuel AR amélioré
  Future<void> _scanAR() async {
    if (_isProcessing || _isImageProcessing || _imageLabeler == null) return;

    setState(() {
      _isProcessing = true;
      _isImageProcessing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final labels = await _imageLabeler!.processImage(inputImage);

      print('🔍 AR Scan - Labels détectés: ${labels.length}');
      print('📋 TOUS LES LABELS ML KIT:');
      labels.forEach(
        (label) => print(
          '  - ${label.label}: ${(label.confidence * 100).toStringAsFixed(1)}%',
        ),
      );

      print('🌱 LABELS ÉCOLOGIQUES FILTRÉS:');
      final ecoLabelsDebug = labels
          .where((label) => _isEcologicallyRelevant(label.label))
          .toList();
      ecoLabelsDebug.forEach(
        (label) => print(
          '  ✅ ${label.label}: ${(label.confidence * 100).toStringAsFixed(1)}%',
        ),
      );

      // ✅ FILTRAGE AMÉLIORÉ : Prendre le meilleur objet écologique
      final ecoLabels = labels
          .where((label) => _isEcologicallyRelevant(label.label))
          .where((label) => label.confidence > 0.5) // Confidence minimum 50%
          .toList();

      // Trier par confidence décroissante
      ecoLabels.sort((a, b) => b.confidence.compareTo(a.confidence));

      if (ecoLabels.isNotEmpty) {
        final bestLabel = ecoLabels.first;
        print(
          '✅ Meilleur objet détecté: ${bestLabel.label} (${(bestLabel.confidence * 100).toStringAsFixed(1)}%)',
        );

        // ✅ NOUVEAU : Mapper le label vers un objet plus spécifique
        final mappedLabel = _mapLabelToSpecificObject(bestLabel.label, labels);
        print('🎯 Label mappé: ${bestLabel.label} → ${mappedLabel}');

        // ✅ DÉMO MODE : Afficher tous les détails avant traitement
        _showDebugInfo(
          bestLabel.label,
          mappedLabel,
          bestLabel.confidence,
          labels,
        );

        // Traiter avec le label mappé
        await _processDetectedObject(mappedLabel, bestLabel.confidence);
      } else {
        // Essayer avec tous les labels si aucun objet écologique
        if (labels.isNotEmpty) {
          final bestOverall = labels.first;
          print('⚠️ Aucun objet écologique, test avec: ${bestOverall.label}');

          // Mapper aussi les objets non-écologiques
          final mappedLabel = _mapLabelToSpecificObject(
            bestOverall.label,
            labels,
          );
          await _processDetectedObject(mappedLabel, bestOverall.confidence);
        } else {
          _showErrorSnackBar('No object detected in image');
        }
      }
    } catch (e) {
      print('❌ AR scan error: $e');
      _showErrorSnackBar('AR scan error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isImageProcessing = false;
        });
      }
    }
  }

  // ✅ NOUVEAU : Scan manuel détaillé
  Future<void> _scanDetailed() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final XFile image = await _cameraController!.takePicture();
      final classification = await TFLiteService.classifyFromBytes(
        await image.readAsBytes(),
      );

      setState(() => _latestClassification = classification);

      if (classification.isEcologicallyRelevant) {
        await _processDetectedObject(
          classification.label,
          classification.confidence,
        );
      } else {
        _showErrorSnackBar('Object not recognized or not ecological');
      }
    } catch (e) {
      _showErrorSnackBar('Detailed scan error: $e');
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
      _showErrorSnackBar('Scan error: $e');
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
      final result = await scannerService.scanObjectWithMLKit(
        label,
        confidence,
      );

      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      _showErrorSnackBar('Processing error: $e');
    }
  }

  // UI Helper methods
  void _showResultDialog(ScanResultModel result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          result: result,
          scanMode: _getModeDisplayName(),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      automaticallyImplyLeading: false,
      title: Text(
        'Scanner - ${_getModeDisplayName()}',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Color(AppConstants.primaryColor),
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
                  Text(_currentMode == ScanMode.quick ? '✓ Quick' : 'Quick'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ScanMode.ar,
              child: Row(
                children: [
                  const Icon(Icons.camera_alt, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _currentMode == ScanMode.ar
                        ? '✓ AR Real-time'
                        : 'AR Real-time',
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ScanMode.detailed,
              child: Row(
                children: [
                  const Icon(Icons.analytics, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _currentMode == ScanMode.detailed
                        ? '✓ Detailed'
                        : 'Detailed',
                  ),
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
        Positioned(top: 16, left: 16, right: 16, child: _buildStatusBar()),

        // Mode indicator
        Positioned(bottom: 100, left: 16, child: _buildModeIndicator()),
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
          child: Icon(Icons.camera_alt, color: Colors.green, size: 48),
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
    // ✅ BOUTON POUR TOUS LES MODES
    return FloatingActionButton.extended(
      onPressed: _isProcessing ? null : _getScanFunction(),
      backgroundColor: _getModeColor(),
      icon: _isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(_getModeIcon(), color: Colors.white),
      label: Text(
        _getScanButtonLabel(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ✅ FONCTIONS UTILITAIRES POUR LE BOUTON
  VoidCallback _getScanFunction() {
    switch (_currentMode) {
      case ScanMode.quick:
        return _quickScan;
      case ScanMode.ar:
        return _scanAR;
      case ScanMode.detailed:
        return _scanDetailed;
    }
  }

  IconData _getModeIcon() {
    switch (_currentMode) {
      case ScanMode.quick:
        return Icons.flash_on;
      case ScanMode.ar:
        return Icons.camera_alt;
      case ScanMode.detailed:
        return Icons.analytics;
    }
  }

  String _getScanButtonLabel() {
    switch (_currentMode) {
      case ScanMode.quick:
        return 'Scan';
      case ScanMode.ar:
        return 'AR Scan';
      case ScanMode.detailed:
        return 'Analyze';
    }
  }

  Widget _buildResultDialog(ScanResultModel result) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 700),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ HEADER ENRICHI
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getImpactColor(result.environmentalImpact),
                        _getImpactColor(
                          result.environmentalImpact,
                        ).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getObjectIcon(result.objectType ?? 'unknown'),
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              result.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scanned with ${_getModeDisplayName()} • ${(result.confidence * 100).toStringAsFixed(1)}% confidence',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ STATS SECTION
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Points',
                          '+${result.pointsEarned}',
                          Icons.stars,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Carbon Impact',
                          result.carbonImpact != null
                              ? '${result.carbonImpact!.toStringAsFixed(1)} kg'
                              : 'Unknown',
                          Icons.co2,
                          _getImpactColor(result.environmentalImpact),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Recyclable',
                          result.recyclable == true ? 'Yes' : 'No',
                          result.recyclable == true
                              ? Icons.recycling
                              : Icons.delete,
                          result.recyclable == true ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ DESCRIPTION SECTION
                if (result.description != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Environmental Impact',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.description!,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // ✅ ALTERNATIVES SECTION
                if (result.alternative != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.eco, size: 18, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Eco-Friendly Alternative',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.alternative!,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // ✅ ECO TIPS SECTION
                if (result.ecoTips != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Recycling Tips',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...result.ecoTips!
                            .split(',')
                            .map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                    Expanded(
                                      child: Text(
                                        tip.trim(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // ✅ FUN FACT SECTION
                if (result.funFact != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 18,
                              color: Colors.purple,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Did You Know?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.funFact!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ✅ ACTIONS
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Save to history or share
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getImpactColor(
                              result.environmentalImpact,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ HELPER METHODS FOR ENRICHED DIALOG
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getObjectIcon(String objectType) {
    switch (objectType.toLowerCase()) {
      case 'plastic':
        return '';
      case 'metal':
        return '';
      case 'glass':
        return '';
      case 'paper':
        return '';
      case 'electronic':
        return '';
      case 'toxic':
        return '';
      case 'mixed':
        return '';
      default:
        return '';
    }
  }

  // Utility methods
  String _getModeDisplayName() {
    switch (_currentMode) {
      case ScanMode.quick:
        return 'Quick';
      case ScanMode.ar:
        return 'AR';
      case ScanMode.detailed:
        return 'Detailed';
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
    // ✅ AMÉLIORÉ : Plus de mots-clés écologiques pour une meilleure détection
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

  // ✅ NOUVEAU : Mapper les labels ML Kit vers des objets spécifiques
  String _mapLabelToSpecificObject(
    String mlKitLabel,
    List<ImageLabel> allLabels,
  ) {
    final lowerLabel = mlKitLabel.toLowerCase();
    final allLabelsText = allLabels.map((l) => l.label.toLowerCase()).toList();

    print(
      '🔍 Mapping ${mlKitLabel} avec contexte: ${allLabelsText.take(5).join(", ")}...',
    );

    // 🍶 BOUTEILLES - Analyser le contexte pour déterminer le type
    if (lowerLabel.contains('bottle')) {
      // Chercher des indices sur le matériau dans les autres labels
      if (allLabelsText.any(
        (l) => l.contains('plastic') || l.contains('water'),
      )) {
        return 'bottle'; // Bouteille plastique (par défaut)
      } else if (allLabelsText.any(
        (l) => l.contains('glass') || l.contains('wine') || l.contains('beer'),
      )) {
        return 'glass'; // Bouteille en verre
      }
      return 'bottle'; // Par défaut
    }

    // 🥤 CANETTES vs BOUTEILLES
    if (lowerLabel.contains('can')) {
      if (allLabelsText.any(
        (l) =>
            l.contains('aluminum') || l.contains('drink') || l.contains('soda'),
      )) {
        return 'can'; // Canette métallique
      }
      return 'can';
    }

    // 🛍️ SACS - Différencier plastique vs tissu
    if (lowerLabel.contains('bag')) {
      if (allLabelsText.any(
        (l) => l.contains('plastic') || l.contains('shopping'),
      )) {
        return 'bag'; // Sac plastique
      } else if (allLabelsText.any(
        (l) =>
            l.contains('fabric') || l.contains('cloth') || l.contains('canvas'),
      )) {
        return 'fabric'; // Sac en tissu
      }
      return 'bag'; // Par défaut plastique
    }

    // ☕ TASSES ET GOBELETS
    if (lowerLabel.contains('cup') || lowerLabel.contains('mug')) {
      if (allLabelsText.any(
        (l) => l.contains('paper') || l.contains('disposable'),
      )) {
        return 'cup'; // Gobelet jetable
      } else if (allLabelsText.any(
        (l) => l.contains('ceramic') || l.contains('porcelain'),
      )) {
        return 'glass'; // Tasse réutilisable
      }
      return 'cup'; // Par défaut jetable
    }

    // 📱 ÉLECTRONIQUE
    if (lowerLabel.contains('phone') || lowerLabel.contains('mobile')) {
      return 'phone';
    }

    if (lowerLabel.contains('battery')) {
      return 'battery';
    }

    // 🚬 CIGARETTES
    if (lowerLabel.contains('cigarette')) {
      return 'cigarette';
    }

    // 📄 PAPIER
    if (lowerLabel.contains('paper') || lowerLabel.contains('document')) {
      return 'paper';
    }

    // 🔧 OBJETS GÉNÉRIQUES - Essayer de deviner
    if (lowerLabel.contains('container')) {
      // Analyser le contexte pour deviner le type de contenant
      if (allLabelsText.any((l) => l.contains('plastic'))) {
        return 'bottle'; // Probablement une bouteille
      } else if (allLabelsText.any((l) => l.contains('metal'))) {
        return 'can'; // Probablement une canette
      }
      return 'container'; // Contenant générique
    }

    // Si aucun mapping spécifique, retourner le label original
    return mlKitLabel;
  }

  // ✅ NOUVEAU : Afficher les infos de debug pour comprendre les erreurs
  void _showDebugInfo(
    String originalLabel,
    String mappedLabel,
    double confidence,
    List<ImageLabel> allLabels,
  ) {
    // En mode debug, afficher une SnackBar avec les détails
    final debugMessage =
        '''
🔍 ML Kit Original: $originalLabel (${(confidence * 100).toStringAsFixed(1)}%)
🎯 Mappé vers: $mappedLabel
📋 Contexte: ${allLabels.take(3).map((l) => l.label).join(", ")}
''';

    print('🐛 DEBUG INFO:');
    print(debugMessage);

    // Optionnel : Afficher aussi dans l'UI pour debug
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(debugMessage),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
      ),
    );
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
    print('🔴 Scanner dispose() - Cleaning up all resources');
    WidgetsBinding.instance.removeObserver(this);

    // ✅ CLEANUP ULTRA-AGRESSIF
    _forceStopAllCameraOperations();
    _cleanupCurrentMode();

    // Forcer la fermeture immédiate de la caméra
    _cameraController?.dispose();
    _cameraController = null;

    _scanAnimationController.dispose();
    _modeTransitionController.dispose();

    print('✅ Scanner cleanup completed');
    super.dispose();
  }

  // ✅ NOUVEAU : Arrêt forcé de toutes les opérations caméra
  void _forceStopAllCameraOperations() {
    print('🛑 Force stopping ALL camera operations');

    // Arrêter immédiatement tout stream caméra
    try {
      _cameraController?.stopImageStream();
    } catch (e) {
      print('⚠️ Error stopping image stream: $e');
    }

    // Arrêter tous les timers
    _stopClassificationTimer();

    // Vider les détections en cours
    _detectedLabels.clear();
    _lastProcessedLabel = null;
    _latestClassification = null;

    // Marquer comme non initialisé
    _isInitialized = false;
    _isProcessing = false;
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
        canvas.drawCircle(
          Offset(targetX, targetY),
          4,
          Paint()..color = Colors.green,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
