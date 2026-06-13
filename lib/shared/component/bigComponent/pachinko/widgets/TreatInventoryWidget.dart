import 'package:flutter/material.dart';
import '../painters/treat_painter.dart';

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Treats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              maxTreats,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildTreatIcon(index < remainingTreats),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$remainingTreats / $maxTreats',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatIcon(bool isFilled) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isFilled ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFilled ? const Color(0xFF8B7355) : Colors.white.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: CustomPaint(
        painter: TreatPainter(
          color: isFilled ? const Color(0xFFD2B48C) : Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }
}
