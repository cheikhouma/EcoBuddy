import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'unified_scanner_screen.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Scanner EcoBuddy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildScannerModeSelection(context),
    );
  }

  Widget _buildScannerModeSelection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choisissez votre mode de scan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Différents modes pour différents besoins',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Mode Rapide
          _buildModeCard(
            context,
            title: 'Scanner Rapide',
            subtitle: 'Scan instantané avec cache intelligent',
            description: 'Idéal pour une identification rapide d\'objets courants. Utilise le cache pour des résultats immédiats.',
            icon: Icons.flash_on,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UnifiedScannerScreen(
                  initialMode: ScanMode.quick,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Mode AR
          _buildModeCard(
            context,
            title: 'Scanner AR Temps Réel',
            subtitle: 'Détection continue avec ML Kit',
            description: 'Scanner en continu avec détection automatique d\'objets. Perfect pour explorer votre environnement.',
            icon: Icons.camera_alt,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UnifiedScannerScreen(
                  initialMode: ScanMode.ar,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Mode Détaillé
          _buildModeCard(
            context,
            title: 'Scanner Détaillé',
            subtitle: 'Analyse approfondie avec TensorFlow Lite',
            description: 'Analyse complète avec intelligence artificielle avancée pour des résultats précis.',
            icon: Icons.analytics,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UnifiedScannerScreen(
                  initialMode: ScanMode.detailed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black26,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
