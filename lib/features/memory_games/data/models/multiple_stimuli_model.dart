import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum StimulusShape {
  circle(Icons.circle),
  square(Icons.square_rounded),
  heart(Icons.favorite_rounded),
  star(Icons.star_rounded),
  hexagon(Icons.hexagon_rounded),
  triangle(Icons.change_history_rounded);

  final IconData icon;
  const StimulusShape(this.icon);
}

class StimulusColor {
  final Color color;
  final String name;

  const StimulusColor(this.color, this.name);
}

class StimulusItem extends Equatable {
  final String id;
  final StimulusShape shape;
  final StimulusColor color;
  final bool isTarget;
  final bool isTapped;
  final bool isWrongTap;

  const StimulusItem({
    required this.id,
    required this.shape,
    required this.color,
    required this.isTarget,
    this.isTapped = false,
    this.isWrongTap = false,
  });

  StimulusItem copyWith({
    bool? isTapped,
    bool? isWrongTap,
  }) {
    return StimulusItem(
      id: id,
      shape: shape,
      color: color,
      isTarget: isTarget,
      isTapped: isTapped ?? this.isTapped,
      isWrongTap: isWrongTap ?? this.isWrongTap,
    );
  }

  @override
  List<Object?> get props => [id, shape, color, isTarget, isTapped, isWrongTap];
}

class TargetDefinition extends Equatable {
  final StimulusShape shape;
  final StimulusColor color;

  const TargetDefinition({
    required this.shape,
    required this.color,
  });

  @override
  List<Object?> get props => [shape, color];
}
