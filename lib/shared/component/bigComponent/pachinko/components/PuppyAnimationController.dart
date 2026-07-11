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

  // Timer for scheduling the next animation in sequence
  Timer? _transitionTimer;

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
      // Not executing anything → start immediately
      _startSequence(sequence);
    } else {
      // Currently busy → queue it
      _sequenceQueue.add(sequence);
    }
  }

  /// Queue an animation sequence to play after current sequence(s)
  void queue(AnimationSequence sequence) {
    if (_currentSequence == null && _sequenceQueue.isEmpty) {
      // If idle with empty queue, start immediately
      _startSequence(sequence);
    } else {
      // Otherwise queue for later
      _sequenceQueue.add(sequence);
    }
  }

  /// Dispose of resources
  void dispose() {
    _transitionTimer?.cancel();
    _transitionTimer = null;
    _sequenceQueue.clear();
    _currentSequence = null;
  }

  /// Start executing a new sequence
  void _startSequence(AnimationSequence sequence) {
    _currentSequence = sequence;
    sequence.reset(); // Ensure sequence starts from beginning
    _playCurrentAnimationInSequence();
  }

  /// Play the current animation from the active sequence
  void _playCurrentAnimationInSequence() {
    if (_currentSequence == null) {
      // No sequence active → default to idle
      _setState(PuppyState.idle);
      return;
    }

    final animation = _currentSequence!.currentAnimation;
    _setState(animation);

    // Schedule transition to next animation after duration
    final duration = getDuration(animation);
    if (duration > 0) {
      _scheduleNextAnimation(duration);
    }
    // If duration is 0 (idle), no transition is scheduled (loops forever)
  }

  /// Set current animation state
  void _setState(PuppyState newState) {
    if (_currentState == newState) return;

    _currentState = newState;

    // Cancel any pending transition when changing state
    _transitionTimer?.cancel();
    _transitionTimer = null;

    // Notify listener (component) that state has changed
    onStateChanged?.call(newState);
  }

  /// Schedule the next animation in the sequence
  void _scheduleNextAnimation(double duration) {
    _transitionTimer = Timer(
      Duration(milliseconds: (duration * 1000).round()),
      _onAnimationComplete,
    );
  }

  /// Handle animation completion - advance sequence or start next queued
  void _onAnimationComplete() {
    if (_currentSequence == null) {
      return; // Safety check
    }

    if (_currentSequence!.hasNext) {
      // More animations in current sequence → advance and play next
      _currentSequence!.advance();
      _playCurrentAnimationInSequence();
    } else {
      // Current sequence finished → check queue
      _currentSequence = null;

      if (_sequenceQueue.isNotEmpty) {
        // Start next queued sequence
        final nextSequence = _sequenceQueue.removeFirst();
        _startSequence(nextSequence);
      } else {
        _setState(PuppyState.idle);
        // No more sequences → stay in current state (usually idle)
        // State is already set to the last animation of the sequence
      }
    }
  }
}
