import 'package:flutter/material.dart';
import '../theme/pixel_art_theme.dart';

/// Full-width horizontal energy bar with level display
class HorizontalEnergyBar extends StatefulWidget {
  final int currentLevel;
  final double currentEnergy;
  final double maxEnergy;
  final double targetEnergy;

  const HorizontalEnergyBar({
    super.key,
    required this.currentLevel,
    required this.currentEnergy,
    required this.maxEnergy,
    required this.targetEnergy,
  });

  @override
  State<HorizontalEnergyBar> createState() => _HorizontalEnergyBarState();
}

class _HorizontalEnergyBarState extends State<HorizontalEnergyBar>
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
  void didUpdateWidget(HorizontalEnergyBar oldWidget) {
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
      height: 24,
      color: PixelArtTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Level display on left
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: PixelArtTheme.pixelContainer(
              color: PixelArtTheme.accent,
            ),
            child: Text(
              'LV ${widget.currentLevel}',
              style: PixelArtTheme.pixelText(
                fontSize: 6,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Progress bar on right (fills remaining space)
          Expanded(
            child: AnimatedBuilder(
              animation: _fillAnimation,
              builder: (context, child) {
                final fillPercentage = _fillAnimation.value;
                return Container(
                  height: 16,
                  decoration: PixelArtTheme.pixelProgressBarContainer(),
                  child: Stack(
                    children: [
                      // Progress fill
                      FractionallySizedBox(
                        widthFactor: fillPercentage,
                        child: Container(
                          decoration: PixelArtTheme.pixelProgressBarFill(
                            color: PixelArtTheme.energyFill,
                          ),
                        ),
                      ),
                      // Energy text centered in bar
                      Center(
                        child: Text(
                          '${widget.targetEnergy.toInt()}/${widget.maxEnergy.toInt()}',
                          style: PixelArtTheme.pixelText(
                            fontSize: 6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
