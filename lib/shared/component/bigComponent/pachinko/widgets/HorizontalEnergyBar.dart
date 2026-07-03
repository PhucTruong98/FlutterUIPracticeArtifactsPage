import 'package:flutter/material.dart';
import '../theme/pixel_art_theme.dart';

/// Full-width horizontal energy bar with level display
class HorizontalEnergyBar extends StatefulWidget {
  final int currentLevel;
  final double currentEnergy;
  final double maxEnergy;
  final double targetEnergy;
  final bool levelUpOccurred;

  const HorizontalEnergyBar({
    super.key,
    required this.currentLevel,
    required this.currentEnergy,
    required this.maxEnergy,
    required this.targetEnergy,
    required this.levelUpOccurred,
  });

  @override
  State<HorizontalEnergyBar> createState() => _HorizontalEnergyBarState();
}

class _HorizontalEnergyBarState extends State<HorizontalEnergyBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fillAnimation;
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();

    // Fill animation controller
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

    // Flash animation controller for level-up
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(HorizontalEnergyBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle level-up animation sequence
    if (widget.levelUpOccurred && !oldWidget.levelUpOccurred) {
      final oldEnergyPercent = oldWidget.targetEnergy / widget.maxEnergy;
      final newEnergyPercent = widget.targetEnergy / widget.maxEnergy;
      _startLevelUpSequence(oldEnergyPercent, newEnergyPercent);
    } else if (oldWidget.targetEnergy != widget.targetEnergy && !widget.levelUpOccurred) {
      // Normal energy update (no level-up)
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

  /// Async sequence for level-up animation: fill to 100% -> flash -> fill to new value
  Future<void> _startLevelUpSequence(double fromPercent, double toPercent) async {
    if (!mounted) return;

    // Step 1: Animate fill to 100%
    _animationController.reset();
    _fillAnimation = Tween<double>(
      begin: fromPercent,
      end: 1.0, // Fill to 100%
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    await _animationController.forward();

    if (!mounted) return;

    // Step 2: Flash animation (3 cycles)
    _flashController.reset();
    _flashController.repeat(reverse: true);

    // Calculate flash duration: 200ms per cycle * 2 (forward + reverse) * 3 cycles
    final flashDuration = _flashController.duration! * 2 * 3;
    await Future.delayed(flashDuration);

    if (!mounted) return;

    _flashController.stop();
    _flashController.value = 0.0;

    // Step 3: Reset to 0 and animate to new value
    _animationController.reset();
    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: toPercent,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    await _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flashController.dispose();
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
          // Level display on left with flash animation
          AnimatedBuilder(
            animation: _flashAnimation,
            builder: (context, child) {
              final flashValue = _flashAnimation.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: PixelArtTheme.pixelContainer(
                  color: Color.lerp(
                    PixelArtTheme.accent,
                    Colors.white,
                    flashValue,
                  )!,
                ),
                child: Text(
                  'LV ${widget.currentLevel}',
                  style: PixelArtTheme.pixelText(
                    fontSize: 6,
                    color: flashValue > 0.5 ? Colors.black : Colors.white,
                  ),
                ),
              );
            },
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
                      // Progress fill with flash animation
                      AnimatedBuilder(
                        animation: _flashAnimation,
                        builder: (context, child) {
                          final flashValue = _flashAnimation.value;
                          return FractionallySizedBox(
                            widthFactor: fillPercentage,
                            child: Container(
                              decoration: PixelArtTheme.pixelProgressBarFill(
                                color: Color.lerp(
                                  PixelArtTheme.energyFill,
                                  Colors.white,
                                  flashValue,
                                )!,
                              ),
                            ),
                          );
                        },
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
