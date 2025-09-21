import 'package:eco_buddy/core/widgets/floating_particles.dart';
import 'package:eco_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  List<OnboardingPage> _getPages(BuildContext context) {
    return [
      OnboardingPage(
        icon: Icons.camera_enhance_rounded,
        emoji: '📱',
        title: AppLocalizations.of(context)!.smartARScanner,
        description: AppLocalizations.of(context)!.discoverEcologicalImpact,
        color: const Color(0xFF2E7D32),
        features: [
          AppLocalizations.of(context)!.geminiAI,
          AppLocalizations.of(context)!.realTime,
          AppLocalizations.of(context)!.alternatives,
        ],
      ),
      OnboardingPage(
        icon: Icons.auto_stories_rounded,
        emoji: '📚',
        title: AppLocalizations.of(context)!.interactiveStories,
        description: AppLocalizations.of(context)!.liveEcologicalAdventures,
        color: const Color(0xFF1565C0),
        features: [
          AppLocalizations.of(context)!.multipleChoices,
          AppLocalizations.of(context)!.points,
          AppLocalizations.of(context)!.suspense,
        ],
      ),
      OnboardingPage(
        icon: Icons.eco_rounded,
        emoji: '🌱',
        title: AppLocalizations.of(context)!.dailyGreenChallenges,
        description: AppLocalizations.of(context)!.transformYourDaily,
        color: const Color(0xFF388E3C),
        features: [
          AppLocalizations.of(context)!.gamification,
          AppLocalizations.of(context)!.rewards,
          AppLocalizations.of(context)!.progress,
        ],
      ),
      OnboardingPage(
        icon: Icons.groups_rounded,
        emoji: '🌍',
        title: AppLocalizations.of(context)!.ecoCitizensCommunity,
        description: AppLocalizations.of(context)!.joinThousandsOfEcoWarriors,
        color: const Color(0xFF00695C),
        features: [
          AppLocalizations.of(context)!.ranking,
          AppLocalizations.of(context)!.sharing,
          AppLocalizations.of(context)!.impact,
        ],
      ),
    ];
  }

  void _nextPage(BuildContext context) {
    final pages = _getPages(context);
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              pages[_currentPage].color.withValues(alpha: 0.9),
              pages[_currentPage].color,
              pages[_currentPage].color.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.5, 1.0],
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
                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return _buildPage(pages[index]);
                      },
                    ),
                  ),

                  // Page indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: _currentPage == index ? 32 : 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                              border: _currentPage == index
                                  ? Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _currentPage == index
                                ? Center(
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: pages[_currentPage].color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height < 700 ? 16.0 : 24.0,
                    ),
                    child: Row(
                      children: [
                        // Previous button
                        if (_currentPage > 0)
                          Expanded(
                            child: AnimatedScale(
                              scale: _currentPage > 0 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                height: MediaQuery.of(context).size.height < 700
                                    ? 48
                                    : 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 2,
                                  ),
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                child: TextButton.icon(
                                  onPressed: _previousPage,
                                  icon: const Icon(
                                    Icons.arrow_back_ios_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.previous,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                              350
                                          ? 14
                                          : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),

                        const SizedBox(width: 16),

                        // Next/Get Started button
                        Expanded(
                          flex: _currentPage == pages.length - 1 ? 1 : 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: MediaQuery.of(context).size.height < 700
                                ? 48
                                : 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withValues(alpha: 0.95),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 1.0, end: 1.0),
                              duration: const Duration(milliseconds: 100),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale.clamp(0.8, 1.2),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Petit effet de bounce
                                      setState(() {});
                                      _nextPage(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    icon: Icon(
                                      _currentPage == pages.length - 1
                                          ? Icons.rocket_launch_rounded
                                          : Icons.arrow_forward_ios_rounded,
                                      color: pages[_currentPage].color,
                                      size: 22,
                                    ),
                                    label: Text(
                                      _currentPage == pages.length - 1
                                          ? AppLocalizations.of(
                                              context,
                                            )!.getStarted
                                          : AppLocalizations.of(context)!.next,
                                      style: TextStyle(
                                        color: pages[_currentPage].color,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                350
                                            ? (_currentPage == pages.length - 1
                                                  ? 14
                                                  : 13)
                                            : (_currentPage == pages.length - 1
                                                  ? 17
                                                  : 16),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
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

  Widget _buildPage(OnboardingPage page) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height > 0 ? size.height : 800.0;
    final screenWidth = size.width > 0 ? size.width : 400.0;
    final isSmallScreen = screenHeight < 700;
    final isNarrowScreen = screenWidth < 350;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrowScreen ? 16.0 : 32.0,
        vertical: isSmallScreen ? 10 : 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenHeight * 0.7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji Hero + Animated Icon
            TweenAnimationBuilder(
              key: ValueKey(_currentPage),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutBack,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value.clamp(0.0, 1.5),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle with pulse animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final baseSize = isSmallScreen ? 150.0 : 200.0;
                          final pulseValue = _pulseController.value.clamp(
                            0.0,
                            1.0,
                          );
                          return Container(
                            width:
                                baseSize +
                                (pulseValue * (isSmallScreen ? 15 : 20)),
                            height:
                                baseSize +
                                (pulseValue * (isSmallScreen ? 15 : 20)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: (0.1 + (pulseValue * 0.05)).clamp(
                                  0.0,
                                  1.0,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(
                                    alpha: (0.2 + (pulseValue * 0.1)).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                  ),
                                  blurRadius: 30 + (pulseValue * 10),
                                  spreadRadius: 10 + (pulseValue * 5),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Inner circle
                      Container(
                        width: isSmallScreen ? 100 : 140,
                        height: isSmallScreen ? 100 : 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Large Emoji
                            Text(
                              page.emoji,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 35 : 50,
                              ),
                            ),
                            // Icon overlay
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  page.icon,
                                  size: isSmallScreen ? 18 : 24,
                                  color: page.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: isSmallScreen ? 30 : 50),

            // Title with slide animation
            TweenAnimationBuilder(
              key: ValueKey('title_$_currentPage'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Text(
                      page.title,
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? 28
                            : (isNarrowScreen ? 32 : 36),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: isSmallScreen ? 1.1 : 1.2,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: isSmallScreen ? 15 : 20),

            // Description with fade-in
            TweenAnimationBuilder(
              key: ValueKey('desc_$_currentPage'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Text(
                      page.description,
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? 15
                            : (isNarrowScreen ? 16 : 18),
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w400,
                        height: isSmallScreen ? 1.4 : 1.6,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: isSmallScreen ? 4 : 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: isSmallScreen ? 25 : 40),

            // Features pills
            TweenAnimationBuilder(
              key: ValueKey('features_$_currentPage'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isNarrowScreen ? 8 : 12,
                      runSpacing: isNarrowScreen ? 6 : 8,
                      children: page.features
                          .map(
                            (feature) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isNarrowScreen ? 12 : 16,
                                vertical: isSmallScreen ? 6 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                feature,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final List<String> features;

  OnboardingPage({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.features,
  });
}
