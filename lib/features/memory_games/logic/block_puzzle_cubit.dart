import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'block_puzzle_state.dart';

class BlockPuzzleCubit extends Cubit<BlockPuzzleState> {
  BlockPuzzleCubit() : super(BlockPuzzleInitial()) {
    startGame();
  }

  static const int totalLevels = 6;
  final Random _random = Random();

  void startGame() {
    _generateLevel(1, 0);
  }

  void _generateLevel(int level, int currentScore) {
    int boardSize = level < 3 ? 3 : 4;
    
    // Create base solid board
    List<List<int>> board = List.generate(boardSize, (_) => List.filled(boardSize, 1));
    
    // Pick a random tetromino
    final shapesList = _getShapes();
    final List<List<int>> missingShape = shapesList[_random.nextInt(shapesList.length)];
    
    // Create the hole by zeroing out the shape from the board
    int shapeRows = missingShape.length;
    int shapeCols = missingShape[0].length;
    
    int rowOffset = _random.nextInt(boardSize - shapeRows + 1);
    int colOffset = _random.nextInt(boardSize - shapeCols + 1);
    
    for (int r = 0; r < shapeRows; r++) {
      for (int c = 0; c < shapeCols; c++) {
        if (missingShape[r][c] == 1) {
          board[rowOffset + r][colOffset + c] = 0;
        }
      }
    }

    // Generate options including the correct one
    List<List<List<int>>> options = [missingShape];
    while (options.length < 4) {
      final List<List<int>> randomShape = shapesList[_random.nextInt(shapesList.length)];
      
      bool alreadyExists = false;
      for (var opt in options) {
        if (_areShapesEqual(opt, randomShape)) {
          alreadyExists = true;
          break;
        }
      }
      if (!alreadyExists) {
        options.add(randomShape);
      }
    }
    
    options.shuffle(_random);
    int correctIndex = options.indexWhere((s) => _areShapesEqual(s, missingShape));
    
    emit(BlockPuzzlePlaying(
      level: level,
      score: currentScore,
      puzzleBoard: board,
      options: options,
      correctOptionIndex: correctIndex,
    ));
  }

  void submitAnswer(int index) async {
    if (state is BlockPuzzlePlaying) {
      final currentState = state as BlockPuzzlePlaying;
      if (currentState.animateTransition) return;

      if (index == currentState.correctOptionIndex) {
        // Correct
        final newScore = currentState.score + 10;
        final nextLevel = currentState.level + 1;
        
        emit(currentState.copyWith(animateTransition: true, score: newScore, isIncorrectTry: false));
        await Future.delayed(const Duration(milliseconds: 700));

        if (nextLevel > totalLevels) {
          emit(BlockPuzzleGameOver(score: newScore, levelsCompleted: totalLevels));
        } else {
          _generateLevel(nextLevel, newScore);
        }
      } else {
        // Incorrect - try again
        emit(currentState.copyWith(isIncorrectTry: true));
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (state is BlockPuzzlePlaying) {
          emit((state as BlockPuzzlePlaying).copyWith(isIncorrectTry: false));
        }
      }
    }
  }

  bool _areShapesEqual(List<List<int>> a, List<List<int>> b) {
    if (a.length != b.length) return false;
    for (int r = 0; r < a.length; r++) {
      if (a[r].length != b[r].length) return false;
      for (int c = 0; c < a[r].length; c++) {
        if (a[r][c] != b[r][c]) return false;
      }
    }
    return true;
  }

  List<List<List<int>>> _getShapes() {
    return [
      // 2x2 Square
      [[1,1], [1,1]],
      // Horizontal Line 3
      [[1,1,1]],
      // Vertical Line 3
      [[1], [1], [1]],
      // L shape
      [[1,0], [1,0], [1,1]],
      // Flipped L
      [[0,1], [0,1], [1,1]],
      // T shape
      [[1,1,1], [0,1,0]],
      // Reverse T
      [[0,1,0], [1,1,1]],
      // Single block
      [[1]],
      // 2 horizontal
      [[1,1]],
      // 2 vertical
      [[1], [1]],
      // Z shape
      [[1,1,0], [0,1,1]],
      // small L
      [[1,0], [1,1]]
    ];
  }
}
