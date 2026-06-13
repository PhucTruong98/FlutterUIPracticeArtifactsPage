import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// CustomPainter for drawing Pachinko pegs with gradient
class PegPainter extends CustomPainter {
  final double size;
  final bool isHit;

  PegPainter({
    this.size = 1.0,
    this.isHit = false,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = canvasSize.width * 0.4;

    // Gradient colors - brighter when hit
    final gradientColors = isHit
        ? [
            const Color(0xFFFFD700), // Bright gold
            const Color(0xFFFFA500), // Orange
            const Color(0xFFFF8C00), // Dark orange
          ]
        : [
            const Color(0xFFFF8C00), // Dark orange
            const Color(0xFFFFA500), // Orange
            const Color(0xFFFFB84D), // Light orange
          ];

    // Create radial gradient
    final gradient = RadialGradient(
      colors: gradientColors,
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;

    // Draw main circle
    canvas.drawCircle(center, radius, paint);

    // Add shine effect on top
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final shineCenter = Offset(
      center.dx - radius * 0.25,
      center.dy - radius * 0.25,
    );
    canvas.drawCircle(shineCenter, radius * 0.3, shinePaint);

    // Add outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, outlinePaint);

    // If hit, add glow effect
    if (isHit) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(center, radius * 1.3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(PegPainter oldDelegate) {
    return oldDelegate.size != size || oldDelegate.isHit != isHit;
  }
}
