import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Confetti burst effect using Flame's ParticleSystemComponent
///
/// Creates particles based on slot multiplier:
/// - 1.2x (green): Small burst, 15 particles
/// - 1.5x (orange): Medium burst, 25 particles
/// - 1.7x (gold): PREMIUM burst, 50+ rainbow particles + sparkles
class ConfettiEffect extends Component {
  ConfettiEffect({
    required this.position,
    required this.multiplier,
  });

  static final SMALL_BURST_COUNT = 15;
  static final MEDIUM_BURST_COUNT = 25;
  static final PREMIUM_BURST_COUNT = 50;
  static final SPARKLE_COUNT = 20;

  static final SMALL_BURST_LIFESPAN = 1.0;
  static final MEDIUM_BURST_LIFESPAN = 1.0;
  static final PREMIUM_BURST_LIFESPAN = 2.0;
  static final SPARKLE_LIFESPAN = 3.0;

  static final SMALL_BURST_RADIUS = 18.0;
  static final MEDIUM_BURST_RADIUS = 18.0;
  static final PREMIUM_BURST_RADIUS = 18.0;
  static final SPARKLE_RADIUS = 18.0;

  final Vector2 position;
  final double multiplier;

  static final Random _random = Random();
  static const double gravity = 15.0;

  // Cached objects shared across all particles to avoid allocations
  static final Paint _sharedPaint = Paint();
  static final Map<double, Path> _starPathCache = {};
  static final Map<double, Rect> _rectCache = {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create particle system based on tier
    final particleComponent = _createParticleSystem();
    parent?.add(particleComponent);

    // This component can remove itself immediately
    // ParticleSystemComponent will handle its own lifecycle
    removeFromParent();
  }

  /// Create appropriate particle system based on multiplier
  ParticleSystemComponent _createParticleSystem() {
    if (multiplier >= 1.7) {
      return _createPremiumBurst();
    } else if (multiplier >= 1.5) {
      return _createMediumBurst();
    } else {
      return _createSmallBurst();
    }
  }

  /// Small confetti burst for outer slots (1.2x multiplier)
  ParticleSystemComponent _createSmallBurst() {
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: SMALL_BURST_COUNT,
        lifespan: SMALL_BURST_LIFESPAN,  
        generator: (i) => _createConfettiParticle(
          color: const Color(0xFF4CAF50), // Green
          burstRadius: SMALL_BURST_RADIUS,
          lifetime: SMALL_BURST_LIFESPAN,
        ),
      ),
    );
  }

  /// Medium confetti burst for inner slots (1.5x multiplier)
  ParticleSystemComponent _createMediumBurst() {
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: MEDIUM_BURST_COUNT,
        lifespan: MEDIUM_BURST_LIFESPAN,
        generator: (i) => _createConfettiParticle(
          color: const Color(0xFFFF9800), // Orange
          burstRadius: MEDIUM_BURST_RADIUS,
          lifetime: MEDIUM_BURST_LIFESPAN,
        ),
      ),
    );
  }

  /// Premium confetti burst for center slot (1.7x multiplier)
  ParticleSystemComponent _createPremiumBurst() {
    const rainbowColors = [
      Color(0xFFFF0000), // Red
      Color(0xFFFF7F00), // Orange
      Color(0xFFFFFF00), // Yellow
      Color(0xFF00FF00), // Green
      Color(0xFF0000FF), // Blue
      Color(0xFF8B00FF), // Purple
    ];

    final particles = <Particle>[];

    // Rainbow confetti (50 particles)
    for (var i = 0; i < 50; i++) {
      particles.add(_createConfettiParticle(
        color: rainbowColors[i % rainbowColors.length],
        burstRadius: PREMIUM_BURST_RADIUS,
        lifetime: PREMIUM_BURST_LIFESPAN,
        shape: ConfettiShape.rectangle,
      ));
    }

    // Sparkle layer (20 white star particles)
    for (var i = 0; i < 20; i++) {
      particles.add(_createConfettiParticle(
        color: Colors.white,
        burstRadius: SPARKLE_RADIUS,
        lifetime: SPARKLE_LIFESPAN,
        shape: ConfettiShape.star,
        size: 0.15,
      ));
    }

    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: particles.length,
        lifespan: 3.0,
        generator: (i) => particles[i],
      ),
    );
  }

  /// Create a single confetti particle with physics and rendering
  Particle _createConfettiParticle({
    required Color color,
    required double burstRadius,
    required double lifetime,
    ConfettiShape shape = ConfettiShape.rectangle,
    double size = 0.25,
  }) {
    // Random angle (bias upward: -120° to -60°)
    final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi / 10;

    // Random speed within burst radius
    final speed = burstRadius * (0.7 + _random.nextDouble() * 0.6);

    // Random rotation speed
    final rotationSpeed = (_random.nextDouble() - 0.5) * pi * 2;

    return AcceleratedParticle(
      lifespan: lifetime,
      speed: Vector2(cos(angle) * speed, sin(angle) * speed),
      acceleration: Vector2(0, gravity),
      child: RotatingParticle(
        from: _random.nextDouble() * 2 * pi,
        to: _random.nextDouble() * 2 * pi + rotationSpeed * lifetime,
        child: _createShapeParticle(shape, color, size),
      ),
    );
  }

  /// Create the visual particle based on shape
  Particle _createShapeParticle(ConfettiShape shape, Color color, double size) {
    switch (shape) {
      case ConfettiShape.circle:
        return CircleParticle(
          radius: size / 2,
          paint: Paint()..color = color,
        );

      case ConfettiShape.rectangle:
        // Get or create cached Rect for this size
        final rect = _rectCache.putIfAbsent(
          size,
          () => Rect.fromCenter(
            center: Offset.zero,
            width: size,
            height: size * 1.5,
          ),
        );

        return ComputedParticle(
          renderer: (canvas, particle) {
            _sharedPaint.color = color.withOpacity(1.0 - particle.progress);
            canvas.drawRect(rect, _sharedPaint);
          },
        );

      case ConfettiShape.star:
        // Get or create cached star Path for this size
        final path = _starPathCache.putIfAbsent(size, () {
          final starPath = Path();
          for (var i = 0; i < 8; i++) {
            final angle = (i * pi / 4);
            final r = i.isEven ? size : size / 2.5;
            final x = cos(angle) * r;
            final y = sin(angle) * r;

            if (i == 0) {
              starPath.moveTo(x, y);
            } else {
              starPath.lineTo(x, y);
            }
          }
          starPath.close();
          return starPath;
        });

        return ComputedParticle(
          renderer: (canvas, particle) {
            _sharedPaint.color = color.withOpacity(1.0 - particle.progress);
            canvas.drawPath(path, _sharedPaint);
          },
        );
    }
  }
}

/// Shape variants for confetti particles
enum ConfettiShape {
  rectangle,
  circle,
  star,
}
