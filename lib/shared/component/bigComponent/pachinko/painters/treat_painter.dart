import 'package:flutter/material.dart';
import 'dart:math' as math;

/// CustomPainter for drawing a dog treat (bone shape)
class TreatPainter extends CustomPainter {
  final Color color;
  final double size;

  TreatPainter({
    this.color = const Color(0xFFD2B48C), // Tan color
    this.size = 1.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF8B7355) // Darker brown outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final boneLength = canvasSize.width * 0.6;
    final boneThickness = canvasSize.height * 0.15;
    final endRadius = canvasSize.width * 0.15;

    // Draw bone shape using path
    final path = Path();

    // Left end circles (top and bottom)
    final leftCenter = Offset(center.dx - boneLength / 2, center.dy);
    canvas.drawCircle(leftCenter + Offset(0, -endRadius * 0.5), endRadius * 0.6, paint);
    canvas.drawCircle(leftCenter + Offset(0, endRadius * 0.5), endRadius * 0.6, paint);

    // Right end circles (top and bottom)
    final rightCenter = Offset(center.dx + boneLength / 2, center.dy);
    canvas.drawCircle(rightCenter + Offset(0, -endRadius * 0.5), endRadius * 0.6, paint);
    canvas.drawCircle(rightCenter + Offset(0, endRadius * 0.5), endRadius * 0.6, paint);

    // Center bar
    final rectLeft = center.dx - boneLength / 2 + endRadius * 0.3;
    final rectRight = center.dx + boneLength / 2 - endRadius * 0.3;
    final rectTop = center.dy - boneThickness / 2;
    final rectBottom = center.dy + boneThickness / 2;

    final centerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom),
      const Radius.circular(8),
    );
    canvas.drawRRect(centerRect, paint);

    // Draw outlines
    canvas.drawCircle(leftCenter + Offset(0, -endRadius * 0.5), endRadius * 0.6, outlinePaint);
    canvas.drawCircle(leftCenter + Offset(0, endRadius * 0.5), endRadius * 0.6, outlinePaint);
    canvas.drawCircle(rightCenter + Offset(0, -endRadius * 0.5), endRadius * 0.6, outlinePaint);
    canvas.drawCircle(rightCenter + Offset(0, endRadius * 0.5), endRadius * 0.6, outlinePaint);
    canvas.drawRRect(centerRect, outlinePaint);
  }

  @override
  bool shouldRepaint(TreatPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.size != size;
  }
}
