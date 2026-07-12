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

  // Processing flag to prevent concurrent processQueue() calls
  bool _isProcessing = false;

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
    _sequenceQueue.add(sequence);
    unawaited(processQueue());
  }

  /// Queue an animation sequence to play after current sequence(s)
  void queue(AnimationSequence sequence) {
      _sequenceQueue.add(sequence);
      unawaited(processQueue());
    
  }

  /// Dispose of resources
  void dispose() {
    _disposed = true;
    _isProcessing = false;
    _sequenceQueue.clear();
    _currentSequence = null;
  }

  Future<void> processQueue() async {
    // Guard: only one processQueue() can run at a time
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      while (_sequenceQueue.isNotEmpty && !_disposed) {
        final sequence = _sequenceQueue.removeFirst();
        await _executeSequence(sequence);
      }

      // All sequences processed - return to idle
      _currentSequence = null;
      if (!_disposed) {
        _setState(PuppyState.idle);
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Execute a single sequence
  Future<void> _executeSequence(AnimationSequence sequence) async {
    if (_disposed) return;

    _currentSequence = sequence;
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
  }



  /// Set current animation state
  void _setState(PuppyState newState) {
    if (_currentState == newState) return;

    _currentState = newState;

    // Notify listener (component) that state has changed
    onStateChanged?.call(newState);
  }
}
