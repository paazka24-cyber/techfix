import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserRepository {
  final _col = FirebaseFirestore.instance.collection('users');

  Stream<List<AppUser>> watchTechnicians() {
    return _col.where('role', isEqualTo: 'technician').snapshots().map(
          (snap) =>
              snap.docs.map((d) => AppUser.fromMap(d.data(), d.id)).toList(),
        );
  }

  Future<void> updateTechnicianProfile(
    String uid, {
    required String fullName,
    required String phoneNumber,
    required String specialization,
    required String bio,
  }) {
    return _col.doc(uid).update({
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'specialization': specialization,
      'bio': bio,
    });
  }

  Future<void> updateCustomerProfile(
    String uid, {
    required String fullName,
    required String phoneNumber,
    required String address,
  }) {
    return _col.doc(uid).update({
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
    });
  }
}
