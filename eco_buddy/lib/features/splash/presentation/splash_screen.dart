import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<double> _progressValue;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse animation controller for background effect
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Logo animations
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animations
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Progress animation
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    // Start logo animation
    await _logoController.forward();

    // Start text animation
    _textController.forward();

    // Small delay then start progress
    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();

    // Check auth status while animations play
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted) {
      // Check if user is already authenticated
      final authState = ref.read(authProvider);

      if (authState.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(AppConstants.primaryColor),
              Color(AppConstants.secondaryColor),
              Color(AppConstants.accentColor),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles background
            Positioned.fill(
              child: FloatingParticles(
                color: Colors.white.withValues(alpha: 0.3),
                particleCount: MediaQuery.of(context).size.height < 700
                    ? 8
                    : 12,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo with pulse effect
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutBack,
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value.clamp(0.0, 1.5),
                              child: AnimatedBuilder(
                                animation: _logoController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _logoScale.value,
                                    child: Transform.rotate(
                                      angle: _logoRotation.value * 0.1,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Background pulse circle
                                          AnimatedBuilder(
                                            animation: _pulseController,
                                            builder: (context, child) {
                                              final pulseValue =
                                                  _pulseController.value.clamp(
                                                    0.0,
                                                    1.0,
                                                  );
                                              return Container(
                                                width: 200 + (pulseValue * 20),
                                                height: 200 + (pulseValue * 20),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white.withValues(
                                                    alpha:
                                                        (0.1 +
                                                                (pulseValue *
                                                                    0.05))
                                                            .clamp(0.0, 1.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white.withValues(
                                                        alpha:
                                                            (0.2 +
                                                                    (pulseValue *
                                                                        0.1))
                                                                .clamp(
                                                                  0.0,
                                                                  1.0,
                                                                ),
                                                      ),
                                                      blurRadius:
                                                          30 +
                                                          (pulseValue * 10),
                                                      spreadRadius:
                                                          10 + (pulseValue * 5),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          // Main logo container
                                          Container(
                                            width: 140,
                                            height: 140,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.3,
                                                ),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 20,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Main eco icon
                                                const Icon(
                                                  Icons.eco,
                                                  size: 70,
                                                  color: Colors.white,
                                                ),
                                                // Small overlay icon
                                                Positioned(
                                                  bottom: 15,
                                                  right: 15,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.9,
                                                          ),
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                          blurRadius: 8,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.stars,
                                                      size: 20,
                                                      color: Color(
                                                        AppConstants
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Animated Text
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _textSlide,
                              child: FadeTransition(
                                opacity: _textOpacity,
                                child: Column(
                                  children: [
                                    Text(
                                      AppConstants.appName,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(
                                          alpha: _textOpacity.value,
                                        ),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.ecologicalAssistant,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70.withValues(
                                          alpha: _textOpacity.value,
                                        ),
                                        fontWeight: FontWeight.w300,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Features Preview
                  Expanded(
                    flex: 2,
                    child: AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _textOpacity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildFeatureItem(
                                  Icons.camera_enhance_rounded,
                                  AppLocalizations.of(context)!.arScanner,
                                  AppLocalizations.of(
                                    context,
                                  )!.scanObjectsDiscoverImpact,
                                ),
                                const SizedBox(height: 16),
                                _buildFeatureItem(
                                  Icons.auto_stories_rounded,
                                  AppLocalizations.of(
                                    context,
                                  )!.interactiveStories,
                                  AppLocalizations.of(
                                    context,
                                  )!.learnEcologyThroughAdventures,
                                ),
                                const SizedBox(height: 16),
                                _buildFeatureItem(
                                  Icons.emoji_events_rounded,
                                  AppLocalizations.of(
                                    context,
                                  )!.ecologicalChallenges,
                                  AppLocalizations.of(
                                    context,
                                  )!.takeChallengesEarnPoints,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Loading Progress
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Column(
                              children: [
                                Container(
                                  width: 200,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 200 * _progressValue.value,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(context)!.loadingText,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
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

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
