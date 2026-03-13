// ─────────────────────────────────────────────────────────────────────────────
//  number_memory_cubit.dart  –  Memomate
//  Business logic for the Number Memory game.
//  Inspired by: https://humanbenchmark.com/tests/number-memory
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/memory_games/logic/number_memory_state.dart';

class NumberMemoryCubit extends Cubit<NumberMemoryState> {
  NumberMemoryCubit() : super(NumberMemoryInitial());

  // ── Internal state ────────────────────────────────────────────────────────
  Timer? _countdownTimer;
  double _progress = 1.0;
  int _currentLevel = 1;
  String _currentNumber = '';

  // How long to show the number: 2s base + 0.5s per extra digit
  Duration _showDuration(int level) =>
      Duration(milliseconds: 2000 + (level - 1) * 500);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Start the game from level 1.
  void startGame() {
    _currentLevel = 1;
    _showNextNumber();
  }

  /// Called when the player submits their answer.
  void submitAnswer(String playerAnswer) {
    _cancelTimer();
    final s = state;
    if (s is! NumberMemoryAnswering) return;

    final isCorrect = playerAnswer.trim() == _currentNumber;

    emit(
      NumberMemoryResult(
        level: _currentLevel,
        correctNumber: _currentNumber,
        playerAnswer: playerAnswer.trim(),
        isCorrect: isCorrect,
      ),
    );

    // After 2 seconds auto-advance
    Future.delayed(const Duration(seconds: 2), () {
      if (isClosed) return;
      if (isCorrect) {
        _currentLevel++;
        _showNextNumber();
      } else {
        emit(NumberMemoryGameOver(finalLevel: _currentLevel));
      }
    });
  }

  /// Restart from beginning.
  void restartGame() {
    _cancelTimer();
    emit(NumberMemoryInitial());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showNextNumber() {
    _currentNumber = _generateNumber(_currentLevel);
    _progress = 1.0;

    emit(
      NumberMemoryShowing(
        level: _currentLevel,
        number: _currentNumber,
        progress: _progress,
      ),
    );

    final duration = _showDuration(_currentLevel);
    const tickMs = 50; // update progress every 50ms for smooth bar
    final totalTicks = duration.inMilliseconds ~/ tickMs;
    int ticks = 0;

    _cancelTimer();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: tickMs), (
      timer,
    ) {
      ticks++;
      _progress = 1.0 - (ticks / totalTicks);
      if (_progress <= 0) {
        _progress = 0;
        timer.cancel();
        if (!isClosed) {
          emit(
            NumberMemoryAnswering(level: _currentLevel, number: _currentNumber),
          );
        }
      } else {
        if (!isClosed) {
          emit(
            NumberMemoryShowing(
              level: _currentLevel,
              number: _currentNumber,
              progress: _progress,
            ),
          );
        }
      }
    });
  }

  String _generateNumber(int digits) {
    final rng = Random();
    // First digit is never 0
    String result = (rng.nextInt(9) + 1).toString();
    for (int i = 1; i < digits; i++) {
      result += rng.nextInt(10).toString();
    }
    return result;
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
