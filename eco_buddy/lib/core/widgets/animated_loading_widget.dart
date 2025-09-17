import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class AnimatedLoadingWidget extends StatefulWidget {
  final List<String> messages;
  final String? estimatedTime;
  final bool showProgress;
  final Color? primaryColor;
  final Duration messageInterval;

  const AnimatedLoadingWidget({
    super.key,
    required this.messages,
    this.estimatedTime,
    this.showProgress = true,
    this.primaryColor,
    this.messageInterval = const Duration(seconds: 3),
  });

  @override
  State<AnimatedLoadingWidget> createState() => _AnimatedLoadingWidgetState();
}

class _AnimatedLoadingWidgetState extends State<AnimatedLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;

  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    // Animation de pulsation pour l'icône centrale
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animation de rotation pour l'indicateur
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Animation de progression
    _progressController = AnimationController(
      duration: const Duration(seconds: 15), // Estimation 15 secondes
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    // Démarrer les animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    if (widget.showProgress) {
      _progressController.forward();
    }

    // Timer pour changer les messages
    if (widget.messages.length > 1) {
      _messageTimer = Timer.periodic(widget.messageInterval, (timer) {
        if (mounted) {
          setState(() {
            _currentMessageIndex =
                (_currentMessageIndex + 1) % widget.messages.length;
          });
        }
      });
    }

    // Timer pour simuler progression réaliste
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Ajouter un peu de randomness pour réalisme
          final random = Random();
          final progress = _progressAnimation.value + (random.nextDouble() * 0.02);
          if (progress < 0.95) {
            _progressController.value = progress;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    _messageTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor ?? Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🚀 ICÔNE CENTRALE ANIMÉE
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Icon(
                            Icons.eco,
                            size: 40,
                            color: color,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // 🚀 BARRE DE PROGRESSION ANIMÉE
          if (widget.showProgress) ...[
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color.withValues(alpha: 0.1),
              ),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 🚀 POURCENTAGE
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // 🚀 MESSAGE ANIMÉ
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              widget.messages[_currentMessageIndex],
              key: ValueKey(_currentMessageIndex),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // 🚀 TEMPS ESTIMÉ
          if (widget.estimatedTime != null)
            Text(
              widget.estimatedTime!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}

// 🚀 WIDGET SPÉCIALISÉ POUR LA NARRATION
class NarrationLoadingWidget extends StatelessWidget {
  final bool isGeneratingStory;

  const NarrationLoadingWidget({
    super.key,
    this.isGeneratingStory = false,
  });

  @override
  Widget build(BuildContext context) {
    final messages = isGeneratingStory
        ? [
            "🌱 L'IA analyse votre impact écologique...",
            "🤖 Génération de votre aventure personnalisée...",
            "✨ Finalisation de votre histoire unique...",
          ]
        : [
            "🔮 Traitement de votre choix...",
            "🌍 Calcul des conséquences écologiques...",
            "📖 Préparation de la suite de l'histoire...",
          ];

    return AnimatedLoadingWidget(
      messages: messages,
      estimatedTime: isGeneratingStory ? "~15 secondes" : "~8 secondes",
      showProgress: true,
      primaryColor: const Color(0xFF4CAF50),
    );
  }
}