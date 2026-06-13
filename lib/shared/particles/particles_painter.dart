import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Data class for a single particle
class Particle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double speed;
  final double size;
  final double rotation;
  final double delay;
  final ParticleShape shape;

  Particle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.delay,
    this.shape = ParticleShape.circle,
  });
}

/// Available particle shapes
enum ParticleShape {
  circle,
  star,
  sparkle,
  triangle,
}

/// Custom painter for floating/exploding particles animation
///
/// Supports different shapes and movement patterns:
/// - Floating particles (energy buildup phase)
/// - Explosion particles (hatch explosion phase)
/// - Confetti particles (celebration phase)
class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final Color color;
  final ParticleMode mode;

  ParticlesPainter({
    required this.particles,
    required this.animationValue,
    required this.color,
    this.mode = ParticleMode.floating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate position with delay
      final adjustedValue =
          ((animationValue - particle.delay) % 1.0).clamp(0.0, 1.0);
      if (adjustedValue == 0.0 && animationValue < particle.delay) continue;

      // Calculate position based on mode
      late double x, y;
      if (mode == ParticleMode.floating) {
        // Floating: gentle up and down motion
        x = particle.startX * size.width;
        y = particle.startY * size.height +
            (math.sin(adjustedValue * math.pi * 2) * 20);
      } else if (mode == ParticleMode.explosion) {
        // Explosion: move from center to edges
        x = particle.startX * size.width +
            ((particle.endX - particle.startX) * size.width * adjustedValue);
        y = particle.startY * size.height +
            ((particle.endY - particle.startY) * size.height * adjustedValue);
      } else {
        // Falling: drop down from top
        x = particle.startX * size.width;
        y = particle.startY * size.height +
            (adjustedValue * size.height * 1.3);
      }

      // Skip if off screen
      if (y > size.height || y < 0 || x < 0 || x > size.width) continue;

      // Calculate opacity fade
      final opacity = mode == ParticleMode.explosion
          ? (1.0 - adjustedValue).clamp(0.0, 1.0)
          : (1.0 - (adjustedValue - 0.5).abs() * 2).clamp(0.3, 1.0);

      // Draw particle
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + (animationValue * math.pi * 2));

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.9)
        ..style = PaintingStyle.fill;

      // Draw shape based on particle type
      _drawShape(canvas, particle.size, paint, particle.shape);

      canvas.restore();
    }
  }

  void _drawShape(Canvas canvas, double size, Paint paint, ParticleShape shape) {
    switch (shape) {
      case ParticleShape.circle:
        canvas.drawCircle(Offset.zero, size / 2, paint);
        break;
      case ParticleShape.star:
        _drawStar(canvas, size, paint);
        break;
      case ParticleShape.sparkle:
        _drawSparkle(canvas, size, paint);
        break;
      case ParticleShape.triangle:
        _drawTriangle(canvas, size, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final outerX = radius * math.cos(angle);
      final outerY = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerAngle = angle + math.pi / 5;
      final innerX = innerRadius * math.cos(innerAngle);
      final innerY = innerRadius * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;

    // Draw 4-pointed sparkle (diamond with points)
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) - math.pi / 4;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;

    // Draw equilateral triangle
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

/// Particle animation mode
enum ParticleMode {
  floating,  // Gentle floating motion (energy buildup)
  explosion, // Explode outward from center (hatch explosion)
  falling,   // Fall down from top (confetti)
}

/// Helper function to generate random particles
List<Particle> generateParticles({
  required int count,
  required ParticleMode mode,
  math.Random? random,
}) {
  final rng = random ?? math.Random();
  final particles = <Particle>[];

  for (int i = 0; i < count; i++) {
    if (mode == ParticleMode.floating) {
      // Floating particles scattered across screen
      particles.add(Particle(
        startX: rng.nextDouble(),
        startY: rng.nextDouble(),
        endX: rng.nextDouble(),
        endY: rng.nextDouble(),
        speed: 0.3 + rng.nextDouble() * 0.7,
        size: 4 + rng.nextDouble() * 8,
        rotation: rng.nextDouble() * math.pi * 2,
        delay: rng.nextDouble() * 0.5,
        shape: ParticleShape.values[rng.nextInt(ParticleShape.values.length)],
      ));
    } else if (mode == ParticleMode.explosion) {
      // Explosion particles from center outward
      final angle = rng.nextDouble() * math.pi * 2;
      final distance = 0.3 + rng.nextDouble() * 0.7;
      particles.add(Particle(
        startX: 0.5,
        startY: 0.5,
        endX: 0.5 + math.cos(angle) * distance,
        endY: 0.5 + math.sin(angle) * distance,
        speed: 0.5 + rng.nextDouble() * 0.5,
        size: 6 + rng.nextDouble() * 12,
        rotation: rng.nextDouble() * math.pi * 2,
        delay: rng.nextDouble() * 0.2,
        shape: ParticleShape.values[rng.nextInt(ParticleShape.values.length)],
      ));
    } else {
      // Falling confetti from top
      particles.add(Particle(
        startX: rng.nextDouble(),
        startY: -0.1 - rng.nextDouble() * 0.2,
        endX: rng.nextDouble(),
        endY: 1.0,
        speed: 0.3 + rng.nextDouble() * 0.7,
        size: 4 + rng.nextDouble() * 8,
        rotation: rng.nextDouble() * math.pi * 2,
        delay: rng.nextDouble() * 0.8,
        shape: ParticleShape.values[rng.nextInt(ParticleShape.values.length)],
      ));
    }
  }

  return particles;
}
