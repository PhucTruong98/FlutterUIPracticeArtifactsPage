
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:practice1/shared/particles/egg_crack_painter.dart';
import 'package:practice1/shared/particles/lightrays_painter.dart';
import 'package:practice1/shared/particles/particles_painter.dart';

/// Full-screen overlay for 5-phase hatching animation
///
/// Phase breakdown (total 4 seconds):
/// 1. Fade Out (0.5s): Darken screen, fade in overlay
/// 2. Energy Build Up (1.0s): Animated gradient background, floating particles
/// 3. Egg Reveal (1.0s): Large egg scales in, rotating light rays
/// 4. Egg Cracking (1.0s): 3 progressive cracks with screen shake
/// 5. Hatch Explosion (0.5s): White flash, particle burst, confetti
///
/// Automatically advances through all phases when started.
/// Calls onComplete when animation finishes.
class HatchingAnimationOverlay extends StatefulWidget {

  const HatchingAnimationOverlay({
    super.key,
  });

  @override
  State<HatchingAnimationOverlay> createState() =>
      _HatchingAnimationOverlayState();
}

class _HatchingAnimationOverlayState extends State<HatchingAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _energyAnimation;
  late Animation<double> _eggAnimation;
  late Animation<double> _crackAnimation;
  late Animation<double> _explosionAnimation;

  // Particle lists
  late List<Particle> _floatingParticles;
  late List<Particle> _explosionParticles;

  // Current crack count (0-3)
  int _crackCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize particles
    _floatingParticles = generateParticles(
      count: 20,
      mode: ParticleMode.floating,
    );
    _explosionParticles = generateParticles(
      count: 40,
      mode: ParticleMode.explosion,
    );

    // Create main animation controller (4 seconds total)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Phase 1: Fade Out (0.0 - 0.125, 0.5s)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.125, curve: Curves.easeIn),
      ),
    );

    // Phase 2: Energy Build Up (0.125 - 0.375, 1.0s)
    _energyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.125, 0.375, curve: Curves.easeInOut),
      ),
    );

    // Phase 3: Egg Reveal (0.375 - 0.625, 1.0s)
    _eggAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.375, 0.625, curve: Curves.elasticOut),
      ),
    );

    // Phase 4: Egg Cracking (0.625 - 0.875, 1.0s)
    _crackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.625, 0.875, curve: Curves.easeInOut),
      ),
    );

    // Phase 5: Hatch Explosion (0.875 - 1.0, 0.5s)
    _explosionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.875, 1.0, curve: Curves.easeOut),
      ),
    );

    // Listen for crack timing (trigger cracks at specific intervals)
    _controller.addListener(() {
      // Crack 1 at 66% of crack phase
      if (_controller.value >= 0.66 && _crackCount == 0) {
        setState(() => _crackCount = 1);
        // TODO: Play crack sound
      }
      // Crack 2 at 75% of crack phase
      else if (_controller.value >= 0.75 && _crackCount == 1) {
        setState(() => _crackCount = 2);
        // TODO: Play crack sound
      }
      // Crack 3 at 84% of crack phase
      else if (_controller.value >= 0.84 && _crackCount == 2) {
        setState(() => _crackCount = 3);
        // TODO: Play crack sound
      }
    });

    // Call onComplete when animation finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
      }
    });

    // Start animation
    _controller.forward();

    // TODO: Play initial whoosh sound
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
        return Stack(
          children: [
            // Phase 1: Fade to dark
            if (_fadeAnimation.value > 0)
              Container(
                color: Colors.black.withOpacity(_fadeAnimation.value * 0.9),
              ),

            // Phase 2: Energy buildup background
            if (_energyAnimation.value > 0)
              _buildEnergyBackground(),

            // Phase 2: Floating particles
            if (_energyAnimation.value > 0 && _energyAnimation.value < 1)
              CustomPaint(
                size: Size.infinite,
                painter: ParticlesPainter(
                  particles: _floatingParticles,
                  animationValue: _energyAnimation.value,
                  color: Colors.white,
                  mode: ParticleMode.floating,
                ),
              ),

            // Phase 3: Egg with light rays
            if (_eggAnimation.value > 0 && _explosionAnimation.value < 0.5)
              _buildEggReveal(),

            // Phase 4: Egg cracks
            if (_crackAnimation.value > 0 && _explosionAnimation.value < 0.5)
              _buildEggCracks(),

            // Phase 5: Explosion white flash
            if (_explosionAnimation.value > 0)
              Container(
                color: Colors.white.withOpacity(
                  _explosionAnimation.value * (1.0 - _explosionAnimation.value) * 4,
                ),
              ),

            // Phase 5: Explosion particles
            if (_explosionAnimation.value > 0)
              CustomPaint(
                size: Size.infinite,
                painter: ParticlesPainter(
                  particles: _explosionParticles,
                  animationValue: _explosionAnimation.value,
                  color: Colors.amber,
                  mode: ParticleMode.explosion,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEnergyBackground() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.purple.withOpacity(0.3 + value * 0.4),
                Colors.blue.withOpacity(0.2 + value * 0.3),
                Colors.pink.withOpacity(0.1 + value * 0.2),
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEggReveal() {
    return Center(
      child: Transform.scale(
        scale: _eggAnimation.value,
        child: SizedBox(
          width: 300,
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating light rays behind egg
              CustomPaint(
                size: const Size(300, 400),
                painter: LightRaysPainter(
                  animationValue: _controller.value * 3, // Rotate faster
                  color: Colors.amber,
                  rayCount: 16,
                  rayLength: 0.8,
                  innerRadius: 0.1,
                ),
              ),

              // Egg with glow
              CustomPaint(
                size: const Size(300, 400),
                painter: EggShellPainter(
                  animationValue: _controller.value * 5, // Pulse faster
                  eggColor: Colors.white.withOpacity(0.9),
                  glowColor: Colors.amber,
                  showGlow: true,
                ),
              ),

              // Egg emoji as placeholder
              const Text(
                '🥚',
                style: TextStyle(fontSize: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEggCracks() {
    // Apply screen shake during cracks
    final shakeOffset = _crackCount > 0
        ? Offset(
            (math.Random().nextDouble() - 0.5) * 10 * _crackAnimation.value,
            (math.Random().nextDouble() - 0.5) * 10 * _crackAnimation.value,
          )
        : Offset.zero;

    return Transform.translate(
      offset: shakeOffset,
      child: Center(
        child: SizedBox(
          width: 300,
          height: 400,
          child: CustomPaint(
            size: const Size(300, 400),
            painter: EggCrackPainter(
              animationValue: _crackAnimation.value,
              crackCount: _crackCount,
              crackColor: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simplified version: Skip button overlay
///
/// Allows user to skip the animation (optional, not in initial spec).
/// Uncomment to enable skip functionality.
/*
class HatchingAnimationWithSkip extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const HatchingAnimationWithSkip({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HatchingAnimationOverlay(onComplete: onComplete),

        // Skip button (top-right)
        if (onSkip != null)
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: onSkip,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
*/
