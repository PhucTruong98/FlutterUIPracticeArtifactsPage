import 'package:flutter/material.dart';
import '../painters/treat_painter.dart';
import '../theme/pixel_art_theme.dart';

/// Widget displaying remaining treats inventory
class TreatInventoryWidget extends StatelessWidget {
  final int remainingTreats;
  final int maxTreats;

  const TreatInventoryWidget({
    super.key,
    required this.remainingTreats,
    this.maxTreats = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: PixelArtTheme.pixelContainer(
        color: PixelArtTheme.primary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TREATS',
            style: PixelArtTheme.pixelText(
              fontSize: 6,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              maxTreats,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildTreatIcon(index < remainingTreats),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$remainingTreats/$maxTreats',
            style: PixelArtTheme.pixelText(
              fontSize: 6,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatIcon(bool isFilled) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isFilled ? Colors.white : Colors.white.withValues(alpha: 0.3),
        border: Border.all(
          color: isFilled ? const Color(0xFF8B7355) : Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
        // NO borderRadius - sharp corners for pixel art!
      ),
      child: CustomPaint(
        painter: TreatPainter(
          color: isFilled ? const Color(0xFFD2B48C) : Colors.grey.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
