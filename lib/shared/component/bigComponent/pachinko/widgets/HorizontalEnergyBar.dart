import 'package:flutter/material.dart';
import '../theme/pixel_art_theme.dart';
import '../hud/energy_bar_controller.dart';

/// Full-width horizontal energy bar with level display.
/// Pure view - all animation state lives in the controller.
class HorizontalEnergyBar extends StatelessWidget {
  const HorizontalEnergyBar({super.key, required this.controller});

  final EnergyBarController controller;

  @override
  Widget build(BuildContext context) {
    // Rebuild on: display changes (ChangeNotifier) + fill ticks + flash ticks.
    return AnimatedBuilder(
      animation: Listenable.merge([controller, controller.fill, controller.flash]),
      builder: (context, _) {
        final fillPercent = controller.fillAnimation.value;
        final flashValue = controller.flash.value; // 0..1

        final displayedEnergy =
    (fillPercent * controller.maxEnergy).round();

        return Container(
          height: 24,
          color: PixelArtTheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Level display on left with flash animation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: PixelArtTheme.pixelContainer(
                  color: Color.lerp(
                    PixelArtTheme.accent,
                    Colors.white,
                    flashValue,
                  )!,
                ),
                child: Text(
                  'LV ${controller.level}',
                  style: PixelArtTheme.pixelText(
                    fontSize: 6,
                    color: flashValue > 0.5 ? Colors.black : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Progress bar on right (fills remaining space)
              Expanded(
                child: Container(
                  height: 16,
                  decoration: PixelArtTheme.pixelProgressBarContainer(),
                  child: Stack(
                    children: [
                      // Progress fill with flash animation
                      FractionallySizedBox(
                        widthFactor: fillPercent,
                        child: Container(
                          decoration: PixelArtTheme.pixelProgressBarFill(
                            color: Color.lerp(
                              PixelArtTheme.energyFill,
                              Colors.white,
                              flashValue,
                            )!,
                          ),
                        ),
                      ),
                      // Energy text centered in bar

                      
                      Center(
                        child: Text(
                          '${displayedEnergy.toInt()}/${controller.maxEnergy.toInt()}',
                          style: PixelArtTheme.pixelText(
                            fontSize: 6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
