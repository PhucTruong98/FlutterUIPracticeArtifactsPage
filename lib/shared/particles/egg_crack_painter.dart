import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for egg cracking animation
///
/// Draws progressive crack lines on an egg shape.
/// Used during Phase 4 of hatching animation (3 cracks).
class EggCrackPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0
  final int crackCount; // How many cracks have appeared (1, 2, or 3)
  final Color crackColor;

  EggCrackPainter({
    required this.animationValue,
    required this.crackCount,
    this.crackColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.6; // Egg width
    final height = size.height * 0.7; // Egg height

    final paint = Paint()
      ..color = crackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw cracks based on count
    if (crackCount >= 1) {
      _drawCrack1(canvas, center, width, height, paint, animationValue);
    }
    if (crackCount >= 2) {
      _drawCrack2(canvas, center, width, height, paint, animationValue);
    }
    if (crackCount >= 3) {
      _drawCrack3(canvas, center, width, height, paint, animationValue);
    }
  }

  /// First crack - vertical zigzag from top to middle
  void _drawCrack1(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    Paint paint,
    double progress,
  ) {
    final path = Path();

    // Start from top
    final startX = center.dx + width * 0.1;
    final startY = center.dy - height * 0.3;

    path.moveTo(startX, startY);

    // Create zigzag path
    final segments = 5;
    final segmentHeight = height * 0.4 / segments;
    final zigzagAmount = width * 0.05;

    for (int i = 0; i < segments; i++) {
      final y = startY + segmentHeight * (i + 1);
      final xOffset = (i % 2 == 0) ? zigzagAmount : -zigzagAmount;
      final x = startX + xOffset;

      path.lineTo(x, y);
    }

    // Draw with progress (animate path reveal)
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(
        0.0,
        metric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  /// Second crack - diagonal from left to right
  void _drawCrack2(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    Paint paint,
    double progress,
  ) {
    final path = Path();

    // Start from left side
    final startX = center.dx - width * 0.2;
    final startY = center.dy - height * 0.1;

    path.moveTo(startX, startY);

    // Create jagged diagonal path
    final points = [
      Offset(center.dx - width * 0.1, center.dy),
      Offset(center.dx, center.dy + height * 0.05),
      Offset(center.dx + width * 0.1, center.dy + height * 0.1),
      Offset(center.dx + width * 0.25, center.dy + height * 0.15),
    ];

    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }

    // Draw with progress
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(
        0.0,
        metric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  /// Third crack - horizontal from right side
  void _drawCrack3(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    Paint paint,
    double progress,
  ) {
    final path = Path();

    // Start from right side
    final startX = center.dx + width * 0.25;
    final startY = center.dy - height * 0.2;

    path.moveTo(startX, startY);

    // Create curved crack going down and left
    final points = [
      Offset(center.dx + width * 0.15, center.dy - height * 0.1),
      Offset(center.dx + width * 0.05, center.dy + height * 0.05),
      Offset(center.dx - width * 0.05, center.dy + height * 0.2),
    ];

    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }

    // Draw with progress
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(
        0.0,
        metric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(EggCrackPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        crackCount != oldDelegate.crackCount;
  }
}

/// Custom painter for egg shell with glow effect
///
/// Draws the egg outline with optional glow/pulse effect.
/// Used during Phase 3 (egg reveal).
class EggShellPainter extends CustomPainter {
  final double animationValue;
  final Color eggColor;
  final Color glowColor;
  final bool showGlow;

  EggShellPainter({
    required this.animationValue,
    this.eggColor = Colors.white,
    this.glowColor = const Color(0xFFFFD700), // Gold
    this.showGlow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.6;
    final height = size.height * 0.7;

    // Draw glow if enabled
    if (showGlow) {
      final glowPaint = Paint()
        ..color = glowColor.withOpacity(0.3 + math.sin(animationValue * math.pi * 2) * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      // Draw egg shape with glow
      final glowPath = _createEggPath(center, width * 1.2, height * 1.2);
      canvas.drawPath(glowPath, glowPaint);
    }

    // Draw main egg
    final eggPaint = Paint()
      ..color = eggColor
      ..style = PaintingStyle.fill;

    final eggPath = _createEggPath(center, width, height);
    canvas.drawPath(eggPath, eggPaint);

    // Draw egg outline
    final outlinePaint = Paint()
      ..color = eggColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(eggPath, outlinePaint);
  }

  Path _createEggPath(Offset center, double width, double height) {
    final path = Path();

    // Create egg shape using bezier curves
    final topY = center.dy - height / 2;
    final bottomY = center.dy + height / 2;
    final leftX = center.dx - width / 2;
    final rightX = center.dx + width / 2;

    // Start at top
    path.moveTo(center.dx, topY);

    // Right side (rounder at bottom)
    path.quadraticBezierTo(
      rightX, topY + height * 0.3,
      rightX * 0.9 + center.dx * 0.1, center.dy,
    );
    path.quadraticBezierTo(
      rightX * 0.8 + center.dx * 0.2, bottomY - height * 0.1,
      center.dx, bottomY,
    );

    // Left side (rounder at bottom)
    path.quadraticBezierTo(
      leftX * 0.8 + center.dx * 0.2, bottomY - height * 0.1,
      leftX * 0.9 + center.dx * 0.1, center.dy,
    );
    path.quadraticBezierTo(
      leftX, topY + height * 0.3,
      center.dx, topY,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(EggShellPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
