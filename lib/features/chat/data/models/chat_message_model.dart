// ─────────────────────────────────────────────
//  chat_message_model.dart  –  Memomate
//  Model representing a single chat message.
// ─────────────────────────────────────────────

class ChatMessageModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String sender; // 'doctor' or 'patient'
  final String text;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      sender: json['sender'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'sender': sender,
      'text': text,
    };
  }
}
