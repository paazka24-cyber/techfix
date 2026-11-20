import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId; // recipient
  final String fromUserId;
  final String title;
  final String body;
  final String? requestId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    this.id = '',
    required this.userId,
    required this.fromUserId,
    required this.title,
    required this.body,
    this.requestId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    final ts = map['createdAt'];
    return AppNotification(
      id: id,
      userId: map['userId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      requestId: map['requestId'],
      isRead: map['isRead'] ?? false,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'fromUserId': fromUserId,
        'title': title,
        'body': body,
        'requestId': requestId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
