// ─────────────────────────────────────────────────────────────────────────────
//  memory_game_state.dart  –  Memomate
//  States for the MemoryGameCubit.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:gradproj/features/memory_games/data/models/memory_card_model.dart';

abstract class MemoryGameState {}

/// Initial / idle state – no game in progress.
class MemoryGameInitial extends MemoryGameState {}

/// Game is actively being played.
class MemoryGamePlaying extends MemoryGameState {
  final List<MemoryCard> cards;
  final int moves;
  final int matchesFound;
  final int totalPairs;
  final Duration elapsed;
  final bool isChecking; // true while brief "wrong pair" pause is active

  MemoryGamePlaying({
    required this.cards,
    required this.moves,
    required this.matchesFound,
    required this.totalPairs,
    required this.elapsed,
    this.isChecking = false,
  });

  MemoryGamePlaying copyWith({
    List<MemoryCard>? cards,
    int? moves,
    int? matchesFound,
    int? totalPairs,
    Duration? elapsed,
    bool? isChecking,
  }) {
    return MemoryGamePlaying(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      matchesFound: matchesFound ?? this.matchesFound,
      totalPairs: totalPairs ?? this.totalPairs,
      elapsed: elapsed ?? this.elapsed,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  bool get isComplete => matchesFound == totalPairs;
}

/// Game finished – all pairs found.
class MemoryGameComplete extends MemoryGameState {
  final int moves;
  final Duration elapsed;

  MemoryGameComplete({required this.moves, required this.elapsed});
}
