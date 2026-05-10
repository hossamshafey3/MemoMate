import 'package:equatable/equatable.dart';
import '../data/models/path_finder_model.dart';

abstract class PathFinderState extends Equatable {
  const PathFinderState();

  @override
  List<Object?> get props => [];
}

class PathFinderInitial extends PathFinderState {}

class PathFinderShowingPath extends PathFinderState {
  final List<PathNode> path;
  final int timerTick;
  final int gridSize;

  const PathFinderShowingPath({
    required this.path,
    required this.timerTick,
    required this.gridSize,
  });

  @override
  List<Object?> get props => [path, timerTick, gridSize];
}

class PathFinderPlaying extends PathFinderState {
  final List<PathNode> targetPath;
  final List<PathNode> userPath;
  final int gridSize;

  const PathFinderPlaying({
    required this.targetPath,
    required this.userPath,
    required this.gridSize,
  });

  @override
  List<Object?> get props => [targetPath, userPath, gridSize];
}

class PathFinderSuccess extends PathFinderState {
  final int level;

  const PathFinderSuccess(this.level);

  @override
  List<Object?> get props => [level];
}

class PathFinderFailure extends PathFinderState {
  final List<PathNode> targetPath;
  final List<PathNode> userPath;

  const PathFinderFailure({
    required this.targetPath,
    required this.userPath,
  });

  @override
  List<Object?> get props => [targetPath, userPath];
}
