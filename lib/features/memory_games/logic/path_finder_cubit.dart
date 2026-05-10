import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/path_finder_model.dart';
import 'path_finder_state.dart';

class PathFinderCubit extends Cubit<PathFinderState> {
  PathFinderCubit() : _random = Random(), super(PathFinderInitial());

  Timer? _timer;
  int _currentLevel = 1;
  int _gridSize = 4;
  int _pathLength = 3;

  final List<PathNode> _currentPath = [];
  final Random _random;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void startGame({int level = 1}) {
    _currentLevel = level;
    _gridSize = _calculateGridSize(_currentLevel);
    _pathLength = _calculatePathLength(_currentLevel);
    _generatePath();
    _startShowingPath();
  }

  void resetGame() {
    startGame(level: 1);
  }

  void nextLevel() {
    startGame(level: _currentLevel + 1);
  }

  int _calculateGridSize(int level) {
    if (level < 3) return 3;
    if (level < 6) return 4;
    if (level < 10) return 5;
    return 6;
  }

  int _calculatePathLength(int level) {
    return (level ~/ 2) + 3; // L1:3, L2:4, L3:4, L4:5, L5:5, ...
  }

  void _generatePath() {
    _currentPath.clear();

    // Start anywhere
    int x = _random.nextInt(_gridSize);
    int y = _random.nextInt(_gridSize);
    _currentPath.add(PathNode(x, y));

    for (int i = 1; i < _pathLength; i++) {
      List<PathNode> possibleNext = _getValidNeighbors(_currentPath.last);
      // Remove already visited
      possibleNext.removeWhere((node) => _currentPath.contains(node));

      if (possibleNext.isEmpty) {
        // If we get stuck, restart generation
        return _generatePath();
      }

      PathNode nextNode = possibleNext[_random.nextInt(possibleNext.length)];
      _currentPath.add(nextNode);
    }
  }

  List<PathNode> _getValidNeighbors(PathNode node) {
    List<PathNode> neighbors = [];
    if (node.x > 0) neighbors.add(PathNode(node.x - 1, node.y));
    if (node.x < _gridSize - 1) neighbors.add(PathNode(node.x + 1, node.y));
    if (node.y > 0) neighbors.add(PathNode(node.x, node.y - 1));
    if (node.y < _gridSize - 1) neighbors.add(PathNode(node.x, node.y + 1));
    return neighbors;
  }

  void _startShowingPath() {
    _timer?.cancel();
    int ticks = 3 + (_currentLevel ~/ 3); // 3, 3, 3, 4, 4, 4... seconds

    emit(
      PathFinderShowingPath(
        path: _currentPath,
        timerTick: ticks,
        gridSize: _gridSize,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ticks--;
      if (ticks <= 0) {
        timer.cancel();
        emit(
          PathFinderPlaying(
            targetPath: _currentPath,
            userPath: const [],
            gridSize: _gridSize,
          ),
        );
      } else {
        emit(
          PathFinderShowingPath(
            path: _currentPath,
            timerTick: ticks,
            gridSize: _gridSize,
          ),
        );
      }
    });
  }

  void onNodeSelected(PathNode node) {
    if (state is! PathFinderPlaying) return;

    final currentState = state as PathFinderPlaying;

    // Don't allow re-selecting the same node if we just tapped it
    if (currentState.userPath.contains(node)) return;

    final List<PathNode> newUserPath = List.from(currentState.userPath)
      ..add(node);

    // Validate the currently selected node
    int currentIndex = newUserPath.length - 1;
    if (_currentPath[currentIndex] != node) {
      // Wrong node selected
      emit(PathFinderFailure(targetPath: _currentPath, userPath: newUserPath));
      return;
    }

    // Correct node
    if (newUserPath.length == _currentPath.length) {
      // Successfully finished the path
      emit(PathFinderSuccess(_currentLevel));
    } else {
      // Keep playing
      emit(
        PathFinderPlaying(
          targetPath: _currentPath,
          userPath: newUserPath,
          gridSize: _gridSize,
        ),
      );
    }
  }
}
