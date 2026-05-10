import 'package:equatable/equatable.dart';
import '../data/models/multiple_stimuli_model.dart';

abstract class MultipleStimuliState extends Equatable {
  const MultipleStimuliState();

  @override
  List<Object?> get props => [];
}

class MultipleStimuliInitial extends MultipleStimuliState {}

class MultipleStimuliInstructions extends MultipleStimuliState {
  final List<TargetDefinition> targets;
  final int level;

  const MultipleStimuliInstructions({
    required this.targets,
    required this.level,
  });

  @override
  List<Object?> get props => [targets, level];
}

class MultipleStimuliPlaying extends MultipleStimuliState {
  final List<TargetDefinition> targets;
  final List<StimulusItem> items;
  final int level;
  final int timeRemaining;
  final int targetsFound;
  final int totalTargets;

  const MultipleStimuliPlaying({
    required this.targets,
    required this.items,
    required this.level,
    required this.timeRemaining,
    required this.targetsFound,
    required this.totalTargets,
  });

  @override
  List<Object?> get props => [targets, items, level, timeRemaining, targetsFound, totalTargets];
}

class MultipleStimuliSuccess extends MultipleStimuliState {
  final int level;

  const MultipleStimuliSuccess(this.level);

  @override
  List<Object?> get props => [level];
}

class MultipleStimuliFailure extends MultipleStimuliState {
  final int level;
  final int score;

  const MultipleStimuliFailure({
    required this.level,
    required this.score,
  });

  @override
  List<Object?> get props => [level, score];
}
