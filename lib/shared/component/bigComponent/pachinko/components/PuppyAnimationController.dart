import 'dart:async';
import 'dart:collection';
import 'AnimationSequence.dart';

/// Enum representing puppy animation states
enum PuppyState {
  idle,    // Looping idle animation
  eating,  // One-shot eating animation
  happy,   // One-shot happy celebration
  levelUp, // One-shot levelUp celebration
}

/// Controller for managing puppy animation sequencing
///
/// Executes animation sequences without hardcoded transition rules.
/// Uses a queue-based system where sequences define what plays next.
class PuppyAnimationController {
  // Current animation state
  PuppyState _currentState = PuppyState.idle;

  // Current sequence being executed
  AnimationSequence? _currentSequence;

  // Queue of sequences waiting to be executed
  final Queue<AnimationSequence> _sequenceQueue = Queue();

  // Function to lookup animation duration by state
  final double Function(PuppyState) getDuration;

  // Callback invoked when state changes (for component to update rendering)
  void Function(PuppyState)? onStateChanged;

  // Cancellation flag for dispose
  bool _disposed = false;

  /// Constructor - requires duration lookup function
  PuppyAnimationController({
    required this.getDuration,
  });

  /// Get current animation state
  PuppyState get currentState => _currentState;

  /// Check if there are queued sequences
  bool get hasQueuedSequences => _sequenceQueue.isNotEmpty;

  /// Check if currently executing a sequence
  bool get isExecutingSequence => _currentSequence != null;

  /// Play an animation sequence immediately if idle, or queue it if busy
  void play(AnimationSequence sequence) {
    if (_currentSequence == null && _sequenceQueue.isEmpty) {
      // Not executing anything → set synchronously and start
      _currentSequence = sequence;
      unawaited(_executeSequence(sequence));
    } else {
      // Currently busy → queue it
      _sequenceQueue.add(sequence);
    }
  }

  /// Queue an animation sequence to play after current sequence(s)
  void queue(AnimationSequence sequence) {
    if (_currentSequence == null && _sequenceQueue.isEmpty) {
      // If idle with empty queue, start immediately
      _currentSequence = sequence;
      unawaited(_executeSequence(sequence));
    } else {
      // Otherwise queue for later
      _sequenceQueue.add(sequence);
    }
  }

  /// Dispose of resources
  void dispose() {
    _disposed = true;
    _sequenceQueue.clear();
    _currentSequence = null;
  }

  /// Execute a sequence (note: _currentSequence already set synchronously by caller)
  Future<void> _executeSequence(AnimationSequence sequence) async {
    // Outer loop: process current sequence and all queued sequences
    while (true) {
      if (_disposed) return;

      sequence.reset(); // Ensure sequence starts from beginning

      // Inner loop: play all animations in current sequence (except last)
      while (!_currentSequence!.isComplete && !_disposed) {
        final animation = _currentSequence!.currentAnimation;
        _setState(animation);

        // Schedule transition to next animation after duration
        final duration = getDuration(animation);
        await Future.delayed(Duration(milliseconds: (duration * 1000).round()));

        if (_disposed) return;
        _currentSequence!.advance();
      }

      if (_disposed) return;

      // Play the last animation
      final lastAnimation = _currentSequence!.currentAnimation;
      _setState(lastAnimation);
      final lastDuration = getDuration(lastAnimation);
      if (lastDuration > 0) {
        await Future.delayed(Duration(milliseconds: (lastDuration * 1000).round()));
      }

      if (_disposed) return;

      // Check if there are more sequences to process
      if (_sequenceQueue.isEmpty) {
        break; // Exit outer loop - no more sequences
      }

      // Pop next sequence and continue outer loop
      final nextSequence = _sequenceQueue.removeFirst();
      _currentSequence = nextSequence;
      sequence = nextSequence;
    }

    // All sequences processed - return to idle
    _currentSequence = null;
    _setState(PuppyState.idle);
  }

  /// Set current animation state
  void _setState(PuppyState newState) {
    if (_currentState == newState) return;

    _currentState = newState;

    // Notify listener (component) that state has changed
    onStateChanged?.call(newState);
  }
}
