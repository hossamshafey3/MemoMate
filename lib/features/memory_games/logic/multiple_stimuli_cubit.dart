import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../data/models/multiple_stimuli_model.dart';
import 'multiple_stimuli_state.dart';

class MultipleStimuliCubit extends Cubit<MultipleStimuliState> {
  MultipleStimuliCubit() : _random = Random(), super(MultipleStimuliInitial());

  final Random _random;
  final _uuid = const Uuid();
  Timer? _gameTimer;

  int _currentLevel = 1;
  int _score = 0;
  
  // Vibrant complementary colors matching deep purple
  final List<StimulusColor> availableColors = const [
    StimulusColor(Color(0xFF00ACC1), "Cyan"),
    StimulusColor(Color(0xFFFBC02D), "Yellow"),
    StimulusColor(Color(0xFFF06292), "Pink"),
    StimulusColor(Color(0xFF009688), "Teal"),
  ];

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    return super.close();
  }

  void startGame({int level = 1, int score = 0}) {
    _currentLevel = level;
    _score = score;
    _generateLevel();
  }

  void nextLevel() {
    startGame(level: _currentLevel + 1, score: _score);
  }

  void restartGame() {
    startGame(level: 1, score: 0);
  }

  void _generateLevel() {
    _gameTimer?.cancel();

    // Determine difficulty params
    int numTargets = _currentLevel < 3 ? 1 : 2; // Find 1 type of shape combo vs 2
    int gridSize = _currentLevel < 5 ? 16 : 25; // 4x4 or 5x5
    int timeLimit = max(10, 20 - (_currentLevel * 2)); // Decreasing time limit

    // 1. Pick Targets
    List<TargetDefinition> targets = [];
    while(targets.length < numTargets) {
      final color = availableColors[_random.nextInt(availableColors.length)];
      final shape = StimulusShape.values[_random.nextInt(StimulusShape.values.length)];
      final target = TargetDefinition(shape: shape, color: color);
      
      if (!targets.contains(target)) {
        targets.add(target);
      }
    }

    // 2. Generate Grid Items
    // We want a manageable number of valid targets to find, e.g., 3-6
    int actualTargetsCount = _random.nextInt(4) + 3; // 3 to 6
    
    List<StimulusItem> gridItems = [];
    
    // Add exact targets
    for (int i = 0; i < actualTargetsCount; i++) {
      final targetDef = targets[_random.nextInt(targets.length)];
      gridItems.add(StimulusItem(
        id: _uuid.v4(),
        shape: targetDef.shape,
        color: targetDef.color,
        isTarget: true,
      ));
    }

    // Fill the rest with distractors
    while(gridItems.length < gridSize) {
      final color = availableColors[_random.nextInt(availableColors.length)];
      final shape = StimulusShape.values[_random.nextInt(StimulusShape.values.length)];
      
      bool isTargetShapeColor = targets.any((t) => t.shape == shape && t.color == color);
      
      gridItems.add(StimulusItem(
        id: _uuid.v4(),
        shape: shape,
        color: color,
        isTarget: isTargetShapeColor,
      ));
    }

    actualTargetsCount = gridItems.where((i) => i.isTarget).length;

    gridItems.shuffle(_random);

    // Show Instructions First
    emit(MultipleStimuliInstructions(
      targets: targets,
      level: _currentLevel,
    ));

    // Wait 3 seconds then start playing
    Future.delayed(const Duration(seconds: 3), () {
      if (isClosed) return;
      
      emit(MultipleStimuliPlaying(
        targets: targets,
        items: gridItems,
        level: _currentLevel,
        timeRemaining: timeLimit,
        targetsFound: 0,
        totalTargets: actualTargetsCount,
      ));

      _startGameTimer();
    });
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is! MultipleStimuliPlaying) {
        timer.cancel();
        return;
      }
      
      final currentState = state as MultipleStimuliPlaying;
      if (currentState.timeRemaining <= 1) {
        timer.cancel();
        emit(MultipleStimuliFailure(level: _currentLevel, score: _score));
      } else {
        emit(MultipleStimuliPlaying(
          targets: currentState.targets,
          items: currentState.items,
          level: currentState.level,
          timeRemaining: currentState.timeRemaining - 1,
          targetsFound: currentState.targetsFound,
          totalTargets: currentState.totalTargets,
        ));
      }
    });
  }

  void onStimulusTapped(String itemId) {
    if (state is! MultipleStimuliPlaying) return;
    
    final currentState = state as MultipleStimuliPlaying;
    
    List<StimulusItem> updatedItems = List.from(currentState.items);
    int itemIndex = updatedItems.indexWhere((i) => i.id == itemId);
    
    if (itemIndex == -1 || updatedItems[itemIndex].isTapped) return;

    final item = updatedItems[itemIndex];
    int newTargetsFound = currentState.targetsFound;

    if (item.isTarget) {
      // Good tap
      updatedItems[itemIndex] = item.copyWith(isTapped: true, isWrongTap: false);
      newTargetsFound++;
      _score += 10;
    } else {
      // Bad tap
      updatedItems[itemIndex] = item.copyWith(isTapped: true, isWrongTap: true);
      _score -= 5;
    }

    if (newTargetsFound >= currentState.totalTargets) {
      _gameTimer?.cancel();
      // Level cleared
      emit(MultipleStimuliSuccess(_currentLevel));
    } else {
      // Keep going
      emit(MultipleStimuliPlaying(
        targets: currentState.targets,
        items: updatedItems,
        level: currentState.level,
        timeRemaining: currentState.timeRemaining,
        targetsFound: newTargetsFound,
        totalTargets: currentState.totalTargets,
      ));

      if (!item.isTarget) {
        // Punish timer mildly or just indicate failure if strict
        // For dementia, just visual feedback is mostly enough, but maybe fail game if 3 strikes.
        // Let's keep it simple: wrong taps just reduce score and turn red.
      }
    }
  }
}
