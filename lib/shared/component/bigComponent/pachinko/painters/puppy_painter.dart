import 'package:flutter/material.dart';
import 'dart:math' as math;

/// CustomPainter for drawing a cute cartoon puppy
class PuppyPainter extends CustomPainter {
  final double size;
  final bool isHappy;

  PuppyPainter({
    this.size = 1.0,
    this.isHappy = false,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final headRadius = canvasSize.width * 0.35;

    // Head
    final headPaint = Paint()
      ..color = const Color(0xFFFFD700) // Golden color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, headRadius, headPaint);

    // Ears (floppy)
    final earPaint = Paint()
      ..color = const Color(0xFFDAA520) // Darker golden
      ..style = PaintingStyle.fill;

    // Left ear
    final leftEarPath = Path();
    leftEarPath.moveTo(center.dx - headRadius * 0.6, center.dy - headRadius * 0.4);
    leftEarPath.quadraticBezierTo(
      center.dx - headRadius * 1.2,
      center.dy - headRadius * 0.2,
      center.dx - headRadius * 0.8,
      center.dy + headRadius * 0.3,
    );
    canvas.drawPath(leftEarPath, earPaint);

    // Right ear
    final rightEarPath = Path();
    rightEarPath.moveTo(center.dx + headRadius * 0.6, center.dy - headRadius * 0.4);
    rightEarPath.quadraticBezierTo(
      center.dx + headRadius * 1.2,
      center.dy - headRadius * 0.2,
      center.dx + headRadius * 0.8,
      center.dy + headRadius * 0.3,
    );
    canvas.drawPath(rightEarPath, earPaint);

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final eyeSize = isHappy ? headRadius * 0.08 : headRadius * 0.12;

    // Left eye
    if (isHappy) {
      // Happy eyes (curved lines)
      final eyeLinePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final leftEyePath = Path();
      leftEyePath.moveTo(center.dx - headRadius * 0.25, center.dy - headRadius * 0.15);
      leftEyePath.quadraticBezierTo(
        center.dx - headRadius * 0.15,
        center.dy - headRadius * 0.05,
        center.dx - headRadius * 0.05,
        center.dy - headRadius * 0.15,
      );
      canvas.drawPath(leftEyePath, eyeLinePaint);

      final rightEyePath = Path();
      rightEyePath.moveTo(center.dx + headRadius * 0.05, center.dy - headRadius * 0.15);
      rightEyePath.quadraticBezierTo(
        center.dx + headRadius * 0.15,
        center.dy - headRadius * 0.05,
        center.dx + headRadius * 0.25,
        center.dy - headRadius * 0.15,
      );
      canvas.drawPath(rightEyePath, eyeLinePaint);
    } else {
      // Normal eyes (circles)
      canvas.drawCircle(
        Offset(center.dx - headRadius * 0.25, center.dy - headRadius * 0.1),
        eyeSize,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + headRadius * 0.25, center.dy - headRadius * 0.1),
        eyeSize,
        eyePaint,
      );
    }

    // Nose
    final nosePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy + headRadius * 0.1),
      headRadius * 0.1,
      nosePaint,
    );

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    mouthPath.moveTo(center.dx, center.dy + headRadius * 0.15);
    mouthPath.lineTo(center.dx, center.dy + headRadius * 0.25);

    // Smile
    final smilePath = Path();
    smilePath.moveTo(center.dx - headRadius * 0.2, center.dy + headRadius * 0.25);
    smilePath.quadraticBezierTo(
      center.dx,
      center.dy + headRadius * 0.4,
      center.dx + headRadius * 0.2,
      center.dy + headRadius * 0.25,
    );

    canvas.drawPath(mouthPath, mouthPaint);
    canvas.drawPath(smilePath, mouthPaint);

    // Add sparkles when happy
    if (isHappy) {
      final sparklePaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;

      _drawSparkle(canvas, Offset(center.dx - headRadius * 1.1, center.dy - headRadius * 0.8), 8, sparklePaint);
      _drawSparkle(canvas, Offset(center.dx + headRadius * 1.1, center.dy - headRadius * 0.8), 8, sparklePaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final outerX = center.dx + math.cos(angle) * size;
      final outerY = center.dy + math.sin(angle) * size;
      final innerX = center.dx + math.cos(angle + math.pi / 4) * (size * 0.3);
      final innerY = center.dy + math.sin(angle + math.pi / 4) * (size * 0.3);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PuppyPainter oldDelegate) {
    return oldDelegate.size != size || oldDelegate.isHappy != isHappy;
  }
}
