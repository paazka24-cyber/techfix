import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthRepository(this._authService);

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    // Step 1: create the Auth account (credentials live here)
    final credential = await _authService.register(email, password);
    final uid = credential.user!.uid;

    // Step 2: save the profile (users/{uid})
    final user = AppUser(
      uid: uid,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      role: 'customer', // always customer on sign-up
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(uid).set(user.toMap());
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
  }

  Future<void> logout() => _authService.logout();

  // Read the profile of a user (needed for role-based navigation)
  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }
}
