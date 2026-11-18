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
    final credential = await _authService.register(email, password);
    final uid = credential.user!.uid;

    final user = AppUser(
      uid: uid,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      role: 'customer',
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(uid).set(user.toMap());
    await credential.user!.sendEmailVerification();
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
  }

  Future<void> logout() => _authService.logout();

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordReset(email);

  Future<void> sendVerificationEmail() => _authService.sendEmailVerification();

  Future<void> reloadUser() => _authService.reloadUser();

  Future<void> signInWithGoogle() async {
    final cred = await _authService.signInWithGoogle();
    final user = cred.user!;
    final docRef = _db.collection('users').doc(user.uid);

    // First Google login: create the Firestore profile (always as customer)
    if (!(await docRef.get()).exists) {
      final appUser = AppUser(
        uid: user.uid,
        fullName: user.displayName ?? '',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ?? '',
        role: 'customer',
        profilePhoto: user.photoURL,
        createdAt: DateTime.now(),
      );
      await docRef.set(appUser.toMap());
    }
  }
}
