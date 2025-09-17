import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/narration_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/card_widget.dart';
import '../../../core/widgets/animated_loading_widget.dart';
import '../../../core/widgets/point_animation_widget.dart';
import '../domain/models/story_history_model.dart';
import 'widgets/choice_result_dialog.dart';
import 'story_detail_screen.dart';

class NarrationScreen extends ConsumerWidget {
  const NarrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final narrationState = ref.watch(narrationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.interactiveStories,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPointsInfoDialog(context),
            tooltip: AppLocalizations.of(context)!.pointsInfoTooltip,
          ),
        ],
      ),
      floatingActionButton: narrationState.when(
        data: (state) => !state.hasActiveStory
            ? FloatingActionButton(
                onPressed: () =>
                    ref.read(narrationProvider.notifier).startNewStory(),
                backgroundColor: const Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
      body: narrationState.when(
        data: (state) => Stack(
          children: [
            _buildMainContent(context, ref, state),
            // Afficher le dialogue si nécessaire
            if (state.showChoiceDialog)
              _buildChoiceResultDialog(context, ref, state),
          ],
        ),
        loading: () => _buildLoadingScreen(context),
        error: (error, _) => _buildErrorContent(context, ref, error.toString()),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    NarrationState state,
  ) {
    // Si une histoire est en cours, afficher l'interface de lecture
    if (state.hasActiveStory) {
      return _buildActiveStoryContent(context, ref, state);
    }

    // Sinon, afficher l'historique des histoires
    return _buildHistoryContent(context, ref, state);
  }

  Widget _buildActiveStoryContent(
    BuildContext context,
    WidgetRef ref,
    NarrationState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story progress indicator
          _buildProgressIndicator(context, state),
          const SizedBox(height: 20),

          // Story content
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.currentStory!.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ChapterTransition(
                  transitionKey: state.currentStory!.id,
                  child: TypewriterText(
                    text: state.currentStory!.content,
                    speed: const Duration(milliseconds: 40),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Choices
          if (state.currentStory!.choices.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.whatDoYouWantToDo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...state.currentStory!.choices.asMap().entries.map(
              (entry) =>
                  _buildChoiceButton(context, ref, entry.key, entry.value),
            ),
          ] else ...[
            // Story completed
            _buildStoryCompletedSection(context, ref, state),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryContent(
    BuildContext context,
    WidgetRef ref,
    NarrationState state,
  ) {
    if (!state.hasHistory) {
      return _buildEmptyHistoryScreen(context, ref);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats header
          _buildHistoryStats(context, state),
          const SizedBox(height: 24),

          // History title
          Text(
            AppLocalizations.of(context)!.yourStories,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // History list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.storyHistory!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final story = state.storyHistory![index];
              return _buildHistoryItem(context, story);
            },
          ),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryScreen(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(
                  AppConstants.primaryColor,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 40,
                color: Color(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noStoriesYet,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.startFirstEcoAdventure,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryStats(BuildContext context, NarrationState state) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: AppLocalizations.of(context)!.storiesCompleted,
            value: '${state.completedStoriesCount}',
            icon: Icons.check_circle,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: AppLocalizations.of(context)!.totalPointsEarned,
            value: '${state.totalHistoryPoints}',
            icon: Icons.eco,
            color: const Color(AppConstants.accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, StoryHistoryModel story) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(story: story),
          ),
        );
      },
      child: CustomCard(
        backgroundColor: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _getThemeColor(story.theme).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        child: Row(
          children: [
            // Theme icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getThemeColor(story.theme).withValues(alpha: 0.2),
                    _getThemeColor(story.theme).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getThemeColor(story.theme).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _getThemeIcon(story.theme),
                color: _getThemeColor(story.theme),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Story info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getThemeColor(
                            story.theme,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          story.themeDisplayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getThemeColor(story.theme),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        story.formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Points and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      AppConstants.accentColor,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco,
                        size: 14,
                        color: Color(AppConstants.accentColor),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${story.totalPoints}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(AppConstants.accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.status.icon,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, NarrationState state) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.primaryColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Color(AppConstants.primaryColor),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.storyProgress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.chapter(state.currentStory!.chapterNumber),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.accentColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  size: 14,
                  color: Color(AppConstants.accentColor),
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.currentStory!.points}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.accentColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(
    BuildContext context,
    WidgetRef ref,
    int index,
    String choice,
  ) {
    final narrationState = ref.watch(narrationProvider);
    final isProcessing = narrationState.value?.isProcessingChoice ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: PulsatingChoiceButton(
        isEnabled: !isProcessing,
        onTap: isProcessing ? null : () { // 🚀 DÉSACTIVER SI EN COURS
          HapticFeedback.lightImpact();
          ref.read(narrationProvider.notifier).makeChoice(index);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isProcessing ? Colors.grey[100] : Colors.white, // 🚀 COULEUR ADAPTÉE
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isProcessing
                ? Colors.grey.withValues(alpha: 0.3) // 🚀 BORDURE GRISÉE
                : const Color(AppConstants.primaryColor).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isProcessing
                    ? Colors.grey.withValues(alpha: 0.1) // 🚀 COULEUR GRISÉE
                    : const Color(AppConstants.primaryColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: isProcessing
                    ? SizedBox( // 🚀 SPINNER DE CHARGEMENT
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey[600],
                        ),
                      )
                    : Text(
                        String.fromCharCode(65 + index), // A, B, C
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isProcessing
                            ? Colors.grey[600] // 🚀 TEXTE GRISÉ
                            : const Color(AppConstants.primaryColor),
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  choice,
                  style: TextStyle(
                    fontSize: 16,
                    color: isProcessing ? Colors.grey[600] : Colors.black87, // 🚀 TEXTE GRISÉ
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCompletedSection(
    BuildContext context,
    WidgetRef ref,
    NarrationState state,
  ) {
    return CustomCard(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.accentColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.celebration,
              size: 30,
              color: Color(AppConstants.accentColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.congratulations,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.storyCompletedSuccessfully,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(
                AppConstants.accentColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco,
                  size: 16,
                  color: Color(AppConstants.accentColor),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.ecologicalPointsEarned(state.totalPointsEarned),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(AppConstants.accentColor),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(narrationProvider.notifier).startNewStory(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.primaryColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.newStory),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref.read(narrationProvider.notifier).reset(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(AppConstants.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.mainMenu),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(AppConstants.errorColor),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.oopsAnErrorOccurred,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.refresh(narrationProvider),
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
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceResultDialog(
    BuildContext context,
    WidgetRef ref,
    NarrationState state,
  ) {
    return ChoiceResultDialog(
      pointsEarned: state.lastPointsEarned,
      totalPoints: state.totalPointsEarned,
      choiceMade: state.lastChoiceMade ?? '',
      isStoryCompleted: state.isCompleted,
      onContinue: () => ref.read(narrationProvider.notifier).continueStory(),
      onFinish: () => ref.read(narrationProvider.notifier).finishStory(),
    );
  }

  void _showPointsInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  const Color(
                    AppConstants.primaryColor,
                  ).withValues(alpha: 0.01),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header avec icône
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(
                          AppConstants.primaryColor,
                        ).withValues(alpha: 0.2),
                        const Color(
                          AppConstants.primaryColor,
                        ).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 30,
                    color: Color(AppConstants.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Titre
                Text(
                  AppLocalizations.of(context)!.pointsSystemTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Explication des points
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(
                        AppConstants.primaryColor,
                      ).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPointRow(
                        context,
                        '30+',
                        AppLocalizations.of(context)!.excellentChoice,
                        AppLocalizations.of(context)!.excellentChoiceDesc,
                        const Color(0xFF4CAF50),
                      ),
                      _buildPointRow(
                        context,
                        '20-29',
                        AppLocalizations.of(context)!.goodChoiceTitle,
                        AppLocalizations.of(context)!.goodChoiceDesc,
                        const Color(0xFF8BC34A),
                      ),
                      _buildPointRow(
                        context,
                        '10-19',
                        AppLocalizations.of(context)!.averageChoice,
                        AppLocalizations.of(context)!.averageChoiceDesc,
                        const Color(0xFFFFC107),
                      ),
                      _buildPointRow(
                        context,
                        '5-9',
                        AppLocalizations.of(context)!.suboptimalChoice,
                        AppLocalizations.of(context)!.suboptimalChoiceDesc,
                        const Color(0xFFFF9800),
                      ),
                      _buildPointRow(
                        context,
                        '0-4',
                        AppLocalizations.of(context)!.problematicChoice,
                        AppLocalizations.of(context)!.problematicChoiceDesc,
                        const Color(0xFFE91E63),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Note explicative
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(
                      AppConstants.accentColor,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: const Color(AppConstants.accentColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.aiEvaluationNote,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton fermer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryColor),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.understood,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointRow(
    BuildContext context,
    String points,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              points,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
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
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final narrationState = ref.watch(narrationProvider);

        // Déterminer si c'est une nouvelle histoire ou une continuation
        final isNewStory = narrationState.value?.currentStory == null;

        // 🚀 NOUVEAU LOADING ANIMÉ AVEC MESSAGES CONTEXTUELS
        return Center(
          child: NarrationLoadingWidget(
            isGeneratingStory: isNewStory,
          ),
        );
      },
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme.toLowerCase()) {
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

  IconData _getThemeIcon(String theme) {
    switch (theme.toLowerCase()) {
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
