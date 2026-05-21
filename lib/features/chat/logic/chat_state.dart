// ─────────────────────────────────────────────
//  chat_state.dart  –  Memomate
//  Cubit States for Chat Feature.
// ─────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:gradproj/features/chat/data/models/chat_message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final bool isSocketConnected;
  final DateTime timestamp;

  ChatLoaded({
    required this.messages,
    required this.isSocketConnected,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [messages, isSocketConnected, timestamp];

  ChatLoaded copyWith({
    List<ChatMessageModel>? messages,
    bool? isSocketConnected,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
      timestamp: DateTime.now(),
    );
  }
}

class ChatError extends ChatState {
  final String errorMessage;

  const ChatError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
