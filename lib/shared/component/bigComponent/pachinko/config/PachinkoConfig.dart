/// Centralized configuration for Pachinko game constants
/// Contains all game balance, physics, and animation values
class PachinkoConfig {
  // Private constructor to prevent instantiation
  PachinkoConfig._();

  // ========================================
  // SCORING & GAME RULES
  // ========================================

  /// Maximum energy capacity for puppy
  static const double maxPuppyEnergy = 900.0;

  /// Starting number of treats in player's inventory
  static const int initialTreats = 5;

  /// Points awarded per peg collision
  static const int pegHitPoints = 50;

  /// Score multipliers for each slot (left to right)
  /// [outer-left, inner-left, center, inner-right, outer-right]
  static const List<double> slotMultipliers = [1.2, 1.5, 1.7, 1.5, 1.2];

  // ========================================
  // PHYSICS
  // ========================================

  /// Downward gravity force (Y-axis)
  static const double gravity = 25.0;

  // --- Peg Physics ---
  /// Radius of peg collision bodies
  static const double pegRadius = 0.6;

  /// Peg bounciness coefficient (higher = more bouncy)
  static const double pegRestitution = 1.2;

  /// Peg surface friction (0 = no friction, 1 = max friction)
  static const double pegFriction = 0.1;

  // --- Treat Physics ---
  /// Radius of treat collision body
  static const double treatRadius = 0.8;

  /// Treat bounciness coefficient
  static const double treatRestitution = 0.1;

  /// Treat surface friction
  static const double treatFriction = 0.3;

  /// Treat mass/weight density
  static const double treatDensity = 10.0;

  // --- Wall Physics ---
  /// Wall bounciness coefficient
  static const double wallRestitution = 0.5;

  /// Wall surface friction
  static const double wallFriction = 0.3;

  // ========================================
  // BOARD LAYOUT
  // ========================================

  /// Total board width (in physics units)
  static const double boardWidth = 20.0;

  /// Total board height (in physics units)
  static const double boardHeight = 25.0;

  // --- Peg Layout ---
  /// Number of peg rows
  static const int pegRows = 4;

  /// Maximum pegs per row
  static const int pegMaxCols = 4;

  /// Y position of first peg row
  static const double pegStartY = -7.0;

  // --- Slot Layout ---
  /// Number of slots at bottom
  static const int slotCount = 5;

  /// Width of slot divider walls
  static const double slotWallWidth = 0.2;

  /// Height of slot divider walls
  static const double slotWallHeight = 3.0;

  /// Height of slot sensor zone
  static const double slotHeight = 0.7;

  // ========================================
  // ANIMATIONS
  // ========================================

  // --- Peg Animations ---
  /// Duration peg stays in "hit" state
  static const Duration pegHitDuration = Duration(milliseconds: 300);

  /// Scale multiplier for peg bounce (1.15 = 15% larger)
  static const double pegScaleEffect = 1.15;

  // --- Energy Bar Animations ---
  /// Energy bar fill animation speed
  static const Duration energyFillDuration = Duration(milliseconds: 800);

  /// Level-up flash animation speed (per cycle)
  static const Duration levelFlashDuration = Duration(milliseconds: 200);

  /// Number of flash cycles on level-up
  static const int levelFlashCycles = 3;

  // --- Score Animations ---
  /// Score pop animation speed
  static const Duration scorePopDuration = Duration(milliseconds: 250);

  // --- Puppy Animations ---
  /// Duration of eating animation
  static const Duration puppyEatingDuration = Duration(milliseconds: 900);

  /// Duration of happy animation
  static const Duration puppyHappyDuration = Duration(milliseconds: 1040);

  // ========================================
  // COMPUTED VALUES (Helpers)
  // ========================================

  /// Vertical spacing between peg rows
  static double get rowSpacing => boardHeight / (pegRows + 2);

  /// Horizontal spacing between pegs
  static double get pegSpacing => boardWidth / pegMaxCols;

  /// Width of each slot zone
  static double get slotWidth =>
      (boardWidth - slotWallWidth * (slotCount - 1)) / slotCount;

  /// Y position of slots (near bottom)
  static double get slotY => boardHeight / 2 - slotHeight / 2;
}
