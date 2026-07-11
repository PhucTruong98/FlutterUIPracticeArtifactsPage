import 'PuppyAnimationController.dart';

/// Represents a sequence of animations to play in order
///
/// This is a data structure that holds a list of animation states
/// and tracks the current position in the sequence.
/// The controller executes sequences without knowing transition rules.
class AnimationSequence {
  final List<PuppyState> states;
  int _currentIndex = 0;

  AnimationSequence(this.states) {
    if (states.isEmpty) {
      throw ArgumentError('AnimationSequence cannot be empty');
    }
  }

  /// Get the currently active animation in the sequence
  PuppyState get currentAnimation => states[_currentIndex];

  /// Check if there are more animations after the current one
  bool get hasNext => _currentIndex < states.length - 1;

  /// Check if the sequence has finished playing all animations
  bool get isComplete => _currentIndex >= states.length - 1;

  /// Move to the next animation in the sequence
  void advance() {
    if (hasNext) {
      _currentIndex++;
    }
  }

  /// Reset the sequence to the beginning
  void reset() {
    _currentIndex = 0;
  }

  /// Get the total number of animations in this sequence
  int get length => states.length;

  @override
  String toString() {
    return 'AnimationSequence(${states.map((s) => s.name).join(' → ')}, '
        'current: ${currentAnimation.name}, index: $_currentIndex)';
  }
}
