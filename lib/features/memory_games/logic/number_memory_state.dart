// ─────────────────────────────────────────────────────────────────────────────
//  number_memory_state.dart  –  Memomate
//  States for the NumberMemoryCubit.
// ─────────────────────────────────────────────────────────────────────────────

abstract class NumberMemoryState {}

/// Landing / start screen.
class NumberMemoryInitial extends NumberMemoryState {}

/// Showing the number to memorize.
class NumberMemoryShowing extends NumberMemoryState {
  final int level;
  final String number;
  final double progress; // 1.0 → 0.0 countdown progress
  NumberMemoryShowing({
    required this.level,
    required this.number,
    required this.progress,
  });
}

/// Player is typing their answer.
class NumberMemoryAnswering extends NumberMemoryState {
  final int level;
  final String number; // kept for result comparison
  NumberMemoryAnswering({required this.level, required this.number});
}

/// Brief result flash after submitting (correct or wrong).
class NumberMemoryResult extends NumberMemoryState {
  final int level;
  final String correctNumber;
  final String playerAnswer;
  final bool isCorrect;
  NumberMemoryResult({
    required this.level,
    required this.correctNumber,
    required this.playerAnswer,
    required this.isCorrect,
  });
}

/// Game over – all lives used.
class NumberMemoryGameOver extends NumberMemoryState {
  final int finalLevel;
  NumberMemoryGameOver({required this.finalLevel});
}
