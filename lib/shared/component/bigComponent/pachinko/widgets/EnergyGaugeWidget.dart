import 'package:flutter/material.dart';

/// Animated energy gauge widget for puppy
class EnergyGaugeWidget extends StatefulWidget {
  final double currentEnergy;
  final double maxEnergy;
  final double targetEnergy;

  const EnergyGaugeWidget({
    super.key,
    required this.currentEnergy,
    required this.maxEnergy,
    required this.targetEnergy,
  });

  @override
  State<EnergyGaugeWidget> createState() => _EnergyGaugeWidgetState();
}

class _EnergyGaugeWidgetState extends State<EnergyGaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fillAnimation = Tween<double>(
      begin: widget.currentEnergy / widget.maxEnergy,
      end: widget.targetEnergy / widget.maxEnergy,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(EnergyGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.targetEnergy != widget.targetEnergy) {
      _animationController.reset();
      _fillAnimation = Tween<double>(
        begin: oldWidget.targetEnergy / widget.maxEnergy,
        end: widget.targetEnergy / widget.maxEnergy,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB84D).withOpacity(0.9),
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
            'Puppy Energy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _fillAnimation,
            builder: (context, child) {
              final fillPercentage = _fillAnimation.value;
              return Column(
                children: [
                  Container(
                    width: 200,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: fillPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF4CAF50),
                                    const Color(0xFF8BC34A),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.targetEnergy.toInt()} / ${widget.maxEnergy.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(fillPercentage * 100).toInt()}% Full',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
