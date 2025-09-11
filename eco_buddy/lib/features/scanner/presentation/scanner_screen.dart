import 'package:eco_buddy/features/scanner/domain/models/scan_result_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/scanner_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/card_widget.dart';
import 'camera_scanner_screen.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scanner AR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Scanner avec caméra',
            onPressed: () => _openCameraScanner(context),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: scannerState.when(
        data: (state) => _buildScannerContent(context, ref, state),
        loading: () => _buildLoadingScreen(),
        error: (error, _) => _buildErrorScreen(context, error.toString()),
      ),
    );
  }

  Widget _buildScannerContent(
    BuildContext context,
    WidgetRef ref,
    ScannerState state,
  ) {
    if (!state.isCameraReady) {
      return _buildCameraSetupScreen(context, ref);
    }

    return Stack(
      children: [
        // Mock camera preview (replace with actual AR camera when AR plugin is integrated)
        _buildMockCameraPreview(context, ref, state),

        // Overlay UI
        _buildScannerOverlay(context, ref, state),

        // Bottom sheet with scan results
        if (state.lastScanResult != null)
          _buildResultBottomSheet(context, ref, state.lastScanResult!),
      ],
    );
  }

  Widget _buildMockCameraPreview(
    BuildContext context,
    WidgetRef ref,
    ScannerState state,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a), Color(0xFF1a1a1a)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: state.isScanning
                      ? const Color(AppConstants.accentColor)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: state.isScanning
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(AppConstants.accentColor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Analyse en cours...',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Icon(
                      Icons.camera_alt_outlined,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              state.isScanning
                  ? 'Reconnaissance de l\'objet...'
                  : 'Pointez votre caméra vers un objet',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'L\'IA analysera l\'impact environnemental',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(
    BuildContext context,
    WidgetRef ref,
    ScannerState state,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Flash toggle
            _buildControlButton(
              icon: state.isFlashOn ? Icons.flash_on : Icons.flash_off,
              label: 'Flash',
              onPressed: () => ref.read(scannerProvider.notifier).toggleFlash(),
            ),

            // Scan button
            GestureDetector(
              onTap: state.isScanning
                  ? null
                  : () => ref.read(scannerProvider.notifier).startScan(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: state.isScanning
                      ? Colors.grey.withValues(alpha: 0.5)
                      : const Color(AppConstants.accentColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(
                  state.isScanning ? Icons.stop : Icons.camera_alt,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

            // History/Gallery
            _buildControlButton(
              icon: Icons.history,
              label: 'Historique',
              onPressed: () => _showScanHistory(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildResultBottomSheet(
    BuildContext context,
    WidgetRef ref,
    ScanResultModel result,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getImpactColor(
                              result.environmentalImpact,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getObjectIcon(result.objectType ?? 'unknown'),
                            color: _getImpactColor(result.environmentalImpact),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.objectName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Impact: ${_getImpactLabel(result.environmentalImpact)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getImpactColor(
                                    result.environmentalImpact,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              AppConstants.accentColor,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${result.points}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(AppConstants.accentColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Environmental info
                    _buildInfoSection(
                      'Impact environnemental',
                      result.environmentalInfo,
                      Icons.eco,
                      _getImpactColor(result.environmentalImpact),
                    ),
                    const SizedBox(height: 16),

                    // Recycling suggestions
                    if (result.recyclingSuggestions.isNotEmpty) ...[
                      _buildInfoSection(
                        'Conseils de recyclage',
                        result.recyclingSuggestions.join('\n'),
                        Icons.recycling,
                        const Color(AppConstants.primaryColor),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Alternative suggestions
                    if (result.alternatives.isNotEmpty) ...[
                      _buildInfoSection(
                        'Alternatives écologiques',
                        result.alternatives.join('\n'),
                        Icons.lightbulb_outline,
                        const Color(AppConstants.warningColor),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref
                                .read(scannerProvider.notifier)
                                .saveResult(result),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                AppConstants.primaryColor,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Sauvegarder'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref
                                .read(scannerProvider.notifier)
                                .shareResult(result),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(
                                AppConstants.primaryColor,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(
                                color: Color(AppConstants.primaryColor),
                              ),
                            ),
                            child: const Text('Partager'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraSetupScreen(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(
                  AppConstants.primaryColor,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 50,
                color: Color(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Configuration de la caméra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'L\'application a besoin d\'accéder à votre caméra pour scanner les objets et analyser leur impact environnemental.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () =>
                  ref.read(scannerProvider.notifier).initializeCamera(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.accentColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Autoriser la caméra',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(AppConstants.primaryColor),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Initialisation du scanner...',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(AppConstants.errorColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur du scanner',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getImpactColor(EnvironmentalImpact impact) {
    switch (impact) {
      case EnvironmentalImpact.low:
        return const Color(AppConstants.accentColor);
      case EnvironmentalImpact.medium:
        return const Color(AppConstants.warningColor);
      case EnvironmentalImpact.high:
        return const Color(AppConstants.errorColor);
    }
  }

  String _getImpactLabel(EnvironmentalImpact impact) {
    switch (impact) {
      case EnvironmentalImpact.low:
        return 'Faible';
      case EnvironmentalImpact.medium:
        return 'Modéré';
      case EnvironmentalImpact.high:
        return 'Élevé';
    }
  }

  IconData _getObjectIcon(String objectType) {
    switch (objectType.toLowerCase()) {
      case 'plastic':
        return Icons.recycling;
      case 'glass':
        return Icons.wine_bar;
      case 'metal':
        return Icons.construction;
      case 'paper':
        return Icons.article;
      case 'electronic':
        return Icons.phonelink;
      case 'textile':
        return Icons.checkroom;
      default:
        return Icons.category;
    }
  }

  void _openCameraScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScannerScreen(),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comment utiliser le scanner'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Pointez votre caméra vers un objet'),
            SizedBox(height: 8),
            Text('2. Appuyez sur le bouton de scan'),
            SizedBox(height: 8),
            Text('3. Attendez l\'analyse IA'),
            SizedBox(height: 8),
            Text('4. Découvrez l\'impact environnemental'),
            SizedBox(height: 8),
            Text('5. Gagnez des points écologiques !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showScanHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Historique des scans',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: 3, // Mock history items
                  itemBuilder: (context, index) => _buildHistoryItem(
                    'Bouteille en plastique',
                    'Il y a 2 heures',
                    Icons.recycling,
                    '+5 points',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String time,
    IconData icon,
    String points,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(
                  AppConstants.primaryColor,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(AppConstants.primaryColor),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              points,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
