import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String requestId;
  final String senderId;
  final String senderName;
  final String text;
  final List<String> readBy;
  final DateTime createdAt;

  Message({
    this.id = '',
    required this.requestId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.readBy = const [],
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    // createdAt is null for a moment on the sender's device (server timestamp pending)
    final ts = map['createdAt'];
    return Message(
      id: id,
      requestId: map['requestId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      readBy: List<String>.from(map['readBy'] ?? []),
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'readBy': [senderId], // the sender has obviously read it
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
