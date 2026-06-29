import 'package:flutter/material.dart';
import '../theme/pixel_art_theme.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: PixelArtTheme.pixelContainer(
        color: PixelArtTheme.accent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ENERGY',
            style: PixelArtTheme.pixelText(
              fontSize: 8,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _fillAnimation,
            builder: (context, child) {
              final fillPercentage = _fillAnimation.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 20,
                    decoration: PixelArtTheme.pixelProgressBarContainer(),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: fillPercentage,
                          child: Container(
                            decoration: PixelArtTheme.pixelProgressBarFill(
                              color: PixelArtTheme.energyFill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.targetEnergy.toInt()}/${widget.maxEnergy.toInt()} (${(fillPercentage * 100).toInt()}%)',
                    style: PixelArtTheme.pixelText(
                      fontSize: 6,
                      color: Colors.white,
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
