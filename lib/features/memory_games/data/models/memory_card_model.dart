// ─────────────────────────────────────────────────────────────────────────────
//  memory_card_model.dart  –  Memomate
//  Data model representing a single memory card in the matching game.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class MemoryCard {
  final String id; // unique card instance id (e.g. "emoji_0", "emoji_0_clone")
  final String value; // emoji / symbol that must be matched
  final IconData? icon; // optional icon alternative

  bool isFaceUp; // currently showing face?
  bool isMatched; // permanently matched?

  MemoryCard({
    required this.id,
    required this.value,
    this.icon,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({bool? isFaceUp, bool? isMatched}) {
    return MemoryCard(
      id: id,
      value: value,
      icon: icon,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
