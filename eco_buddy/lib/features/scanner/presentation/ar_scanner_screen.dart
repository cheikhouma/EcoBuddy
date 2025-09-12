import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:eco_buddy/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../data/scanner_service.dart';
import '../domain/models/scan_result_model.dart';
import '../../../shared/services/permission_service.dart';

class ARScannerScreen extends ConsumerStatefulWidget {
  const ARScannerScreen({super.key});

  @override
  ConsumerState<ARScannerScreen> createState() => _ARScannerScreenState();
}

class _ARScannerScreenState extends ConsumerState<ARScannerScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isDetecting = false;
  bool _isLoading = false;
  ImageLabeler? _imageLabeler;
  ScanResultModel? _lastScanResult;
  List<ImageLabel> _detectedLabels = [];
  DateTime _lastDetectionTime = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _initializeApp();
  }

  /// Initialisation complète avec vérification des permissions
  Future<void> _initializeApp() async {
    // 1. Vérifier et demander les permissions
    final hasPermission = await PermissionService.requestCameraPermission();

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Permission caméra requise pour utiliser le scanner AR',
            ),
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

    // 2. Initialiser la caméra et ML Kit
    await Future.wait([_initializeCamera(), _initializeImageLabeler()]);
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        _startImageStream();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('❌ Erreur initialisation caméra: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur caméra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initializeImageLabeler() async {
    try {
      final options = ImageLabelerOptions(confidenceThreshold: 0.5);
      _imageLabeler = ImageLabeler(options: options);
    } catch (e) {
      print('❌ Erreur initialisation ML Kit: $e');
    }
  }

  void _startImageStream() {
    if (_cameraController?.value.isInitialized != true) return;

    _cameraController!.startImageStream((CameraImage image) {
      if (!_isDetecting &&
          DateTime.now().difference(_lastDetectionTime).inMilliseconds > 1500) {
        _detectObjects(image);
      }
    });
  }

  Future<void> _detectObjects(CameraImage cameraImage) async {
    if (_isDetecting || _imageLabeler == null) return;

    setState(() {
      _isDetecting = true;
    });

    try {
      final inputImage = _createInputImageFromCameraImage(cameraImage);
      if (inputImage != null) {
        final labels = await _imageLabeler!.processImage(inputImage);

        // Filtrer les objets écologiquement pertinents
        final ecoLabels = labels
            .where((label) => _isEcologicallyRelevant(label.label))
            .toList();

        if (ecoLabels.isNotEmpty && mounted) {
          setState(() {
            _detectedLabels = ecoLabels;
          });

          // Envoyer le meilleur résultat au backend
          final bestLabel = ecoLabels.first;
          await _sendToBackend(bestLabel);
        }
      }
    } catch (e) {
      print('❌ Erreur détection objets: $e');
    } finally {
      _lastDetectionTime = DateTime.now();
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
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

  bool _isEcologicallyRelevant(String label) {
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
    ];

    final lowerLabel = label.toLowerCase();
    return ecoKeywords.any((keyword) => lowerLabel.contains(keyword));
  }

  Future<void> _sendToBackend(ImageLabel label) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final scannerService = ref.read(scannerServiceProvider);
      final result = await scannerService.scanObjectWithMLKit(
        label.label,
        label.confidence,
      );

      if (mounted) {
        setState(() {
          _lastScanResult = result;
        });
      }
    } catch (e) {
      print('❌ Erreur envoi backend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    _imageLabeler?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Scanner AR', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Aperçu caméra
          if (_cameraController?.value.isInitialized == true)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator(color: Colors.green)),

          // Overlay de scan avec animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScanOverlayPainter(
                    detectedLabels: _detectedLabels,
                    isDetecting: _isDetecting,
                    animationValue: _animation.value,
                  ),
                );
              },
            ),
          ),

          // Résultat du scan
          if (_lastScanResult != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildResultCard(_lastScanResult!),
            ),

          // Indicateur de chargement
          if (_isLoading)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      strokeWidth: 2,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Analyse en cours...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Labels détectés
          if (_detectedLabels.isNotEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🔍 Objets détectés:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._detectedLabels
                        .take(3)
                        .map(
                          (label) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${label.label} (${(label.confidence * 100).toInt()}%)',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard(ScanResultModel result) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête avec objet détecté
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
                  '🔍 ${result.objectName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Impact: ${_getImpactText(result.environmentalImpact)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Métriques environnementales
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (result.carbonFootprint != null)
                  _buildMetricRow(
                    '🌍',
                    'Empreinte carbone',
                    '${result.carbonFootprint!.toStringAsFixed(2)} kg CO₂',
                  ),
                if (result.recyclingRate != null)
                  _buildMetricRow(
                    '♻️',
                    'Taux de recyclage',
                    '${(result.recyclingRate! * 100).toInt()}%',
                  ),
                if (result.biodegradabilityYears != null)
                  _buildMetricRow(
                    '⏱️',
                    'Biodégradation',
                    '${result.biodegradabilityYears} ans',
                  ),

                const SizedBox(height: 16),

                // Alternatives écologiques
                if (result.alternatives.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '💡 Alternatives écologiques:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result.alternatives
                      .take(3)
                      .map(
                        (alt) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(color: Colors.green),
                              ),
                              Expanded(
                                child: Text(
                                  alt,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],

                // Conseil écologique du jour
                if (result.funFact?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 Le saviez-vous ?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.funFact!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _lastScanResult = null;
                          });
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Scanner autre'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Fermer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
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

  String _getImpactText(EnvironmentalImpact impact) {
    switch (impact) {
      case EnvironmentalImpact.low:
        return 'Faible';
      case EnvironmentalImpact.medium:
        return 'Moyen';
      case EnvironmentalImpact.high:
        return 'Élevé';
    }
  }
}

class ScanOverlayPainter extends CustomPainter {
  final List<ImageLabel> detectedLabels;
  final bool isDetecting;
  final double animationValue;

  ScanOverlayPainter({
    required this.detectedLabels,
    required this.isDetecting,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = detectedLabels.isNotEmpty ? Colors.green : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scanSize = size.width * 0.7;

    // Cercle de scan principal avec couleur dynamique
    canvas.drawCircle(Offset(centerX, centerY), scanSize / 2, paint);

    // Animation de scan améliorée
    if (isDetecting) {
      final animationPaint = Paint()
        ..color = Colors.green.withOpacity(0.2 + (animationValue * 0.3))
        ..style = PaintingStyle.fill;

      // Effet de pulsation
      final pulseFactor = 0.8 + (animationValue * 0.2);
      canvas.drawCircle(
        Offset(centerX, centerY),
        (scanSize / 2) * pulseFactor,
        animationPaint,
      );

      // Ligne de scan qui bouge
      final scanLinePaint = Paint()
        ..color = Colors.green.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final top = centerY - scanSize / 2;
      final left = centerX - scanSize / 2;
      final right = centerX + scanSize / 2;
      final scanY = top + (animationValue * scanSize);
      canvas.drawLine(Offset(left, scanY), Offset(right, scanY), scanLinePaint);
    }

    // Indicateurs visuels pour objets détectés
    if (detectedLabels.isNotEmpty) {
      final targetPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Petits cercles autour du centre pour indiquer détection
      for (int i = 0; i < detectedLabels.length && i < 3; i++) {
        final angle = (i * 2 * 3.14159) / 3;
        final targetX = centerX + (scanSize / 3) * 0.8 * cos(angle);
        final targetY = centerY + (scanSize / 3) * 0.8 * sin(angle);

        canvas.drawCircle(Offset(targetX, targetY), 8, targetPaint);
        canvas.drawCircle(
          Offset(targetX, targetY),
          4,
          Paint()
            ..color = Colors.green.withOpacity(0.6)
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Coins du cadre de scan
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final left = centerX - scanSize / 2;
    final right = centerX + scanSize / 2;
    final top = centerY - scanSize / 2;
    final bottom = centerY + scanSize / 2;

    // Coin top-left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top)
        ..lineTo(left + cornerLength, top),
      cornerPaint,
    );

    // Coin top-right
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, top)
        ..lineTo(right, top)
        ..lineTo(right, top + cornerLength),
      cornerPaint,
    );

    // Coin bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerLength)
        ..lineTo(left, bottom)
        ..lineTo(left + cornerLength, bottom),
      cornerPaint,
    );

    // Coin bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, bottom)
        ..lineTo(right, bottom)
        ..lineTo(right, bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
