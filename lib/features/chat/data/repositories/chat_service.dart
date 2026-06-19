// ─────────────────────────────────────────────
//  chat_service.dart  –  Memomate
//  Service to handle real-time sockets and
//  fetching message history from the local chat server.
//  Implements singleton design with global background triggers.
// ─────────────────────────────────────────────

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/core/services/notification_service.dart';
import 'package:gradproj/features/chat/data/models/chat_message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  // ── Singleton Pattern ─────────────────────────────────
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal() {
    loadUnreadChats();
  }

  IO.Socket? _socket;

  // Global notifier for unread chat receiver IDs
  static final ValueNotifier<List<String>> unreadChats = ValueNotifier<List<String>>([]);

  // Active chat screen tracking
  static String? activeChatReceiverId;

  // Active chat screen callback
  Function(ChatMessageModel)? _onMessageReceivedCallback;

  /// Dynamic URL resolver: automatically points to 10.0.2.2 on Android emulator,
  /// and localhost for iOS/desktop.
  static String get chatServerUrl {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return 'http://192.168.1.18:5001';
    }
    return 'http://localhost:5001';
  }

  /// Retrieve the token dynamically from SharedPreferences based on active role
  Future<Map<String, String>> _getHeaders() async {
    final role = await AuthStorage.getLastRole();
    String? token;
    if (role == 'doctor') {
      token = await AuthStorage.getToken();
    } else if (role == 'patient' || role == 'caregiver') {
      token = await AuthStorage.getUserToken();
    }
    
    // Fail-safe robust fallback: if token is still null, fetch whichever token exists
    if (token == null || token.isEmpty) {
      final docToken = await AuthStorage.getToken();
      final usrToken = await AuthStorage.getUserToken();
      token = (docToken != null && docToken.isNotEmpty) ? docToken : usrToken;
    }

    return {
      'Authorization': 'Bearer ${token ?? ""}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ── Unread Chat Management ─────────────────────────────

  static Future<void> loadUnreadChats() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('unread_chat_ids') ?? [];
    unreadChats.value = list;
    debugPrint('🔔 [ChatService] Loaded unread chat IDs: $list');
  }

  static Future<void> markAsUnread(String senderId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(unreadChats.value);
    if (!list.contains(senderId)) {
      list.add(senderId);
      await prefs.setStringList('unread_chat_ids', list);
      unreadChats.value = list;
      debugPrint('🔔 [ChatService] Marked $senderId as unread. Current list: $list');
    }
  }

  static Future<void> markAsRead(String senderId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update local last read timestamp
    await prefs.setString('last_read_time_$senderId', DateTime.now().toIso8601String());

    final list = List<String>.from(unreadChats.value);
    if (list.contains(senderId)) {
      list.remove(senderId);
      await prefs.setStringList('unread_chat_ids', list);
      unreadChats.value = list;
      debugPrint('🔔 [ChatService] Marked $senderId as read. Current list: $list');
    }
  }

  static Future<bool> hasUnreadMessages(String receiverId, String currentUserId) async {
    try {
      final messages = await ChatService().getChatHistory(receiverId);
      if (messages.isEmpty) return false;
      
      final lastMessage = messages.last;
      final senderId = lastMessage.sender == 'doctor' ? lastMessage.doctorId : lastMessage.patientId;
      
      // If I sent the last message, it's not unread
      if (senderId == currentUserId) return false;
      
      final prefs = await SharedPreferences.getInstance();
      final lastReadStr = prefs.getString('last_read_time_$receiverId');
      if (lastReadStr == null) return true; // never read, so it is unread
      
      final lastRead = DateTime.parse(lastReadStr);
      return lastMessage.createdAt.isAfter(lastRead);
    } catch (e) {
      debugPrint('Error checking unread status for $receiverId: $e');
      return false;
    }
  }

  // ── Sockets Connections ────────────────────────────────

  /// Connect globally at app startup to listen for messages in background/other screens
  void connectGlobal({required String userId}) {
    if (_socket != null && _socket!.connected) {
      debugPrint('Global socket already connected. Re-registering room: $userId');
      _socket!.emit('register', userId);
      return;
    }

    final url = chatServerUrl;
    debugPrint('Connecting global socket at: $url');

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Global socket connected successfully. Registering: $userId');
      _socket!.emit('register', userId);
    });

    _socket!.onConnectError((err) {
      debugPrint('Global socket connect error: $err');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Global socket disconnected');
    });

    _socket!.on('receive_message', (data) {
      try {
        debugPrint('Global socket received message: $data');
        final message = ChatMessageModel.fromJson(data as Map<String, dynamic>);
        
        final senderId = message.sender == 'doctor' ? message.doctorId : message.patientId;
        
        if (activeChatReceiverId == senderId) {
          // If actively viewing this chat, trigger standard cubit receiver callback
          _onMessageReceivedCallback?.call(message);
        } else {
          // Otherwise, show instant push notification & trigger visual pulsing indicator
          markAsUnread(senderId);
          
          NotificationService().showChatNotification(
            title: message.sender == 'doctor' ? 'New Message from Doctor 🩺' : 'New Message from Caregiver 💬',
            body: message.text,
          );
        }
      } catch (e) {
        debugPrint('Error parsing received global socket message: $e');
      }
    });

    _socket!.connect();
  }

  /// Establish Socket.io connection to the local node server
  void connect({
    required String userId,
    required Function(ChatMessageModel) onMessageReceived,
    required Function(dynamic) onConnectError,
  }) {
    _onMessageReceivedCallback = onMessageReceived;
    
    // Clear unread flag for this user when entering chat room
    if (activeChatReceiverId != null) {
      markAsRead(activeChatReceiverId!);
    }

    if (_socket != null && _socket!.connected) {
      debugPrint('Socket already connected globally. Re-registering room: $userId');
      _socket!.emit('register', userId);
      return;
    }

    connectGlobal(userId: userId);
  }

  /// Send message in real-time via Socket.io
  void sendMessage({
    required String doctorId,
    required String patientId,
    required String sender,
    required String text,
  }) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('Cannot send message: Socket is not connected.');
      return;
    }

    final payload = {
      'doctorId': doctorId,
      'patientId': patientId,
      'sender': sender,
      'text': text,
    };
    debugPrint('Emitting send_message payload: $payload');
    _socket!.emit('send_message', payload);
  }

  /// Clear screen callback safely when exiting chat view without breaking global socket
  void disconnect() {
    debugPrint('Clearing active chat screen callback and receiver ID.');
    _onMessageReceivedCallback = null;
    activeChatReceiverId = null;
  }

  /// Fully disconnect the global socket connection (useful on logout)
  void disconnectGlobal() {
    if (_socket != null) {
      debugPrint('Fully disconnecting global chat socket.');
      _socket!.disconnect();
      _socket = null;
    }
  }

  /// Fetch chat history from the Node.js REST API
  Future<List<ChatMessageModel>> getChatHistory(String receiverId) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    final url = 'https://memo-mate-server.vercel.app/api/messages/$receiverId';

    try {
      final headers = await _getHeaders();
      debugPrint('Fetching chat history from $url with headers $headers');

      final response = await dio.get(
        url,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body['success'] == true && body['data'] is List) {
          final list = body['data'] as List;
          debugPrint('Successfully loaded ${list.length} messages from history');
          return list
              .map((item) =>
                  ChatMessageModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching chat history (Offline/DB disconnected?): $e');
      return [];
    }
  }
}
