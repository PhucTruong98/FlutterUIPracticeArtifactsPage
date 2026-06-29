import 'package:flutter/material.dart';
import '../theme/pixel_art_theme.dart';

/// Button to load a treat onto the Pachinko board
class LoadTreatButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const LoadTreatButton({
    super.key,
    required this.onPressed,
    required this.enabled,
  });

  @override
  State<LoadTreatButton> createState() => _LoadTreatButtonState();
}

class _LoadTreatButtonState extends State<LoadTreatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(LoadTreatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If enabled state changed while button was being pressed, reset animation
    if (oldWidget.enabled != widget.enabled && !widget.enabled) {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = true);
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: widget.enabled
                  ? PixelArtTheme.pixelButton(
                      color: PixelArtTheme.primary,
                      isPressed: _isPressed,
                    )
                  : PixelArtTheme.pixelContainer(
                      color: PixelArtTheme.disabled,
                    ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LOAD',
                    style: PixelArtTheme.pixelText(
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
