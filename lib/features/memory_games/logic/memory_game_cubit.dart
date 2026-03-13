// ─────────────────────────────────────────────────────────────────────────────
//  memory_game_cubit.dart  –  Memomate
//  Business logic for the Memory Card matching game (Concentration).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/memory_games/data/models/memory_card_model.dart';
import 'package:gradproj/features/memory_games/logic/memory_game_state.dart';

class MemoryGameCubit extends Cubit<MemoryGameState> {
  MemoryGameCubit() : super(MemoryGameInitial());

  // ── Game configuration ────────────────────────────────────────────────────
  static const _easyPairs = 6; // 3×4 grid
  // The pairs count is passed in by the caller; these are not needed as constants.

  // Rich emoji set for cards
  static const List<String> _allEmojis = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐮',
    '🐷',
    '🐸',
    '🐵',
    '🐔',
    '🐧',
    '🐦',
    '🌸',
    '🌺',
    '🌻',
    '🍎',
    '🍊',
    '🍋',
  ];

  // ── Internal state ────────────────────────────────────────────────────────
  Timer? _timer;
  Timer? _flipBackTimer;
  Duration _elapsed = Duration.zero;
  MemoryCard? _firstFlipped;
  int _moves = 0;
  int _matchesFound = 0;
  int _totalPairs = 0;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Start (or restart) a new game with the given difficulty.
  void startGame({int pairsCount = _easyPairs}) {
    _cleanup();

    _totalPairs = pairsCount;
    _moves = 0;
    _matchesFound = 0;
    _elapsed = Duration.zero;
    _firstFlipped = null;

    final shuffled = List<String>.from(_allEmojis)..shuffle();
    final emojis = shuffled.take(pairsCount).toList();
    final cards = <MemoryCard>[];

    for (int i = 0; i < emojis.length; i++) {
      cards.add(MemoryCard(id: '${emojis[i]}_a', value: emojis[i]));
      cards.add(MemoryCard(id: '${emojis[i]}_b', value: emojis[i]));
    }
    cards.shuffle();

    _startTimer();
    emit(
      MemoryGamePlaying(
        cards: cards,
        moves: _moves,
        matchesFound: _matchesFound,
        totalPairs: _totalPairs,
        elapsed: _elapsed,
      ),
    );
  }

  /// Called when the player taps a card.
  void flipCard(String cardId) {
    final current = state;
    if (current is! MemoryGamePlaying) return;
    if (current.isChecking) return; // locked during mismatch pause

    final cardIndex = current.cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) return;

    final card = current.cards[cardIndex];
    if (card.isFaceUp || card.isMatched) return;

    // Flip the tapped card face-up
    final updatedCards = List<MemoryCard>.from(current.cards);
    updatedCards[cardIndex] = card.copyWith(isFaceUp: true);

    if (_firstFlipped == null) {
      // First card of a pair
      _firstFlipped = updatedCards[cardIndex];
      emit(current.copyWith(cards: updatedCards));
    } else {
      // Second card – evaluate match
      _moves++;

      if (_firstFlipped!.value == card.value) {
        // ✅ Match!
        _matchesFound++;
        for (int i = 0; i < updatedCards.length; i++) {
          if (updatedCards[i].value == card.value) {
            updatedCards[i] = updatedCards[i].copyWith(
              isMatched: true,
              isFaceUp: true,
            );
          }
        }
        _firstFlipped = null;

        final nextState = current.copyWith(
          cards: updatedCards,
          moves: _moves,
          matchesFound: _matchesFound,
        );

        if (_matchesFound == _totalPairs) {
          _cleanup();
          emit(MemoryGameComplete(moves: _moves, elapsed: _elapsed));
        } else {
          emit(nextState);
        }
      } else {
        // ❌ No match – show both briefly, then flip back
        emit(
          current.copyWith(
            cards: updatedCards,
            moves: _moves,
            isChecking: true,
          ),
        );

        final firstId = _firstFlipped!.id;
        _firstFlipped = null;

        _flipBackTimer = Timer(const Duration(milliseconds: 900), () {
          final s = state;
          if (s is! MemoryGamePlaying) return;
          final flippedBack = List<MemoryCard>.from(s.cards);
          for (int i = 0; i < flippedBack.length; i++) {
            if ((flippedBack[i].id == card.id ||
                    flippedBack[i].id == firstId) &&
                !flippedBack[i].isMatched) {
              flippedBack[i] = flippedBack[i].copyWith(isFaceUp: false);
            }
          }
          emit(s.copyWith(cards: flippedBack, isChecking: false));
        });
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is MemoryGamePlaying && !s.isComplete) {
        _elapsed = _elapsed + const Duration(seconds: 1);
        emit(s.copyWith(elapsed: _elapsed));
      }
    });
  }

  void _cleanup() {
    _timer?.cancel();
    _timer = null;
    _flipBackTimer?.cancel();
    _flipBackTimer = null;
  }

  /// Return to the difficulty selection screen.
  void resetGame() {
    _cleanup();
    _firstFlipped = null;
    emit(MemoryGameInitial());
  }

  @override
  Future<void> close() {
    _cleanup();
    return super.close();
  }
}
