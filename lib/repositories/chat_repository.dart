import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class ChatRepository {
  final _col = FirebaseFirestore.instance.collection('messages');

  // CREATE
  Future<void> send(Message message) => _col.add(message.toMap());

  // READ (live), oldest first
  Stream<List<Message>> watchMessages(String requestId) {
    return _col
        .where('requestId', isEqualTo: requestId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => Message.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  // UPDATE: mark the other person's messages as read by me
  Future<void> markRead(List<Message> messages, String myUid) async {
    final unread =
        messages.where((m) => m.senderId != myUid && !m.readBy.contains(myUid));
    if (unread.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final m in unread) {
      batch.update(_col.doc(m.id), {
        'readBy': FieldValue.arrayUnion([myUid]),
      });
    }
    await batch.commit();
  }
}
