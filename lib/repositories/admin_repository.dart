import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // Uses a temporary second Firebase app so the admin stays signed in.
  Future<void> createTechnician({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String specialization,
  }) async {
    final app = await Firebase.initializeApp(
      name: 'tech_creator',
      options: Firebase.app().options,
    );
    try {
      final auth = FirebaseAuth.instanceFor(app: app);
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      await _db.collection('users').doc(uid).set(
            AppUser(
              uid: uid,
              fullName: fullName,
              email: email,
              phoneNumber: phoneNumber,
              role: 'technician',
              specialization: specialization,
              createdAt: DateTime.now(),
            ).toMap(),
          );
      try {
        await cred.user!.sendEmailVerification();
      } catch (_) {}
      await auth.signOut();
    } finally {
      await app.delete();
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).update(data);

  Future<void> deleteUserProfile(String uid) =>
      _db.collection('users').doc(uid).delete();

  Future<void> addCategory(String name) => _db
      .collection('device_categories')
      .add(DeviceCategory(id: '', name: name).toMap());

  Future<void> renameCategory(String id, String name) =>
      _db.collection('device_categories').doc(id).update({'name': name});

  Future<void> deleteCategory(String id) =>
      _db.collection('device_categories').doc(id).delete();
}
