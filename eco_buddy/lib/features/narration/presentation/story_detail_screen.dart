import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/card_widget.dart';
import '../domain/models/story_history_model.dart';
import '../../../shared/providers/narration_provider.dart';

class StoryDetailScreen extends ConsumerWidget {
  final StoryHistoryModel story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.storyDetails,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(AppConstants.primaryColor),
                const Color(AppConstants.primaryColor).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut
            _buildStoryHeader(context),
            const SizedBox(height: 24),

            // Statistiques
            _buildStatsSection(context),
            const SizedBox(height: 24),

            // Résumé de l'histoire
            _buildStorySummary(context),
            const SizedBox(height: 24),

            // Informations détaillées
            _buildDetailedInfo(context),
            const SizedBox(height: 32),

            // Actions
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _getThemeColor().withValues(alpha: 0.1),
            _getThemeColor().withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getThemeColor().withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomCard(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getThemeColor().withValues(alpha: 0.2),
                        _getThemeColor().withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _getThemeColor().withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getThemeIcon(),
                    size: 30,
                    color: _getThemeColor(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.themeDisplayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getThemeColor(),
                          fontWeight: FontWeight.w600,
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
                    color: story.status == StoryStatus.completed
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : const Color(0xFFFF9800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        story.status.icon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        story.status.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: story.status == StoryStatus.completed
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getThemeColor().withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    story.formattedDate(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: AppLocalizations.of(context)!.pointsEarneds,
            value: '${story.totalPoints}',
            icon: Icons.eco,
            color: const Color(AppConstants.accentColor),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: AppLocalizations.of(context)!.chapters,
            value: '${story.chapterCount}',
            icon: Icons.auto_stories,
            color: const Color(AppConstants.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStorySummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getThemeColor(),
                      _getThemeColor().withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.storySummary,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          backgroundColor: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _getThemeColor().withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getThemeColor().withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Text(
              story.summary,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(AppConstants.secondaryColor),
                      const Color(
                        AppConstants.secondaryColor,
                      ).withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.detailedInformation,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          child: Column(
            children: [
              // _buildInfoRow(
              //   AppLocalizations.of(context)!.sessionId,
              //   story.sessionId,
              // ),
              _buildInfoRow(
                AppLocalizations.of(context)!.ecologicalTheme,
                story.themeDisplayName,
              ),
              _buildInfoRow(
                AppLocalizations.of(context)!.completionDate,
                '${story.completedAt.day}/${story.completedAt.month}/${story.completedAt.year}',
              ),
              _buildInfoRow(
                AppLocalizations.of(context)!.status,
                story.status.displayName,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Fermer cette page et démarrer une nouvelle histoire
              Navigator.of(context).pop();
              ref.read(narrationProvider.notifier).startNewStory();
            },
            icon: const Icon(Icons.auto_stories, size: 20),
            label: Text(
              AppLocalizations.of(context)!.newSimilarStory,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 20),
            label: Text(
              AppLocalizations.of(context)!.backToHistory,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(AppConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(
                color: Color(AppConstants.primaryColor),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getThemeColor() {
    switch (story.theme.toLowerCase()) {
      case 'transport':
        return const Color(0xFF2196F3); // Bleu
      case 'energy':
      case 'energie':
        return const Color(0xFFFFC107); // Jaune
      case 'food':
      case 'alimentation':
        return const Color(0xFF4CAF50); // Vert
      case 'waste':
      case 'dechets':
        return const Color(0xFF795548); // Marron
      case 'water':
      case 'eau':
        return const Color(0xFF00BCD4); // Cyan
      case 'biodiversity':
      case 'biodiversite':
        return const Color(0xFF8BC34A); // Vert clair
      default:
        return const Color(AppConstants.primaryColor); // Vert principal
    }
  }

  IconData _getThemeIcon() {
    switch (story.theme.toLowerCase()) {
      case 'transport':
        return Icons.directions_car;
      case 'energy':
      case 'energie':
        return Icons.flash_on;
      case 'food':
      case 'alimentation':
        return Icons.restaurant;
      case 'waste':
      case 'dechets':
        return Icons.delete;
      case 'water':
      case 'eau':
        return Icons.water_drop;
      case 'biodiversity':
      case 'biodiversite':
        return Icons.nature;
      default:
        return Icons.eco;
    }
  }
}
