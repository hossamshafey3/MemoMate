// ─────────────────────────────────────────────
//  chat_cubit.dart  –  Memomate
//  Cubit to manage chat operations (messages, socket state, optimistic sending).
// ─────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/chat/data/models/chat_message_model.dart';
import 'package:gradproj/features/chat/data/repositories/chat_service.dart';
import 'package:gradproj/features/chat/logic/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;
  List<ChatMessageModel> _messagesList = [];

  ChatCubit(this._chatService) : super(ChatInitial());

  /// Initialize real-time chat: fetch history and establish socket connection.
  Future<void> initChat({
    required String currentUserId,
    required String receiverId,
  }) async {
    emit(ChatLoading());

    // 1. Establish real-time socket connection
    _chatService.connect(
      userId: currentUserId,
      onMessageReceived: (message) {
        // Double check this message belongs to the current conversation
        if ((message.doctorId == currentUserId || message.patientId == currentUserId) &&
            (message.doctorId == receiverId || message.patientId == receiverId)) {
          _appendNewMessage(message);
        }
      },
      onConnectError: (err) {
        if (state is ChatLoaded) {
          emit((state as ChatLoaded).copyWith(isSocketConnected: false));
        }
      },
    );

    // 2. Fetch historical messages via REST API
    final history = await _chatService.getChatHistory(receiverId);
    _messagesList = List.from(history);

    emit(ChatLoaded(
      messages: List.from(_messagesList),
      isSocketConnected: true,
    ));
  }

  /// Sends a text message (optimistic UI update + socket emit)
  void sendMessageText({
    required String text,
    required String doctorId,
    required String patientId,
    required String sender,
  }) {
    if (text.trim().isEmpty) return;

    print('MemoMate Cubit: sendMessageText called with text: "$text"');

    // Create local mock/optimistic message to show instantly in UI
    final localMsg = ChatMessageModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      doctorId: doctorId,
      patientId: patientId,
      sender: sender,
      text: text,
      createdAt: DateTime.now(),
    );

    // Append locally
    _messagesList.add(localMsg);
    print('MemoMate Cubit: Added local message. List size is now ${_messagesList.length}');
    
    emit(ChatLoaded(
      messages: List.from(_messagesList),
      isSocketConnected: true,
    ));
    print('MemoMate Cubit: Emitted ChatLoaded state with ${_messagesList.length} messages.');

    // Emit to socket server
    _chatService.sendMessage(
      doctorId: doctorId,
      patientId: patientId,
      sender: sender,
      text: text,
    );
  }

  /// Internal helper to append incoming socket messages
  void _appendNewMessage(ChatMessageModel message) {
    // Avoid duplicates if same message ID already exists
    if (_messagesList.any((m) => m.id == message.id && message.id.isNotEmpty)) {
      return;
    }

    _messagesList.add(message);
    
    emit(ChatLoaded(
      messages: List.from(_messagesList),
      isSocketConnected: true,
    ));
  }

  @override
  Future<void> close() {
    _chatService.disconnect();
    return super.close();
  }
}
