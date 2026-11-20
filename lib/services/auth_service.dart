import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // userChanges() also fires after reload(), so the app notices verification
  Stream<User?> get authStateChanges => _auth.userChanges();

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<UserCredential> signInWithGoogle() {
    final provider = GoogleAuthProvider();
    // Web uses a popup, Android/iOS use the native provider flow
    if (kIsWeb) {
      return _auth.signInWithPopup(provider);
    }
    return _auth.signInWithProvider(provider);
  }
}
