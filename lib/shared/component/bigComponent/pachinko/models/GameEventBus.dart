import 'dart:async';

/// Base class for all game events
abstract class GameEvent {
  const GameEvent();
}

/// Event emitted when a peg is hit
class PegHitEvent extends GameEvent {
  const PegHitEvent();
}

/// Event emitted when a treat is caught in a slot
class TreatCaughtEvent extends GameEvent {
  final double multiplier;

  const TreatCaughtEvent(this.multiplier);
}

/// Event emitted when puppy levels up
class LevelUpEvent extends GameEvent {
  const LevelUpEvent();
}

/// Centralized event bus for Pachinko game events
///
/// Uses a single broadcast stream for all game events.
/// Components emit events, PachinkoGame listens and coordinates responses.
class GameEventBus {
  // Private constructor for singleton
  GameEventBus._();

  static final GameEventBus instance = GameEventBus._();

  // Single broadcast stream controller for all game events
  final _eventController = StreamController<GameEvent>.broadcast();

  /// Stream of all game events
  Stream<GameEvent> get gameEvents => _eventController.stream;

  /// Emit a game event
  ///
  /// This is the single method for emitting any type of game event.
  /// Provides a central interception point for logging, validation, or analytics.
  void emit(GameEvent event) {
    _eventController.add(event);
  }

  /// Dispose of stream controller
  /// Call this when the game is permanently closed
  void dispose() {
    _eventController.close();
  }
}
