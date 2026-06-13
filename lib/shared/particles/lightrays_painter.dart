import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for rotating light rays effect
///
/// Creates a sunburst/light rays effect radiating from the center.
/// Used for:
/// - Egg reveal phase (rotating rays around egg)
/// - Reward reveal card (rotating rays behind reward icon)
class LightRaysPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final int rayCount;
  final double rayLength;
  final double innerRadius;

  LightRaysPainter({
    required this.animationValue,
    required this.color,
    this.rayCount = 12,
    this.rayLength = 0.5,
    this.innerRadius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    // Create gradient for rays
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus; // Additive blending for glow effect

    // Rotate rays based on animation value
    final rotationAngle = animationValue * math.pi * 2;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount) + rotationAngle;

      // Calculate ray vertices
      final innerX = center.dx + math.cos(angle) * maxRadius * innerRadius;
      final innerY = center.dy + math.sin(angle) * maxRadius * innerRadius;

      final outerX = center.dx + math.cos(angle) * maxRadius * rayLength;
      final outerY = center.dy + math.sin(angle) * maxRadius * rayLength;

      // Calculate perpendicular offsets for ray width
      final perpAngle = angle + math.pi / 2;
      final widthAtInner = maxRadius * 0.03;
      final widthAtOuter = maxRadius * 0.01;

      final innerLeft = Offset(
        innerX + math.cos(perpAngle) * widthAtInner,
        innerY + math.sin(perpAngle) * widthAtInner,
      );
      final innerRight = Offset(
        innerX - math.cos(perpAngle) * widthAtInner,
        innerY - math.sin(perpAngle) * widthAtInner,
      );
      final outerPoint = Offset(outerX, outerY);

      // Create gradient from center to edge (fade out)
      final rayGradient = RadialGradient(
        center: Alignment.center,
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.4),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      // Draw ray as triangle
      final path = Path()
        ..moveTo(innerLeft.dx, innerLeft.dy)
        ..lineTo(outerPoint.dx, outerPoint.dy)
        ..lineTo(innerRight.dx, innerRight.dy)
        ..close();

      // Apply gradient
      paint.shader = rayGradient.createShader(
        Rect.fromCircle(
          center: center,
          radius: maxRadius * rayLength,
        ),
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(LightRaysPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        color != oldDelegate.color ||
        rayCount != oldDelegate.rayCount;
  }
}

/// Variant: Pulsing glow ring effect
///
/// Creates concentric rings that pulse outward.
/// Used for panda "ready to hatch" glow effect.
class PulsingGlowPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final int ringCount;

  PulsingGlowPainter({
    required this.animationValue,
    required this.color,
    this.ringCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < ringCount; i++) {
      // Stagger rings with delay
      final ringDelay = i * 0.3;
      final ringValue = ((animationValue - ringDelay) % 1.0).clamp(0.0, 1.0);

      final radius = maxRadius * ringValue;
      final opacity = (1.0 - ringValue) * 0.6;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(PulsingGlowPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

/// Variant: Sparkle burst effect
///
/// Creates small sparkles that burst outward.
/// Used for egg crack moments.
class SparkleBurstPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final int sparkleCount;

  SparkleBurstPainter({
    required this.animationValue,
    required this.color,
    this.sparkleCount = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < sparkleCount; i++) {
      final angle = (i * 2 * math.pi / sparkleCount);
      final distance = maxRadius * 0.3 * animationValue;

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      // Fade out as sparkles move outward
      final opacity = (1.0 - animationValue).clamp(0.0, 1.0);
      final size = 8.0 * (1.0 - animationValue * 0.5);

      paint.color = color.withOpacity(opacity);

      // Draw sparkle as 4-pointed star
      _drawSparkle(canvas, Offset(x, y), size, paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // Draw cross/plus shape
    // Horizontal line
    path.moveTo(center.dx - size, center.dy);
    path.lineTo(center.dx + size, center.dy);

    // Vertical line
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx, center.dy + size);

    canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 2);

    // Add center circle
    canvas.drawCircle(center, size * 0.3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(SparkleBurstPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
