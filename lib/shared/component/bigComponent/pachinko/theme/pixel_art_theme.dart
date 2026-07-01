import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pixel art theme for retro gaming aesthetic
/// Provides consistent styling for all UI elements outside the Flame game
class PixelArtTheme {
  // Color Palette - Keeping existing colors but using them as flat colors
  static const Color background = Color(0xFF2C3E50);      // Dark blue-gray background
  static const Color primary = Color(0xFFFF6B35);         // Orange
  static const Color secondary = Color(0xFF9B59B6);       // Purple
  static const Color accent = Color(0xFFFFB84D);          // Yellow-orange
  static const Color success = Color(0xFF27AE60);         // Green
  static const Color energyFill = Color(0xFF4CAF50);      // Energy bar green

  // Border Colors
  static const Color border = Color(0xFF000000);          // Black borders
  static const Color borderLight = Color(0xFFFFFFFF);     // White for inset effect

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);     // White
  static const Color textSecondary = Color(0xFFCCCCCC);   // Light gray

  /// Pixel text style using Press Start 2P font
  ///
  /// This is the classic retro gaming font
  /// Use smaller sizes (6-12px) as it's very bold and wide
  static TextStyle pixelText({
    double fontSize = 12,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.normal,
    double? height,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height ?? 1.5, // Press Start 2P needs more line height
    );
  }

  /// Standard pixel art container decoration
  ///
  /// Sharp corners, solid color, black border
  /// No shadows, no gradients - pure pixel art
  static BoxDecoration pixelContainer({
    required Color color,
    double borderWidth = 3,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color,
      border: Border.all(
        color: borderColor ?? border,
        width: borderWidth,
      ),
      // NO borderRadius - sharp corners only!
      // NO boxShadow - use borders instead
    );
  }

  /// Pixel art button decoration with inset/outset effect
  ///
  /// Creates a 3D effect using different border colors
  /// When pressed, borders are inverted for "pushed in" look
  static BoxDecoration pixelButton({
    required Color color,
    bool isPressed = false,
    double borderWidth = 3,
  }) {
    return BoxDecoration(
      color: color,
      border: Border(
        top: BorderSide(
          color: isPressed ? border : borderLight,
          width: borderWidth,
        ),
        left: BorderSide(
          color: isPressed ? border : borderLight,
          width: borderWidth,
        ),
        right: BorderSide(
          color: isPressed ? borderLight : border,
          width: borderWidth,
        ),
        bottom: BorderSide(
          color: isPressed ? borderLight : border,
          width: borderWidth,
        ),
      ),
    );
  }

  /// Pixel art progress bar container
  ///
  /// For energy gauge and similar progress indicators
  static BoxDecoration pixelProgressBarContainer() {
    return BoxDecoration(
      color: Color(0xFF2C3E50),
      border: Border.all(color: border, width: 2),
    );
  }

  /// Pixel art progress bar fill
  ///
  /// Solid color fill for progress bars
  static BoxDecoration pixelProgressBarFill({
    required Color color,
  }) {
    return BoxDecoration(
      color: color,
      // No border needed - container provides it
    );
  }

  /// Top sky placeholder background
  ///
  /// Stepped gradient mimicking pixel art sky
  /// TODO: Replace with DecorationImage using topSkyBackdrop.png when available
  static BoxDecoration topSkyPlaceholder() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF87CEEB), // Sky blue (lighter at top)
          Color(0xFF7EC0EE), // Medium sky blue
          Color(0xFF63B8FF), // Deeper sky blue (darker at bottom)
        ],
        stops: [0.0, 0.5, 1.0], // Banded effect for pixel art look
      ),
    );
  }

  /// Ground/grass placeholder background
  ///
  /// Stepped gradient mimicking pixel art ground with grass
  /// TODO: Replace with DecorationImage using groundBackdrop.png when available
  static BoxDecoration groundPlaceholder() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF228B22), // Forest green (grass at top)
          Color(0xFF6B4423), // Brown (dirt middle)
          Color(0xFF4A3728), // Dark brown (deep soil at bottom)
        ],
        stops: [0.0, 0.4, 1.0], // Banded effect showing soil layers
      ),
    );
  }

  /// Disabled/inactive color
  ///
  /// For disabled buttons and inactive elements
  static Color get disabled => const Color(0xFF666666);

  /// Get appropriate text color for background
  ///
  /// Helper to ensure text is readable on different backgrounds
  static Color textColorFor(Color backgroundColor) {
    // Simple luminance check
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? border : textPrimary;
  }
}
