import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';

class NotificationRepository {
  final _col = FirebaseFirestore.instance.collection('notifications');

  Future<void> create(AppNotification n) => _col.add(n.toMap());

  Stream<List<AppNotification>> watchMine(String uid) {
    return _col.where('userId', isEqualTo: uid).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => AppNotification.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> markRead(String id) => _col.doc(id).update({'isRead': true});

  Future<void> markAllRead(List<AppNotification> list) async {
    final unread = list.where((n) => !n.isRead);
    if (unread.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final n in unread) {
      batch.update(_col.doc(n.id), {'isRead': true});
    }
    await batch.commit();
  }
}
