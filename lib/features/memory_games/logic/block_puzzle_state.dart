import 'package:equatable/equatable.dart';

abstract class BlockPuzzleState extends Equatable {
  const BlockPuzzleState();

  @override
  List<Object?> get props => [];
}

class BlockPuzzleInitial extends BlockPuzzleState {}

class BlockPuzzlePlaying extends BlockPuzzleState {
  final int level;
  final int score;
  final List<List<int>> puzzleBoard;
  final List<List<List<int>>> options;
  final int correctOptionIndex;
  final bool isIncorrectTry;
  final bool animateTransition;

  const BlockPuzzlePlaying({
    required this.level,
    required this.score,
    required this.puzzleBoard,
    required this.options,
    required this.correctOptionIndex,
    this.isIncorrectTry = false,
    this.animateTransition = false,
  });

  BlockPuzzlePlaying copyWith({
    int? level,
    int? score,
    List<List<int>>? puzzleBoard,
    List<List<List<int>>>? options,
    int? correctOptionIndex,
    bool? isIncorrectTry,
    bool? animateTransition,
  }) {
    return BlockPuzzlePlaying(
      level: level ?? this.level,
      score: score ?? this.score,
      puzzleBoard: puzzleBoard ?? this.puzzleBoard,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      isIncorrectTry: isIncorrectTry ?? this.isIncorrectTry,
      animateTransition: animateTransition ?? this.animateTransition,
    );
  }

  @override
  List<Object?> get props => [
        level,
        score,
        puzzleBoard,
        options,
        correctOptionIndex,
        isIncorrectTry,
        animateTransition,
      ];
}

class BlockPuzzleGameOver extends BlockPuzzleState {
  final int score;
  final int levelsCompleted;

  const BlockPuzzleGameOver({
    required this.score,
    required this.levelsCompleted,
  });

  @override
  List<Object?> get props => [score, levelsCompleted];
}
