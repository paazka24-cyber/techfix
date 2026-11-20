import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/device_category.dart';
import '../models/repair_request.dart';

class AdminRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<AppUser>> watchAllUsers() {
    return _db.collection('users').snapshots().map((snap) {
      final list =
          snap.docs.map((d) => AppUser.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<RepairRequest>> watchAllRequests() {
    return _db.collection('repair_requests').snapshots().map((snap) {
      final list =
          snap.docs.map((d) => RepairRequest.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> setUserRole(String uid, String role) =>
      _db.collection('users').doc(uid).update({'role': role});

  // Categories
  Future<void> addCategory(String name) => _db
      .collection('device_categories')
      .add(DeviceCategory(id: '', name: name).toMap());

  Future<void> renameCategory(String id, String name) =>
      _db.collection('device_categories').doc(id).update({'name': name});

  Future<void> deleteCategory(String id) =>
      _db.collection('device_categories').doc(id).delete();
}
