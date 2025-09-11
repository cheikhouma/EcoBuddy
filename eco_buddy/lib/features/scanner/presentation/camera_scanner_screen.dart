import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/tflite_service.dart';
import '../../../shared/services/permission_service.dart';
import '../../../core/constants/app_constants.dart';
import '../data/scanner_service.dart';
import '../domain/models/scan_result_model.dart';

class CameraScannerScreen extends ConsumerStatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  ConsumerState<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends ConsumerState<CameraScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _isProcessing = false;
  
  // Classification en temps réel
  Timer? _classificationTimer;
  ClassificationResult? _latestClassification;
  String _detectionStatus = 'Pointez vers un objet...';
  
  // Résultats
  ScanResultModel? _latestScanResult;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialisation avec vérification permissions
  Future<void> _initializeApp() async {
    // 1. Vérifier et demander les permissions
    final hasPermission = await PermissionService.requestCameraPermission();
    
    if (!hasPermission) {
      _updateStatus('Permission caméra refusée');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permission caméra requise'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Paramètres',
              onPressed: () => PermissionService.openPermissionSettings(),
            ),
          ),
        );
      }
      return;
    }

    // 2. Initialiser caméra et TensorFlow
    await Future.wait([
      _initializeCamera(),
      _initializeTensorFlow(),
    ]);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _classificationTimer?.cancel();
    TFLiteService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        _updateStatus('Aucune caméra disponible');
        return;
      }

      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _updateStatus('Caméra prête');
      }
    } catch (e) {
      _updateStatus('Erreur caméra: ${e.toString()}');
    }
  }

  Future<void> _initializeTensorFlow() async {
    try {
      final success = await TFLiteService.initialize();
      if (success) {
        _updateStatus('IA initialisée avec succès');
      } else {
        _updateStatus('IA en mode simulation');
      }
    } catch (e) {
      _updateStatus('Erreur IA: ${e.toString()}');
    }
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _detectionStatus = status;
      });
    }
  }

  void _startRealTimeScanning() {
    if (!_isCameraInitialized || _isScanning) return;
    
    setState(() {
      _isScanning = true;
      _detectionStatus = 'Scan en cours...';
    });

    _classificationTimer = Timer.periodic(
      const Duration(milliseconds: 1500), 
      _performRealTimeClassification
    );
  }

  void _stopRealTimeScanning() {
    _classificationTimer?.cancel();
    setState(() {
      _isScanning = false;
      _detectionStatus = 'Scan arrêté';
    });
  }

  Future<void> _performRealTimeClassification(Timer timer) async {
    if (!_isCameraInitialized || _cameraController?.value.isStreamingImages != true) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      
      final classification = await TFLiteService.classifyFromBytes(bytes);
      
      if (mounted) {
        setState(() {
          _latestClassification = classification;
          
          if (classification.confidence > 0.7 && classification.isEcologicallyRelevant) {
            _detectionStatus = '${classification.label} détecté (${(classification.confidence * 100).toInt()}%)';
          } else {
            _detectionStatus = 'Recherche d\'objets...';
          }
        });
      }
      
      // Nettoyer le fichier temporaire
      if (await File(image.path).exists()) {
        await File(image.path).delete();
      }
      
    } catch (e) {
      _updateStatus('Erreur classification: ${e.toString()}');
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _detectionStatus = 'Capture et analyse...';
    });

    try {
      HapticFeedback.mediumImpact();
      
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      
      // 1. Classification locale
      final classification = await TFLiteService.classifyFromBytes(bytes);
      
      // 2. Analyse complète via backend
      final scannerService = ScannerService();
      final scanResult = await scannerService.scanFromBytes(bytes);
      
      setState(() {
        _latestScanResult = scanResult;
        _isProcessing = false;
        _detectionStatus = 'Analyse terminée';
      });
      
      // Nettoyer
      if (await File(image.path).exists()) {
        await File(image.path).delete();
      }
      
      // Afficher les résultats
      _showScanResults();
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _detectionStatus = 'Erreur: ${e.toString()}';
      });
    }
  }

  void _showScanResults() {
    if (_latestScanResult == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildResultsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scanner AR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isScanning ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _isScanning ? _stopRealTimeScanning : _startRealTimeScanning,
          ),
        ],
      ),
      body: _isCameraInitialized 
        ? _buildCameraView()
        : _buildLoadingView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(AppConstants.primaryColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(AppConstants.primaryColor)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Initialisation de la caméra...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _detectionStatus,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Vue caméra
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // Overlay de scan
        _buildScanOverlay(),
        
        // Status et contrôles
        _buildTopControls(),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildScanOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ScanOverlayPainter(
          isScanning: _isScanning,
          hasDetection: _latestClassification?.isEcologicallyRelevant == true && 
                        _latestClassification!.confidence > 0.7,
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              _detectionStatus,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (_latestClassification != null && 
                _latestClassification!.isEcologicallyRelevant &&
                _latestClassification!.confidence > 0.7) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.primaryColor).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_latestClassification!.label} - ${(_latestClassification!.confidence * 100).toInt()}% sûr',
                  style: const TextStyle(
                    color: Color(AppConstants.primaryColor),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Bouton de capture principal
          Center(
            child: GestureDetector(
              onTap: _captureAndAnalyze,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isProcessing 
                    ? Colors.grey 
                    : const Color(AppConstants.primaryColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: _isProcessing
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 32,
                    ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Boutons d'actions secondaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.flash_on,
                label: 'Flash',
                onTap: _toggleFlash,
              ),
              _buildActionButton(
                icon: _isScanning ? Icons.stop : Icons.center_focus_strong,
                label: _isScanning ? 'Stop' : 'Scan Auto',
                onTap: _isScanning ? _stopRealTimeScanning : _startRealTimeScanning,
              ),
              _buildActionButton(
                icon: Icons.flip_camera_android,
                label: 'Retourner',
                onTap: _switchCamera,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsBottomSheet() {
    if (_latestScanResult == null) return Container();
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle du modal
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Titre et confiance
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _latestScanResult!.objectName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.accentColor).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+${_latestScanResult!.points} points',
                        style: const TextStyle(
                          color: Color(AppConstants.accentColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Information environnementale
                _buildInfoSection(
                  'Impact Environnemental',
                  _latestScanResult!.environmentalInfo,
                  Icons.eco,
                ),
                
                // Suggestions de recyclage
                if (_latestScanResult!.recyclingSuggestions.isNotEmpty)
                  _buildListSection(
                    'Recyclage',
                    _latestScanResult!.recyclingSuggestions,
                    Icons.recycling,
                  ),
                
                // Alternatives
                if (_latestScanResult!.alternatives.isNotEmpty)
                  _buildListSection(
                    'Alternatives',
                    _latestScanResult!.alternatives,
                    Icons.lightbulb,
                  ),
                
                const SizedBox(height: 20),
                
                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveResult,
                        icon: const Icon(Icons.save),
                        label: const Text('Sauvegarder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppConstants.primaryColor),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareResult,
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(AppConstants.primaryColor)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(AppConstants.primaryColor)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(item)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _toggleFlash() async {
    try {
      await _cameraController!.setFlashMode(
        _cameraController!.value.flashMode == FlashMode.off 
          ? FlashMode.torch 
          : FlashMode.off
      );
    } catch (e) {
      _updateStatus('Erreur flash: ${e.toString()}');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    try {
      final currentCamera = _cameraController!.description;
      final newCamera = _cameras!.firstWhere(
        (camera) => camera != currentCamera,
        orElse: () => _cameras!.first,
      );
      
      await _cameraController!.dispose();
      _cameraController = CameraController(newCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _updateStatus('Erreur changement caméra: ${e.toString()}');
    }
  }

  Future<void> _saveResult() async {
    if (_latestScanResult == null) return;
    
    final scannerService = ScannerService();
    final success = await scannerService.saveResult(_latestScanResult!);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Résultat sauvegardé' : 'Erreur sauvegarde'),
        ),
      );
    }
  }

  Future<void> _shareResult() async {
    // Implémentation du partage
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partage en cours...')),
      );
    }
  }
}

class ScanOverlayPainter extends CustomPainter {
  final bool isScanning;
  final bool hasDetection;
  
  ScanOverlayPainter({required this.isScanning, required this.hasDetection});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Couleur selon l'état
    if (hasDetection) {
      paint.color = const Color(AppConstants.primaryColor);
    } else if (isScanning) {
      paint.color = Colors.blue;
    } else {
      paint.color = Colors.white70;
    }
    
    // Zone de scan centrale
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );
    
    // Coins arrondis
    final cornerLength = 30.0;
    
    // Coin haut gauche
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );
    
    // Coin haut droit
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );
    
    // Coin bas gauche
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );
    
    // Coin bas droit
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
    
    // Ligne de scan animée si actif
    if (isScanning) {
      final scanPaint = Paint()
        ..color = paint.color.withValues(alpha: 0.7)
        ..strokeWidth = 2;
        
      canvas.drawLine(
        Offset(rect.left + 10, rect.center.dy),
        Offset(rect.right - 10, rect.center.dy),
        scanPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}