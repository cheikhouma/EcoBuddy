import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/point_animation_widget.dart';

class ChoiceResultDialog extends StatefulWidget {
  final int pointsEarned;
  final int totalPoints;
  final String choiceMade;
  final bool isStoryCompleted;
  final VoidCallback onContinue;
  final VoidCallback onFinish;
  final int previousTotalPoints;

  const ChoiceResultDialog({
    super.key,
    required this.pointsEarned,
    required this.totalPoints,
    required this.choiceMade,
    required this.isStoryCompleted,
    required this.onContinue,
    required this.onFinish,
  }) : previousTotalPoints = totalPoints - pointsEarned;

  @override
  State<ChoiceResultDialog> createState() => _ChoiceResultDialogState();
}

class _ChoiceResultDialogState extends State<ChoiceResultDialog>
    with TickerProviderStateMixin {
  bool _showPointAnimation = true;
  bool _showCounterAnimation = false;

  @override
  void initState() {
    super.initState();
    // Délai pour démarrer l'animation du compteur après l'animation des points
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showCounterAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(AppConstants.primaryColor).withValues(alpha: 0.03),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Points earned animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(
                      AppConstants.accentColor,
                    ).withValues(alpha: 0.2),
                    const Color(
                      AppConstants.accentColor,
                    ).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.eco,
                size: 40,
                color: Color(AppConstants.accentColor),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.isStoryCompleted
                  ? AppLocalizations.of(context)!.storyCompleted
                  : AppLocalizations.of(context)!.goodChoice,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Choice made
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
              child: Text(
                '"${widget.choiceMade}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // 🚀 ZONE D'ANIMATION DES POINTS
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  // Points display container
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(
                              AppConstants.accentColor,
                            ).withValues(alpha: 0.15),
                            const Color(
                              AppConstants.accentColor,
                            ).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              // 🚀 ANIMATION DES POINTS VOLANTS
                              if (_showPointAnimation)
                                PointAnimationWidget(
                                  points: widget.pointsEarned,
                                  pointColor: const Color(AppConstants.accentColor),
                                  onComplete: () {
                                    setState(() {
                                      _showPointAnimation = false;
                                    });
                                  },
                                )
                              else
                                Text(
                                  '+${widget.pointsEarned}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(AppConstants.accentColor),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.pointsEarneds,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 40, color: Colors.grey[300]),
                          Column(
                            children: [
                              // 🚀 ANIMATION DU COMPTEUR TOTAL
                              if (_showCounterAnimation)
                                AnimatedPointCounter(
                                  targetPoints: widget.totalPoints,
                                  previousPoints: widget.previousTotalPoints,
                                  duration: const Duration(milliseconds: 1000),
                                  textStyle: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(AppConstants.primaryColor),
                                  ),
                                )
                              else
                                Text(
                                  '${widget.previousTotalPoints}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(AppConstants.primaryColor),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.totalPoints,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
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
            const SizedBox(height: 24),

            // Buttons
            if (widget.isStoryCompleted) ...[
              // Story completed - only finish button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.primaryColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.celebration, size: 20),
                  label: Text(
                    AppLocalizations.of(context)!.viewResults,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Story continues - continue and finish buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onFinish,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(
                          alpha: 0.2,
                        ),
                        foregroundColor: const Color(AppConstants.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      icon: const Icon(Icons.stop, size: 18, color: Colors.red),
                      label: Text(
                        AppLocalizations.of(context)!.finish,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppConstants.primaryColor),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text(
                        AppLocalizations.of(context)!.continueStory,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
