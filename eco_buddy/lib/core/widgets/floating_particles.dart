import 'dart:math';
import 'package:flutter/material.dart';

class FloatingParticles extends StatefulWidget {
  final Color color;
  final int particleCount;

  const FloatingParticles({
    super.key,
    required this.color,
    this.particleCount = 15,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    particles = List.generate(
      widget.particleCount,
      (index) => Particle(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            animation: _controller,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speedX;
  late double speedY;
  late double opacity;

  Particle() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = 2 + random.nextDouble() * 6;
    speedX = (random.nextDouble() - 0.5) * 0.02;
    speedY = (random.nextDouble() - 0.5) * 0.02;
    opacity = 0.3 + random.nextDouble() * 0.4;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Update particle position
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      // Wrap around edges
      if (particle.x > 1.0) particle.x = 0.0;
      if (particle.x < 0.0) particle.x = 1.0;
      if (particle.y > 1.0) particle.y = 0.0;
      if (particle.y < 0.0) particle.y = 1.0;

      // Breathing animation
      final breathe = sin(animation.value * 2 * pi + particle.x * 10) * 0.5 + 0.5;
      final currentSize = (particle.size * (0.8 + breathe * 0.4)).clamp(0.0, 20.0);
      final currentOpacity = (particle.opacity * (0.6 + breathe * 0.4)).clamp(0.0, 1.0);

      paint.color = color.withValues(alpha: currentOpacity.clamp(0.0, 1.0));

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        currentSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}