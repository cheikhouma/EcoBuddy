import 'package:flutter/material.dart';
import 'dart:async';

class PointAnimationWidget extends StatefulWidget {
  final int points;
  final VoidCallback? onComplete;
  final Color? pointColor;

  const PointAnimationWidget({
    super.key,
    required this.points,
    this.onComplete,
    this.pointColor,
  });

  @override
  State<PointAnimationWidget> createState() => _PointAnimationWidgetState();
}

class _PointAnimationWidgetState extends State<PointAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _floatAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -2),
    ).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    // Animation de départ (float + fade)
    _floatController.forward();
    _fadeController.forward();

    // Callback après animation complète
    Timer(const Duration(milliseconds: 800), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.pointColor ?? const Color(0xFF4CAF50);

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation, _floatAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: _floatAnimation.value * 50,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.points}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🚀 WIDGET POUR COUNTER ANIMÉ DES POINTS TOTAUX
class AnimatedPointCounter extends StatefulWidget {
  final int targetPoints;
  final int previousPoints;
  final Duration duration;
  final TextStyle? textStyle;

  const AnimatedPointCounter({
    super.key,
    required this.targetPoints,
    required this.previousPoints,
    this.duration = const Duration(milliseconds: 800),
    this.textStyle,
  });

  @override
  State<AnimatedPointCounter> createState() => _AnimatedPointCounterState();
}

class _AnimatedPointCounterState extends State<AnimatedPointCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = IntTween(
      begin: widget.previousPoints,
      end: widget.targetPoints,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value} pts',
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
        );
      },
    );
  }
}

// 🚀 WIDGET POUR RÉVÉLATION PROGRESSIVE DU TEXTE
class TypewriterText extends StatefulWidget {
  final String text;
  final Duration speed;
  final TextStyle? textStyle;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 50),
    this.textStyle,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.textStyle,
    );
  }
}

// 🚀 WIDGET POUR PULSATION DES BOUTONS DE CHOIX
class PulsatingChoiceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isEnabled;

  const PulsatingChoiceButton({
    super.key,
    required this.child,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  State<PulsatingChoiceButton> createState() => _PulsatingChoiceButtonState();
}

class _PulsatingChoiceButtonState extends State<PulsatingChoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isEnabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsatingChoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isEnabled ? _animation.value : 1.0,
          child: GestureDetector(
            onTap: widget.isEnabled ? widget.onTap : null,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// 🚀 WIDGET POUR TRANSITION FLUIDE ENTRE CHAPITRES
class ChapterTransition extends StatefulWidget {
  final Widget child;
  final String transitionKey;

  const ChapterTransition({
    super.key,
    required this.child,
    required this.transitionKey,
  });

  @override
  State<ChapterTransition> createState() => _ChapterTransitionState();
}

class _ChapterTransitionState extends State<ChapterTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}